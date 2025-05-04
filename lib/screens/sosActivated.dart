import 'package:flutter/material.dart';
import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'deactivatedSOS.dart';

class SOSActivatedPage extends StatefulWidget {
  final List<Map<String, String>> emergencyContacts;

  const SOSActivatedPage({Key? key, required this.emergencyContacts}) : super(key: key);

  @override
  State<SOSActivatedPage> createState() => _SOSActivatedPageState();
}

class _SOSActivatedPageState extends State<SOSActivatedPage> {
  Position? _currentPosition;
  bool _isFetchingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      setState(() {
        _isFetchingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isFetchingLocation = false;
    });
  }

  Future<bool> _checkSmsPermission() async {
    final smsPermission = await Permission.sms.status;
    if (smsPermission.isGranted) {
      return true;
    } else {
      final status = await Permission.sms.request();
      return status.isGranted;
    }
  }

  Future<void> _sendSOSMessage() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    if (_currentPosition == null) {
      return; // Exit if still null after retry
    }

    bool isPermissionGranted = await _checkSmsPermission();
    if (!isPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SMS permission not granted')),
      );
      return;
    }

    String locationLink = 'https://www.google.com/maps/search/?api=1&query=${_currentPosition?.latitude},${_currentPosition?.longitude}';
    String message = 'SOS! I need help! My location: $locationLink';

    for (var contact in widget.emergencyContacts) {
      String? phoneNumber = contact['phone'];
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        try {
          var result = await BackgroundSms.sendMessage(
            phoneNumber: phoneNumber,
            message: message,
          );

          if (result == SmsStatus.sent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('SOS message sent to ${contact['name']}')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to send SOS message to ${contact['name']}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sending message to ${contact['name']}: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid phone number for ${contact['name']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SOS Mode Activated"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/sos.png',
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              const Text(
                'SOS Mode Activated',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isFetchingLocation ? null : _sendSOSMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isFetchingLocation
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Send to Authority',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DeactivatePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Deactivate SOS Mode',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
