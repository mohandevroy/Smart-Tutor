import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:smart_tutor/screens/guardian/guardian_profile_screen.dart';
import 'package:smart_tutor/screens/tutor/tutor_profile_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>?> getUserData() async {
    final user = AuthService.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading user data: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found'));
          }

          final data = snapshot.data!;

          final name = data['name'] ?? 'No Name';
          final role = data['role'] ?? 'No Role';
          final email = data['email'] ?? 'No Email';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Role: $role'),
                const SizedBox(height: 8),
                Text('Email: $email'),
                const SizedBox(height: 20),
                if (role.toString().trim().toLowerCase() == 'guardian')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GuardianProfileScreen(),
                          ),
                        );
                      },
                      child: const Text('Complete Guardian Profile'),
                    ),
                  ),
                if (role.toString().trim().toLowerCase() == 'tutor')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TutorProfileScreen(),
                          ),
                        );
                      },
                      child: const Text('Complete Tutor Profile'),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await AuthService.logout();
                    },
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
