import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class TestHomeScreen extends StatelessWidget {
  const TestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AreumFit Auth Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              '🎉 Firebase Auth 테스트 성공!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '로그인된 사용자 정보:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('UID', user?.uid ?? 'Unknown'),
                    _buildInfoRow('이메일', user?.email ?? 'Unknown'),
                    _buildInfoRow('이름', user?.displayName ?? '설정되지 않음'),
                    _buildInfoRow('이메일 인증', user?.emailVerified == true ? '인증됨' : '미인증'),
                    _buildInfoRow('로그인 방법', _getProviderInfo(user)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService().signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getProviderInfo(User? user) {
    if (user == null) return 'Unknown';
    
    final providers = user.providerData.map((info) {
      switch (info.providerId) {
        case 'password':
          return '이메일/비밀번호';
        case 'google.com':
          return 'Google';
        case 'apple.com':
          return 'Apple';
        default:
          return info.providerId;
      }
    }).join(', ');
    
    return providers.isNotEmpty ? providers : '알 수 없음';
  }
}