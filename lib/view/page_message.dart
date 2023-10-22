import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controller/auth.dart'; // Import the Auth class from your auth.dart file

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final Auth _auth = Auth(); // Create an instance of the Auth class
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _auth.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            // Handle errors or null user data gracefully
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final userData = snapshot.data!;
          final ispetugas = userData['accountType'] == 'petugas';

          if (ispetugas) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: db.collection('panic_data').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  // Handle stream errors gracefully
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final panicData = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: panicData.length,
                  itemBuilder: (context, index) {
                    final data = panicData[index].data();
                    final documentId = panicData[index]
                        .id; // Get the document ID for the message
                    final sender =
                        data['sender'] as String?; // Perform null check here
                    final message =
                        data['message'] as String?; // Perform null check here
                    final timestamp = data['timestamp']
                        as Timestamp?; // Perform null check here
                    return Dismissible(
                      key: Key(documentId), // Use the document ID as the key
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // Delete the message when dismissed
                        _deleteMessageWithConfirmation(documentId);
                      },
                      child: ListTile(
                        title: Text(sender ?? ''),
                        subtitle: Text(message ?? ''),
                        trailing: Text(
                          // Format the timestamp into a readable format
                          timestamp != null ? _formatTimestamp(timestamp) : '',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Text('Untuk pengembangan kedepan'),
            );
          }
        },
      ),
    );
  }

  // Helper method to format timestamp into a readable format
  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${dateTime.hour}:${dateTime.minute}';
  }

// Method to delete a message from Firestore with confirmation dialog
  Future<void> _deleteMessageWithConfirmation(String documentId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Refresh the message list when the user cancels the delete action
                setState(() {});
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Proceed with the deletion
                Navigator.of(context).pop(); // Close the dialog
                try {
                  await db.collection('panic_data').doc(documentId).delete();
                  // Call setState after deletion to trigger a rebuild of the widget tree
                  setState(() {});
                } catch (e) {
                  // Handle any errors that occur during the deletion process
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete the message.'),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
