import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Added geolocator package
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class Econtactpage extends StatefulWidget {
  const Econtactpage({super.key});

  @override
  State<Econtactpage> createState() => _EcontactpageState();
}

class _EcontactpageState extends State<Econtactpage> {
  String selectedSuburb = 'Mulund';
  LatLng selectedLocation = LatLng(19.1663, 72.9432);

  // Map of Mumbai suburbs with their coordinates
  final Map<String, LatLng> suburbCoordinates = {
    'Mulund': LatLng(19.1663, 72.9432),
    'Bhandup': LatLng(19.1511, 72.9372),
    'Nahur': LatLng(19.1589, 72.9428),
    'Thane': LatLng(19.2183, 72.9781),
    'Powai': LatLng(19.1176, 72.9060),
    'Andheri': LatLng(19.1136, 72.8697),
    'Bandra': LatLng(19.0596, 72.8295),
    'Borivali': LatLng(19.2321, 72.8596),
    'Chembur': LatLng(19.0522, 72.9005),
    'Dadar': LatLng(19.0178, 72.8478),
    'Dharavi': LatLng(19.0380, 72.8538),
    'Ghatkopar': LatLng(19.0858, 72.9086),
    'Goregaon': LatLng(19.1663, 72.8526),
    'Jogeshwari': LatLng(19.1538, 72.8509),
    'Juhu': LatLng(19.1075, 72.8263),
    'Kalyan': LatLng(19.2403, 73.1305),
    'Kandivali': LatLng(19.2037, 72.8519),
    'Kurla': LatLng(19.0726, 72.8845),
    'Malad': LatLng(19.1874, 72.8484),
    'Matunga': LatLng(19.0283, 72.8557),
    'Mira Road': LatLng(19.2809, 72.8464),
    'Santacruz': LatLng(19.0798, 72.8397),
    'Sion': LatLng(19.0380, 72.8690),
    'Versova': LatLng(19.1351, 72.8146),
    'Nerul': LatLng(19.1174, 72.9277),
    'Vile Parle': LatLng(19.0969, 72.8497),
    'Worli': LatLng(19.0179, 72.8346),
  };

  // Emergency contacts for each suburb
  final Map<String, Map<String, String>> emergencyContacts = {
    'Mulund': {
      'Police': '022-25684444',
      'Police Control Room': '022-25633533',
      'Ambulance': '108',
      'Women Helpline': '1091',
      'Fire Brigade': '101',
      'Municipal Ward Office': '022-25694252',
      'Railway Police': '022-25683320',
    },
    'Bhandup': {
      'Police': '022-25954343',
      'Police Control Room': '022-25954321',
      'Ambulance': '108',
      'Women Helpline': '1091',
      'Fire Brigade': '101',
      'Municipal Ward Office': '022-25954545',
    },
    'Thane': {
      'Police': '022-25401010',
      'Police Control Room': '022-25401919',
      'Ambulance': '108',
      'Women Helpline': '1091',
      'Fire Brigade': '101',
      'Municipal Corporation': '022-25331590',
    },
    // For other suburbs, maintaining essential emergency numbers
    'Andheri': {'Police': '022-26303893', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Bandra': {'Police': '022-26439877', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Borivali': {'Police': '022-28893333', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Chembur': {'Police': '022-25224475', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Dadar': {'Police': '022-24132327', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Ghatkopar': {'Police': '022-25133333', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Goregaon': {'Police': '022-28722407', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Jogeshwari': {'Police': '022-26783333', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Kandivali': {'Police': '022-28854327', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Kurla': {'Police': '022-26500901', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Malad': {'Police': '022-28893333', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Powai': {'Police': '022-25703333', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Santacruz': {'Police': '022-26491233', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Nerul': {'Police': '022-25742828', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
    'Worli': {'Police': '022-24924444', 'Ambulance': '108', 'Fire Brigade': '101', 'Women Helpline': '1091'},
  };

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Function to get the user's current location
  Future<void> _getUserLocation() async {
    // Check for location permissions
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      // Find the closest suburb based on coordinates (this can be done via distance calculation or using pre-defined ranges)
      String nearestSuburb = _getNearestSuburb(userLocation);

      setState(() {
        selectedSuburb = nearestSuburb;
        selectedLocation = userLocation;
      });
    }
  }

  // Function to get the nearest suburb based on coordinates (simple distance check)
  String _getNearestSuburb(LatLng userLocation) {
    double minDistance = double.infinity;
    String nearestSuburb = '';

    suburbCoordinates.forEach((suburb, coordinates) {
      double distance = Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, coordinates.latitude, coordinates.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearestSuburb = suburb;
      }
    });

    return nearestSuburb;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (!await launcher.launchUrl(launchUri, mode: launcher.LaunchMode.externalApplication)) {
        throw 'Could not launch $phoneNumber';
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Could not launch call: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Emergency Contacts for $selectedSuburb',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: emergencyContacts[selectedSuburb]!.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: Colors.blue),
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                    onTap: () => _makePhoneCall(entry.value),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
