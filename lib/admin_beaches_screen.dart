import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminBeachesScreen extends StatefulWidget {
  const AdminBeachesScreen({super.key, required this.onAddBeach});

  final Function(String name, String details) onAddBeach;

  @override
  State<AdminBeachesScreen> createState() => _AdminBeachesScreenState();
}

class _AdminBeachesScreenState extends State<AdminBeachesScreen> {
  TextEditingController beachNameController = TextEditingController();
  TextEditingController beachDetailsController = TextEditingController();
  TextEditingController editBeachNameController = TextEditingController();
  TextEditingController editBeachDetailsController = TextEditingController();
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
            Icon(Icons.beach_access, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Add Beach Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextFormField(
            controller: beachNameController,
            decoration: const InputDecoration(hintText: "Beach Name"),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: beachDetailsController,
            decoration: const InputDecoration(hintText: "Beach Details"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              await db.collection('beaches').add({
                'name': beachNameController.text,
                'details': beachDetailsController.text
              });
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Beach Added"), backgroundColor: Colors.green),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.beach_access, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  "Add Beach",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: db.collection('beaches').snapshots(),
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
                        title: Text(documentSnapshot['name']),
                        subtitle: Text(documentSnapshot['details']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                editBeachNameController.text = documentSnapshot['name'];
                                editBeachDetailsController.text = documentSnapshot['details'];
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Edit Beach Details"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: editBeachNameController,
                                            decoration: const InputDecoration(hintText: "Edit Beach Name"),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: editBeachDetailsController,
                                            decoration: const InputDecoration(hintText: "Edit Beach Details"),
                                          ),
                                        ],
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
                                            await db.collection('beaches').doc(documentSnapshot.id).update({
                                              'name': editBeachNameController.text,
                                              'details': editBeachDetailsController.text
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text("Beach Updated"),
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
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () {
                                db.collection('beaches').doc(documentSnapshot.id).delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Beach Deleted"), backgroundColor: Colors.red),
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
