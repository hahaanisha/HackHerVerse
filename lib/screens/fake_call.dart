import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class FakeCallPage extends StatelessWidget {
  final String callAgentNumber = '+13238143763';

  const FakeCallPage({Key? key}) : super(key: key);

  Future<void> _launchFakeCall(BuildContext context) async {
    final status = await Permission.phone.request();
    print('Permission status: $status');

    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone permission is required to make calls.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Try direct string URL first
      final phoneNumber = 'tel:$callAgentNumber';
      print('Attempting to launch: $phoneNumber');

      // Create the Uri object
      final Uri launchUri = Uri.parse(phoneNumber);
      print('URI created: $launchUri');

      // Attempt to launch
      final bool result = await launchUrl(
        launchUri,
        mode: LaunchMode.platformDefault,
      );
      print('Launch result: $result');

      if (!result) {
        // Try alternative formatting if first attempt fails
        final alternativeUri = Uri(
          scheme: 'tel',
          path: callAgentNumber,
        );
        print('Trying alternative URI: $alternativeUri');

        final bool alternativeResult = await launchUrl(
          alternativeUri,
          mode: LaunchMode.platformDefault,
        );

        if (!alternativeResult) {
          throw 'Could not launch phone app';
        }
      }
    } catch (e) {
      print('Launch error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // Rest of your code remains the same...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Press "Call Now" to initiate a fake call.\nYou can talk about anything under the sky in English to the agent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showConfirmationDialog(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Call Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fake Call'),
          content: const Text('Do you want to start a fake call?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Press "Call Now" to initiate a fake call.'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchFakeCall(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}