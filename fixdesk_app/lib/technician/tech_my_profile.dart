import 'package:flutter/material.dart';

class TechMyProfile extends StatelessWidget {
  final Map<String, dynamic> userData;

  const TechMyProfile({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 20),

            Text(
              "${userData['us_first_name_th']} ${userData['us_last_name_th']}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              userData['us_email'] ?? "",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}