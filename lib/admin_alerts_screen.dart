import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminAlertsScreen extends StatefulWidget {
  const AdminAlertsScreen({super.key, required this.onAddAlert});

  final Function(String title, String details) onAddAlert;

  @override
  State<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends State<AdminAlertsScreen> {
  TextEditingController alertTitleController = TextEditingController();
  TextEditingController alertDetailsController = TextEditingController();
  TextEditingController editAlertTitleController = TextEditingController();
  TextEditingController editAlertDetailsController = TextEditingController();
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
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Add Alert Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextFormField(
            controller: alertTitleController,
            decoration: const InputDecoration(hintText: "Alert Title"),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: alertDetailsController,
            decoration: const InputDecoration(hintText: "Alert Details"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              await db.collection('alerts').add({
                'title': alertTitleController.text,
                'details': alertDetailsController.text
              });
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Alert Added"), backgroundColor: Colors.green),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  "Add Alert",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: db.collection('alerts').snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, int index) {
                    DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                    return ListTile(
                      title: Text(documentSnapshot['title']),
                      subtitle: Text(documentSnapshot['details']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              editAlertTitleController.text = documentSnapshot['title'];
                              editAlertDetailsController.text = documentSnapshot['details'];
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Edit Alert Details"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: editAlertTitleController,
                                          decoration: const InputDecoration(hintText: "Edit Alert Title"),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: editAlertDetailsController,
                                          decoration: const InputDecoration(hintText: "Edit Alert Details"),
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
                                          await db.collection('alerts').doc(documentSnapshot.id).update({
                                            'title': editAlertTitleController.text,
                                            'details': editAlertDetailsController.text
                                          });
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text("Alert Updated"),
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
                              db.collection('alerts').doc(documentSnapshot.id).delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Alert Deleted"), backgroundColor: Colors.red),
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
            },
          ),
        ],
      ),
    );
  }
}
