import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:test_rait_new/Screens/reportPAge.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("reports");
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  void _fetchReports() {
    _databaseRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Map<String, dynamic>> loadedReports = [];

        data.forEach((key, value) {
          final Map<String, dynamic> report = Map<String, dynamic>.from(value);
          loadedReports.add(report);
        });

        setState(() {
          _reports = loadedReports;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents',style: TextStyle(fontSize: 16),),
      ),
      body: _reports.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _buildChatMessage(report);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  ReportPage()),
        );
      },
      child: Text('Report Incident') ,
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> report) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Text(report['incidentType'][0]),
            backgroundColor: Colors.blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['incidentType'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(report['description']),
                  const SizedBox(height: 5),
                  Text(
                    'Location: ${report['location']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Severity: ${report['severity'].toString()}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Date: ${report['date']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
