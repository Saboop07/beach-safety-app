import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('alerts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No alerts available'));
          }

          final alerts = snapshot.data!.docs.map((doc) {
            return {
              'title': doc['title'] ?? 'No Title',  // Default value if 'title' is missing
              'details': doc['details'] ?? 'No Details available',  // Default value if 'details' is missing
            };
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(alert['title']),
                  subtitle: Text(alert['details']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
