import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'reportPAge.dart';


class IncidentListPage extends StatefulWidget {
  @override
  _IncidentListPageState createState() => _IncidentListPageState();
}

class _IncidentListPageState extends State<IncidentListPage> {
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/reports.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      setState(() {
        _reports = List<Map<String, dynamic>>.from(jsonDecode(contents));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Incident Reports'),
      //   backgroundColor: Colors.blue,
      // ),
      body: Column(
        children: [
          Expanded(
            child: _reports.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Incident Type: ${report['incidentType']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Severity: ${report['severity']}'),
                        Text('Location: ${report['location']}'),
                        Text('Description: ${report['description']}'),
                        Text('Date: ${report['date']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportPage()),
                ).then((_) {
                  _loadReports(); // Reload reports when returning to this page
                });
              },
              child: const Text('Report Incident'),
            ),
          ),
        ],
      ),
    );
  }
}
