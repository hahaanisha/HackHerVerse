import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bottomNavBar.dart';
import 'sosActivated.dart';


class AddContactsPage extends StatefulWidget {
  final String userId;
  const AddContactsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AddContactsPageState createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  List<Contact> _selectedContacts = [];
  bool _isLoading = false;

  Future<void> _pickContacts() async {
    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      List<Contact> pickedContacts = [];

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select up to 5 Contacts'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  Contact contact = contacts.elementAt(index);
                  bool isSelected = pickedContacts.contains(contact);
                  return ListTile(
                    title: Text(contact.displayName ?? 'Unknown'),
                    subtitle: Text(contact.phones!.isNotEmpty ? contact.phones!.first.value ?? '' : 'No number'),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            if (pickedContacts.length < 5) {
                              pickedContacts.add(contact);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You can select a maximum of 5 contacts')),
                              );
                            }
                          } else {
                            pickedContacts.remove(contact);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedContacts = pickedContacts;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access contacts.')),
      );
    }
  }

  Future<void> _saveContacts() async {
    if (_selectedContacts.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    List<Map<String, String>> emergencyContacts = _selectedContacts.map((contact) {
      return {
        'name': contact.displayName ?? 'Unknown',
        'phone': contact.phones!.isNotEmpty ? contact.phones!.first.value ?? '' : '',
      };
    }).toList();

    try {
      await FirebaseDatabase.instance.ref().child('users/${widget.userId}/contacts').set(emergencyContacts);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Bottomnavbar()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save contacts: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSOSActivatedPage() {
    List<Map<String, String>> emergencyContacts = _selectedContacts.map((contact) {
      return {
        'name': contact.displayName ?? 'Unknown',
        'phone': contact.phones!.isNotEmpty ? contact.phones!.first.value ?? '' : '',
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SOSActivatedPage(emergencyContacts: emergencyContacts),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Emergency Contacts')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedContacts.isEmpty
                ? const Text('No contacts selected.')
                : Expanded(
              child: ListView.builder(
                itemCount: _selectedContacts.length,
                itemBuilder: (context, index) {
                  Contact contact = _selectedContacts[index];
                  return ListTile(
                    title: Text(contact.displayName ?? 'Unknown'),
                    subtitle: Text(contact.phones!.isNotEmpty ? contact.phones!.first.value ?? '' : 'No number'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickContacts,
              icon: const Icon(Icons.contacts),
              label: const Text('Pick Contacts'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _selectedContacts.isNotEmpty ? _saveContacts : null,
              icon: const Icon(Icons.save),
              label: const Text('Save Contacts'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectedContacts.isNotEmpty ? _navigateToSOSActivatedPage : null,
              icon: const Icon(Icons.warning),
              label: const Text('Activate SOS Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
