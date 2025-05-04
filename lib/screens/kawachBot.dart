import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class SafetySupport extends StatefulWidget {
  const SafetySupport({super.key});

  @override
  State<SafetySupport> createState() => _SafetySupportState();
}

class _SafetySupportState extends State<SafetySupport> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  String _modelResponse = "";
  final apikey = 'AIzaSyBC1V1ERSRe7sXp-dDtysFu8EukQ055P-4'; // Replace with your Gemini API key
  Position? _currentPosition;
  String _currentAddress = "";

  List<Map<String, String>> _emergencyContacts = [];

  Future<void> _speakWelcome() async {
    await _flutterTts.speak(
        'Welcome to Kawach Safety Bot. Speak your situation or say help for immediate assistance.');
  }

  @override
  void initState() {
    super.initState();
    initSpeech();
    _speakWelcome();
    _getCurrentLocation();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.contacts.request();
    await Permission.location.request();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      // You can implement reverse geocoding here to get the address
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      handleSafetyResponse();
    });
  }

  Future<void> handleSafetyResponse() async {
    // Handle immediate emergency keywords
    if (_wordsSpoken.toLowerCase().contains('emergency') ||
        _wordsSpoken.toLowerCase().contains('help me')) {
      await _handleEmergency();
    } else if (_wordsSpoken.toLowerCase().contains('what is kawach')) {
      _flutterTts.speak(
          'Kawach is your personal safety assistant, designed to provide immediate help and safety guidance in challenging situations.');
    } else if (_wordsSpoken.toLowerCase().contains('safe places')) {
      _suggestSafePlaces();
    } else if (_wordsSpoken.toLowerCase().contains('contact police')) {
      _contactEmergencyServices();
    } else {
      talkWithGemini();
    }
  }

  Future<void> _handleEmergency() async {
    // Implement emergency protocol
    _flutterTts.speak(
        'Initiating emergency protocol. Sending your location to emergency contacts. Stay calm and stay on the line.');
    // Add your emergency handling logic here
    // - Send SMS with location
    // - Contact emergency services
    // - Alert emergency contacts
  }

  void _suggestSafePlaces() async {
    if (_currentPosition != null) {
      // Implement nearby safe places suggestion
      // You can integrate with Maps API to get nearby police stations, hospitals, etc.
      _flutterTts.speak(
          'Looking for safe places near you. Please wait while I fetch the information.');
    } else {
      _flutterTts.speak(
          'Unable to access your location. Please ensure location services are enabled.');
    }
  }

  void _contactEmergencyServices() {
    // Implement emergency services contact logic
    _flutterTts.speak(
        'Contacting emergency services. Sharing your current location with them.');
  }

  Future<void> talkWithGemini() async {
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apikey);

    final prompt = '''
    You are Kawach, a women's safety assistant. Provide immediate, helpful safety advice for the following situation.
    Current location: ${_currentAddress}
    User's words: ${_wordsSpoken}
    
    Provide a brief, clear, and calming response focused on immediate safety steps.
    Keep the response under 30 words and actionable.
    ''';

    final content = Content.text(prompt);

    try {
      final response = await model.generateContent([content]);

      setState(() {
        _modelResponse = response.text!;
      });

      _flutterTts.speak(_modelResponse);
    } catch (e) {
      print('Error getting response: $e');
      _flutterTts.speak(
          'I apologize, but I\'m having trouble connecting. Please say "help" for immediate emergency assistance.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50], // Safety-themed color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Safety Status Indicator
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "I'm listening to you:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _wordsSpoken,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.purple[700],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.purple[700],
          onPressed: _speechToText.isListening ? _stopListening : _startListening,
          child: Icon(
            _speechToText.isListening ? Icons.mic : Icons.mic_off,
            color: Colors.white,
            size: MediaQuery.of(context).size.height * 0.1,
          ),
        ),
      ),
    );
  }
}