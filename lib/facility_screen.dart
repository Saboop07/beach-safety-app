import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FacilityScreen extends StatelessWidget {
  const FacilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Facilities'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('facility').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No facility data available'));
          }

          final facilities = snapshot.data!.docs.map((doc) {
            return {
              'beach_name': doc['beach_name']?.toString() ?? 'Beach Name not available',
              'dog_allowed': doc['dog_allowed'] is bool ? doc['dog_allowed'] : false,
              'rides_available': doc['rides_available'] is bool ? doc['rides_available'] : false,
              'parking_allowed': doc['parking_allowed'] is bool ? doc['parking_allowed'] : false,
              'toilets_available': doc['toilets_available'] is bool ? doc['toilets_available'] : false,
            };
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: facilities.length,
            itemBuilder: (context, index) {
              final facility = facilities[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(facility['beach_name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pets, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text('Dog Allowed: ${facility['dog_allowed'] ? 'Yes' : 'No'}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.directions_bike, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text('Rides Available: ${facility['rides_available'] ? 'Yes' : 'No'}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.local_parking, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('Parking Allowed: ${facility['parking_allowed'] ? 'Yes' : 'No'}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.wc, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          Text('Toilets Available: ${facility['toilets_available'] ? 'Yes' : 'No'}'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
