import 'package:flutter/material.dart';

/// 회원가입 화면 (임시)
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: const Center(
        child: Text('회원가입 화면 (개발 예정)'),
      ),
    );
  }
}