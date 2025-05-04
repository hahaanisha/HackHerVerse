import 'package:flutter/material.dart';

void main() {
  runApp(SafetyChecklistApp());
}

class SafetyChecklistApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafetyChecklistPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SafetyChecklistPage extends StatefulWidget {
  @override
  _SafetyChecklistPageState createState() => _SafetyChecklistPageState();
}

class _SafetyChecklistPageState extends State<SafetyChecklistPage> {
  // List of safety tips with actionable instructions
  final List<Map<String, dynamic>> safetyTips = [
    {'tip': 'Share your live location with a trusted contact when traveling.', 'isChecked': false},
    {'tip': 'Stick to well-lit and busy areas, especially at night.', 'isChecked': false},
    {'tip': 'Keep your phone charged and save emergency numbers.', 'isChecked': false},
    {'tip': 'Carry a personal safety alarm or pepper spray.', 'isChecked': false},
    {'tip': 'Stay alert and avoid distractions like headphones in both ears.', 'isChecked': false},
    {'tip': 'Use ride-hailing apps with safety features like trip-sharing.', 'isChecked': false},
    {'tip': 'Regularly update your emergency contacts and medical information on your phone', 'isChecked': false},
    {'tip': 'Always plan your route in advance and inform someone about your expected arrival time', 'isChecked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Checklist'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Safety Tips for Women',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: safetyTips.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(
                        safetyTips[index]['tip'],
                        style: TextStyle(
                          decoration: safetyTips[index]['isChecked']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      value: safetyTips[index]['isChecked'],
                      onChanged: (bool? value) {
                        setState(() {
                          safetyTips[index]['isChecked'] = value ?? false;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}