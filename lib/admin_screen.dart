import 'package:flutter/material.dart';
import 'admin_notification_screen.dart';
import 'admin_beaches_screen.dart';
import 'admin_alerts_screen.dart';
import 'admin_facility_screen.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Dashboard',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildCustomButton(
                    context,
                    icon: Icons.notifications,
                    text: 'Add Notification for Tourist',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminNotificationScreen(
                            onAddNotification: (String title, String message) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Notification Added: $title')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCustomButton(
                    context,
                    icon: Icons.beach_access,
                    text: 'Add Beaches',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminBeachesScreen(onAddBeach: (String name, String details) {  },),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCustomButton(
                    context,
                    icon: Icons.warning,
                    text: 'Add Alerts',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminAlertsScreen(onAddAlert: (String title, String details) {  },),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCustomButton(
                    context,
                    icon: Icons.add_box,
                    text: 'Add Facility',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminFacilityScreen(onAddFacility: (String title, String details) {  },),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required void Function()? onPressed,
      }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
