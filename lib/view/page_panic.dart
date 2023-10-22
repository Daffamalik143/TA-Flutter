// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controller/auth.dart'; // Import the Auth class from your auth.dart file

class PanicPage extends StatefulWidget {
  const PanicPage({Key? key}) : super(key: key);

  @override
  State<PanicPage> createState() => _PanicPageState();
}

class _PanicPageState extends State<PanicPage> {
  final Auth _auth = Auth(); // Create an instance of the Auth class

  var db = FirebaseFirestore.instance;
  bool isActiveBantuan = false;
  bool isActiveBahaya = false;
  bool isActiveTersesat = false;
  String panicText = ''; // Default panic text is "Saya sedang dalam bahaya"

  void toggleActiveStateBantuan() {
    setState(() {
      isActiveBantuan = !isActiveBantuan;
      isActiveBahaya = false;
      isActiveTersesat = false;
      panicText = 'Saya butuh bantuan';
    });
    if (isActiveBantuan) {
      _showSnackBar('Pesan terkirim');
    }
  }

  void toggleActiveStateBahaya() {
    setState(() {
      isActiveBahaya = !isActiveBahaya;
      isActiveBantuan = false;
      isActiveTersesat = false;
      panicText = 'Saya sedang dalam bahaya';
    });
    if (isActiveBahaya) {
      _showSnackBar('Pesan terkirim');
    }
  }

  void toggleActiveStateTersesat() {
    setState(() {
      isActiveTersesat = !isActiveTersesat;
      isActiveBantuan = false;
      isActiveBahaya = false;
      panicText = 'Saya sedang tersesat';
    });
    if (isActiveTersesat) {
      _showSnackBar('Pesan terkirim');
    }
  }

  void _showSnackBar(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );

    final userData = await _auth.getUserData();
    if (userData != null && userData['accountType'] == 'pengguna') {
      // Only allow users with role "pengguna" to send panic data

      // Get the current user's document in the "panic_data" collection
      final docRef = db.collection('panic_data').doc(_auth.currentUser!.uid);

      // Update the panic data for the current user
      docRef.set({
        'sender': userData['username'],
        'message': panicText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Display a message or take appropriate action if the user does not have the required role.
      // For example, you can show a SnackBar to inform the user that they are not allowed to send panic data.
      _showSnackBar("You are not allowed to send panic data.");
    }
  }

  //Delete Pesan
  bool isActiveDelete = false;

  void toggleActiveStateDelete() {
    setState(() {
      isActiveDelete = !isActiveDelete;
    });
  }

  void deleteSentMessage() async {
    final userData = await _auth.getUserData();
    if (userData != null && userData['accountType'] == 'pengguna') {
      // Only allow users with role "pengguna" to delete their sent messages

      // Get the current user's document in the "panic_data" collection
      final docRef = db.collection('panic_data').doc(_auth.currentUser!.uid);

      // Check if the document exists before attempting to delete
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        // Delete the panic data for the current user
        docRef.delete();

        // Reset the panic text and buttons states
        setState(() {
          isActiveBahaya = false;
          isActiveTersesat = false;
          panicText = '';
          isActiveDelete = false;
        });
        _showSnackBar("Message deleted.");
      } else {
        // Show a message if there are no messages to delete
        _showSnackBar("There are no messages to delete.");
      }
    } else {
      // Display a message or take appropriate action if the user does not have the required role.
      // For example, you can show a SnackBar to inform the user that they are not allowed to delete messages.
      _showSnackBar("You are not allowed to delete messages.");
    }
  }
  //Delete Pesan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16), // Add some space above the text
                const Text(
                  'Pilih pesan yang ingin dikirim:',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(
                    height: 16), // Add some space between the text and buttons
                Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 350,
                        child: ElevatedButton(
                          onPressed: toggleActiveStateBantuan,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: isActiveBantuan
                                ? Colors.blueGrey[400]
                                : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Saya butuh bantuan',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 350,
                        child: ElevatedButton(
                          onPressed: toggleActiveStateBahaya,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: isActiveBahaya
                                ? Colors.blueGrey[400]
                                : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Saya sedang dalam bahaya',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 16), // Add some space between the buttons
                      SizedBox(
                        width: 350,
                        child: ElevatedButton(
                          onPressed: toggleActiveStateTersesat,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: isActiveTersesat
                                ? Colors.blueGrey[400]
                                : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            'Saya sedang tersesat',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: deleteSentMessage,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: isActiveDelete ? Colors.red : Colors.grey[300],
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(
                Icons.delete,
                size: 32,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
