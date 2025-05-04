import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import '../color/colors.dart';
import 'ChatPage.dart';
import 'add_contacts.dart';
import 'fake_call.dart';
import 'guide_main.dart';
import 'homePage.dart';
import 'incident_list_page.dart';
import 'sosActivated.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});
  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  bool _shakeDetectionActive = false; // Prevents automatic SOS on app start
  // Speech recognition variables
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _wordsSpoken = "";


  static List<Widget> _pages = <Widget>[
    Homepage(),
    FakeCallPage(),
    IncidentListPage(),
    GuidePage(),
  ];


  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _startShakeDetection();
    initSpeech();
  }
// Initialize speech recognition
  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
    setState(() {});
  }

  // Start listening to speech
  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Listening...'),
        duration: Duration(seconds: 2),
      ),
    );
  }


  // Stop listening to speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      print('Words spoken: $_wordsSpoken');

      // Check for help-related keywords
      if (_wordsSpoken.toLowerCase().contains('help') ||
          _wordsSpoken.toLowerCase().contains('emergency') ||
          _wordsSpoken.toLowerCase().contains('danger')) {
        print('Help keyword detected!');
        _sendSOS();
      }
    });
  }

  @override
  void dispose() {
    _stopListening();
    _stopShakeDetection();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      await Permission.sms.request();
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _sendSOS() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool hasPermission = await isPermissionGranted();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS permission is required to send SOS messages'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Position position = await _getCurrentLocation();
      String message =
          "SOS! I need help! This is an emergency message. My location: "
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      await sendSms('8879781985', message);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS message sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to SOS Page after sending the message
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SOSActivatedPage(emergencyContacts: [],)), // Replace with SOS page
      );
    } catch (e) {
      print('Error sending SOS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send SOS message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back arrow
        title: Center(
          child: Text(
            'Kawach',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.contacts, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddContactsPage(userId: '',)),
              );
            },
          ),
        ],
      ),

      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          await _sendSOS();
        },
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.sos, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call, color: Colors.white),
            label: 'FakeCall',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.crisis_alert, color: Colors.white),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined, color: Colors.white),
            label: 'guide',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
      ),
    );
  }

  getPermission() async => await [Permission.sms].request();

  Future<bool> isPermissionGranted() async => await Permission.sms.status.isGranted;

  Future<void> sendSms(String phoneNumber, String message) async {
    var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message);
    if (result == SmsStatus.sent) {
      print('Sent');
    } else {
      print('Failed');
    }
  }

  StreamSubscription? _accelerometerSubscription;

  void _startShakeDetection() {
    const double shakeThreshold = 5.0;

    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration = event.x * event.x + event.y * event.y + event.z * event.z;
      if (acceleration > shakeThreshold && _shakeDetectionActive) {
        _sendSOS();
      }
    });
  }

  void _stopShakeDetection() {
    _accelerometerSubscription?.cancel();
  }
}
