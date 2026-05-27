import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/services/auth_service.dart';
import 'package:smart_tutor/screens/tutor/tutor_dashboard_screen.dart';
import 'package:smart_tutor/screens/guardian/guardian_dashboard_screen.dart';
import 'package:smart_tutor/screens/admin/admin_dashboard_screen.dart';

class RoleRouterScreen extends StatelessWidget {
  const RoleRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final rawRole = (data['role'] ?? '').toString().trim().toLowerCase();
        if (rawRole == 'admin') {
          return const AdminDashboardScreen();
        }

        if (rawRole == 'tutor') {
          return const TutorDashboardScreen();
        }

        if (rawRole == 'guardian' || rawRole == 'parent') {
          return const GuardianDashboardScreen();
        }

        return Scaffold(
          body: Center(
            child: Text('Invalid role: $rawRole'),
          ),
        );
      },
    );
  }
}
