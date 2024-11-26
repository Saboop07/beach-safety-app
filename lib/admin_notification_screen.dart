import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key, required this.onAddNotification});

  final Function(String title, String message) onAddNotification;

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notifications, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Add Notification for Tourist",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextFormField(
            controller: messageController,
            decoration: const InputDecoration(hintText: "Write a message for tourist"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              await db.collection('messages').add({'message': messageController.text});
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notification Sent"), backgroundColor: Colors.green),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  "Send Notification",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: db.collection('messages').snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, int index) {
                      DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                      return ListTile(
                        title: Text(documentSnapshot['message']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                editController.text = documentSnapshot['message'];
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Edit Notification"),
                                      content: TextFormField(
                                        controller: editController,
                                        decoration: const InputDecoration(hintText: "Edit your message"),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await db
                                                .collection('messages')
                                                .doc(documentSnapshot.id)
                                                .update({'message': editController.text});
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text("Notification Updated"),
                                                  backgroundColor: Colors.blue),
                                            );
                                          },
                                          child: const Text("Update"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue), // Pencil icon for edit
                            ),
                            IconButton(
                              onPressed: () {
                                db.collection('messages').doc(documentSnapshot.id).delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Deleted"), backgroundColor: Colors.red),
                                );
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
