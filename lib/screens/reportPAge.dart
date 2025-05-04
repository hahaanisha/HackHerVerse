import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_rait_new/Screens/ChatPage.dart';
import 'incident_list_page.dart'; // Import the IncidentListPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kawach Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IncidentListPage(), // Set IncidentListPage as the home page
    );
  }
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedIncidentType;
  double _severity = 1;
  double? _latitude;
  double? _longitude;

  final List<String> _incidentTypes = [
    'Harassment',
    'Stalking',
    'Domestic Violence',
    'Assault',
    'Kidnapping',
    'Cyberbullying',
    'Eve Teasing',
    'Mugging',
    'Human Trafficking',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildIncidentTypeDropdown(),
                _buildSeveritySlider(),
                _buildLocationSearchField(),
                _buildTextField(_descriptionController, 'Description'),
                _buildDateField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitReport,
                  child: const Text('Submit Report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedIncidentType,
        items: _incidentTypes.map((type) {
          return DropdownMenuItem(value: type, child: Text(type));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedIncidentType = value;
          });
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Incident Type',
        ),
        validator: (value) => value == null ? 'Please select an incident type' : null,
      ),
    );
  }

  Widget _buildSeveritySlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Severity'),
          Slider(
            value: _severity,
            min: 1,
            max: 5,
            divisions: 4,
            label: _severity.round().toString(),
            onChanged: (value) {
              setState(() {
                _severity = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _locationController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Location',
        ),
        onTap: () async {
          await _searchLocation();
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a location';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _searchLocation() async {
    String location = _locationController.text;
    if (location.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(location);
        if (locations.isNotEmpty) {
          setState(() {
            _latitude = locations.first.latitude;
            _longitude = locations.first.longitude;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching location: $e')),
        );
      }
    }
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _dateController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Date',
        ),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            _dateController.text = date.toLocal().toString().split(' ')[0];
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      final reportData = {
        'incidentType': _selectedIncidentType,
        'severity': _severity,
        'location': _locationController.text,
        'latitude': _latitude,
        'longitude': _longitude,
        'description': _descriptionController.text,
        'date': _dateController.text,
      };

      _saveReportToFile(reportData).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
        _formKey.currentState!.reset();
        Navigator.pop(context); // Navigate back to the IncidentListPage
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $error')),
        );
      });
    }
  }

  Future<void> _saveReportToFile(Map<String, dynamic> reportData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/reports.json');
    List<Map<String, dynamic>> reports = [];

    if (await file.exists()) {
      final contents = await file.readAsString();
      reports = List<Map<String, dynamic>>.from(jsonDecode(contents));
    }

    reports.add(reportData);
    final jsonData = jsonEncode(reports);
    await file.writeAsString(jsonData);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
