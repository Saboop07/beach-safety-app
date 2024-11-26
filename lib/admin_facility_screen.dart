import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminFacilityScreen extends StatefulWidget {
  const AdminFacilityScreen({super.key, required this.onAddFacility});

  final Function(String title, String details) onAddFacility;

  @override
  State<AdminFacilityScreen> createState() => _AdminFacilityScreenState();
}

class _AdminFacilityScreenState extends State<AdminFacilityScreen> {
  TextEditingController beachNameController = TextEditingController();
  TextEditingController dogAllowedController = TextEditingController();
  TextEditingController ridesAvailableController = TextEditingController();
  TextEditingController parkingAllowedController = TextEditingController();
  TextEditingController toiletsAvailableController = TextEditingController();
  TextEditingController editBeachNameController = TextEditingController();
  TextEditingController editDogAllowedController = TextEditingController();
  TextEditingController editRidesAvailableController = TextEditingController();
  TextEditingController editParkingAllowedController = TextEditingController();
  TextEditingController editToiletsAvailableController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  bool dogAllowed = false;
  bool ridesAvailable = false;
  bool parkingAllowed = false;
  bool toiletsAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_parking, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Add Beach Facility Details",
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
          Row(
            children: [
              const Icon(Icons.pets, color: Colors.blue),  // Dog Allowed icon
              const SizedBox(width: 8),
              const Text("Dog Allowed: "),
              Switch(
                value: dogAllowed,
                onChanged: (value) {
                  setState(() {
                    dogAllowed = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.directions_bike, color: Colors.orange),  // Rides Available icon
              const SizedBox(width: 8),
              const Text("Rides Available: "),
              Switch(
                value: ridesAvailable,
                onChanged: (value) {
                  setState(() {
                    ridesAvailable = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.local_parking, color: Colors.green),  // Parking Allowed icon
              const SizedBox(width: 8),
              const Text("Parking Allowed: "),
              Switch(
                value: parkingAllowed,
                onChanged: (value) {
                  setState(() {
                    parkingAllowed = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.wc, color: Colors.blueGrey),  // Toilets Available icon
              const SizedBox(width: 8),
              const Text("Toilets Available: "),
              Switch(
                value: toiletsAvailable,
                onChanged: (value) {
                  setState(() {
                    toiletsAvailable = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async {
              await db.collection('facility').add({
                'beach_name': beachNameController.text,
                'dog_allowed': dogAllowed,
                'rides_available': ridesAvailable,
                'parking_allowed': parkingAllowed,
                'toilets_available': toiletsAvailable,
              });
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Facility Added"), backgroundColor: Colors.green),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle_outline, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  "Add Facility",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: db.collection('facility').snapshots(),
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
                        title: Text(documentSnapshot['beach_name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.pets, color: Colors.blue),  // Dog Allowed icon
                                const SizedBox(width: 8),
                                Text("Dog Allowed: ${documentSnapshot['dog_allowed'] ? 'Yes' : 'No'}"),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.directions_bike, color: Colors.orange),  // Rides Available icon
                                const SizedBox(width: 8),
                                Text("Rides Available: ${documentSnapshot['rides_available'] ? 'Yes' : 'No'}"),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.local_parking, color: Colors.green),  // Parking Allowed icon
                                const SizedBox(width: 8),
                                Text("Parking Allowed: ${documentSnapshot['parking_allowed'] ? 'Yes' : 'No'}"),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.wc, color: Colors.blueGrey),  // Toilets Available icon
                                const SizedBox(width: 8),
                                Text("Toilets Available: ${documentSnapshot['toilets_available'] ? 'Yes' : 'No'}"),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                editBeachNameController.text = documentSnapshot['beach_name'];
                                editDogAllowedController.text = documentSnapshot['dog_allowed'].toString();
                                editRidesAvailableController.text = documentSnapshot['rides_available'].toString();
                                editParkingAllowedController.text = documentSnapshot['parking_allowed'].toString();
                                editToiletsAvailableController.text = documentSnapshot['toilets_available'].toString();

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Edit Facility Details"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: editBeachNameController,
                                            decoration: const InputDecoration(hintText: "Edit Beach Name"),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Text("Dog Allowed: "),
                                              Switch(
                                                value: editDogAllowedController.text == 'true',
                                                onChanged: (value) {
                                                  setState(() {
                                                    editDogAllowedController.text = value.toString();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Rides Available: "),
                                              Switch(
                                                value: editRidesAvailableController.text == 'true',
                                                onChanged: (value) {
                                                  setState(() {
                                                    editRidesAvailableController.text = value.toString();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Parking Allowed: "),
                                              Switch(
                                                value: editParkingAllowedController.text == 'true',
                                                onChanged: (value) {
                                                  setState(() {
                                                    editParkingAllowedController.text = value.toString();
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Toilets Available: "),
                                              Switch(
                                                value: editToiletsAvailableController.text == 'true',
                                                onChanged: (value) {
                                                  setState(() {
                                                    editToiletsAvailableController.text = value.toString();
                                                  });
                                                },
                                              ),
                                            ],
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
                                            await db.collection('facility').doc(documentSnapshot.id).update({
                                              'beach_name': editBeachNameController.text,
                                              'dog_allowed': editDogAllowedController.text == 'true',
                                              'rides_available': editRidesAvailableController.text == 'true',
                                              'parking_allowed': editParkingAllowedController.text == 'true',
                                              'toilets_available': editToiletsAvailableController.text == 'true',
                                            });
                                            Navigator.pop(context);
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
                                db.collection('facility').doc(documentSnapshot.id).delete();
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
