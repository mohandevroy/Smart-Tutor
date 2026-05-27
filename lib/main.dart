import 'package:smart_tutor/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_tutor/firebase_options.dart';
import 'package:smart_tutor/screens/auth/login_screen.dart';
import 'package:smart_tutor/screens/common/role_router_screen.dart';
import 'package:smart_tutor/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  home: const AuthGate(),
);
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const RoleRouterScreen();
        }

        return const LoginScreen();
      },
    );
  }
}