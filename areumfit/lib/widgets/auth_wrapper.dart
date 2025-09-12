import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AreumFit 로딩 중...'),
                ],
              ),
            ),
          );
        }

        // 로그인된 사용자가 있으면 HomeScreen (Mainboard)
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // 로그인되지 않았으면 LoginScreen
        return const LoginScreen();
      },
    );
  }
}