import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the left
          children: [
            Text(
              'Get in Touch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'If you have any questions, feedback, or need assistance, feel free to reach out to us. We are here to help you!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Email: co.2021.aschiddarwar@bitwardha.ac.in',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Alternate Email: co.2021.prsaboo@bitwardha.ac.in',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Alternate Email: co.2021.ssgaikwad@bitwardha.ac.in',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Phone: +91 8432170897',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
