import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 64, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              '채팅 화면',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'AI 코치와의 채팅 기능 구현 예정',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}