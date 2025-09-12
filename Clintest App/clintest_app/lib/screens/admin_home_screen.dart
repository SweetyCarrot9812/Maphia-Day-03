import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/atlas_auth_service.dart';
import '../services/secure_storage_service.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clintest 관리자'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 관리자 정보 카드
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 60,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<String?>(
                      future: SecureStorageService.getUserName(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Hanoa 관리자',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String?>(
                      future: SecureStorageService.getUserEmail(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'hanoa01@gmail.com',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple),
                      ),
                      child: const Text(
                        '슈퍼 관리자',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 관리 메뉴
            const Text(
              '시스템 관리',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAdminCard(
                    title: '사용자 관리',
                    description: '사용자 계정 관리',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => _showComingSoon(context),
                  ),
                  _buildAdminCard(
                    title: '콘텐츠 관리',
                    description: '학습 콘텐츠 관리',
                    icon: Icons.content_paste,
                    color: Colors.green,
                    onTap: () => _showComingSoon(context),
                  ),
                  _buildAdminCard(
                    title: '시스템 통계',
                    description: '사용 통계 및 분석',
                    icon: Icons.analytics,
                    color: Colors.orange,
                    onTap: () => _showComingSoon(context),
                  ),
                  _buildAdminCard(
                    title: '설정 관리',
                    description: '시스템 설정',
                    icon: Icons.settings,
                    color: Colors.red,
                    onTap: () => _showComingSoon(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 현재 상태
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    '시스템 정상 작동',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('준비 중'),
        content: const Text('이 기능은 현재 개발 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final atlasAuthService = Provider.of<AtlasAuthService>(context, listen: false);
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말로 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await atlasAuthService.logout();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}