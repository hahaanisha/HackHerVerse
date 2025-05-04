import 'package:flutter/material.dart';
import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bottomNavBar.dart';

class DeactivatePage extends StatefulWidget {
  const DeactivatePage({Key? key}) : super(key: key);

  @override
  _DeactivatePageState createState() => _DeactivatePageState();
}

class _DeactivatePageState extends State<DeactivatePage> {
  TextEditingController _pinController = TextEditingController();
  bool _isPinCorrect = false;
  final List<String> _emergencyNumbers = ['+918879781985'];

  Future<bool> _checkSmsPermission() async {
    final smsPermission = await Permission.sms.status;
    if (smsPermission.isGranted) {
      return true;
    } else {
      final status = await Permission.sms.request();
      return status.isGranted;
    }
  }

  Future<void> _sendSafetyMessage() async {
    bool isPermissionGranted = await _checkSmsPermission();
    if (!isPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SMS permission not granted')),
      );
      return;
    }

    String message = "I am Safe. This was a false alarm.";

    for (String number in _emergencyNumbers) {
      try {
        var result = await BackgroundSms.sendMessage(
          phoneNumber: number,
          message: message,
        );

        if (result == SmsStatus.sent) {
          print("SMS sent successfully to $number");
        } else {
          print("Failed to send SMS to $number");
        }
      } catch (e) {
        print("Error sending SMS to $number: $e");
      }
    }
  }

  void _checkPin() async {
    if (_pinController.text == '1234') {
      setState(() {
        _isPinCorrect = true;
      });

      // Send safety message to both numbers
      await _sendSafetyMessage();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS Mode deactivated and contacts notified')),
      );

      // Navigate to bottom navigation bar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Bottomnavbar()),
      );
    } else {
      setState(() {
        _isPinCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivate SOS Mode'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the pin to deactivate SOS mode:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Pin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _checkPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Deactivate SOS',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            if (!_isPinCorrect)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Incorrect PIN. Try again.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}