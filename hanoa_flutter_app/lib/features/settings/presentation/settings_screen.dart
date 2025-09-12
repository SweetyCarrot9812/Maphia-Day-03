import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/app_state_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/admin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 설정 화면 - MVP: 동기화 스위치만 제공 (실제 기능 없음)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: AppTheme.textSecondaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // 데이터 동기화 섹션
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '데이터 동기화',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  
                  // 서버 동기화 스위치 (MVP: UI만)
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_sync_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: const Text(
                      '서버 동기화',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      settings.syncEnabled 
                        ? '학습 데이터를 서버와 동기화합니다'
                        : '로컬 저장만 사용합니다 (MVP 모드)',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Switch(
                      value: settings.syncEnabled,
                      onChanged: settings.syncEnabled 
                        ? null // MVP에서는 켜진 상태에서 끌 수 없음
                        : (value) {
                            // MVP 안내 메시지 표시
                            _showMvpNotice(context);
                          },
                      activeColor: AppTheme.primaryColor,
                      inactiveThumbColor: AppTheme.textSecondaryColor,
                    ),
                  ),
                  
                  // 자동 백업 스위치 (MVP: UI만)
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.backup_outlined,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    title: const Text(
                      '자동 백업',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '주기적으로 데이터를 백업합니다 (서버 동기화 필요)',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Switch(
                      value: false, // MVP에서는 항상 비활성화
                      onChanged: null, // MVP에서는 조작 불가
                      inactiveThumbColor: AppTheme.textSecondaryColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            // 알림 설정 섹션
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '알림 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  
                  // 변경 알림 스위치
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    title: const Text(
                      '변경 알림',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      settings.notificationsEnabled
                        ? '데이터 변경 제안을 알려드립니다'
                        : '변경 알림을 받지 않습니다',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleNotifications();
                      },
                      activeColor: AppTheme.errorColor,
                      inactiveThumbColor: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // 앱 정보 섹션
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '앱 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  
                  // 버전 정보
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: const Text(
                      '앱 버전',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Hanoa MVP v1.0.0',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  // 데이터베이스 상태
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.storage_outlined,
                        color: AppTheme.successColor,
                      ),
                    ),
                    title: const Text(
                      '데이터베이스',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '로컬 Isar DB - 정상 작동',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 기타 설정 섹션
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '기타',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  
                  // 변경 알림 화면으로 이동
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pending_actions_outlined,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    title: const Text(
                      '변경 알림 관리',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '대기 중인 변경 제안을 확인하고 관리합니다',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondaryColor,
                    ),
                    onTap: () => context.go('/pending-changes'),
                  ),
                  
                  // 관리자 패널 (로그인된 사용자만 표시)
                  FutureBuilder<bool>(
                    future: _checkAdminAccess(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      
                      if (!snapshot.hasData || !snapshot.data!) {
                        return const SizedBox.shrink();
                      }
                      
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: const Text(
                          '관리자 패널',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Hanoa 생태계 관리 (관리자만 접근 가능)',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppTheme.textSecondaryColor,
                        ),
                        onTap: () => context.go('/admin'),
                      );
                    },
                  ),
                  
                  // 초기화 (위험)
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    title: const Text(
                      '모든 데이터 초기화',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    subtitle: Text(
                      '모든 학습 데이터를 삭제합니다 (복구 불가)',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.warning_outlined,
                      color: AppTheme.errorColor,
                    ),
                    onTap: () => _showResetConfirmation(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 하단 정보
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology_rounded,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hanoa MVP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '로컬 우선 의료 학습 도우미\n현재는 MVP 버전으로 기본 기능만 제공됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 관리자 접근 권한 확인
  Future<bool> _checkAdminAccess() async {
    try {
      // 로그인 상태 확인
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      
      // 관리자 권한 확인
      return await AdminService.isAdmin();
    } catch (e) {
      return false;
    }
  }

  void _showMvpNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('MVP 버전 안내'),
          ],
        ),
        content: const Text(
          'Hanoa MVP에서는 서버 동기화 기능이 준비 중입니다.\n\n현재 버전에서는 로컬 저장만 지원하며, 향후 업데이트에서 클라우드 동기화 기능을 제공할 예정입니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: AppTheme.errorColor,
            ),
            SizedBox(width: 8),
            Text('데이터 초기화'),
          ],
        ),
        content: const Text(
          '정말로 모든 데이터를 초기화하시겠습니까?\n\n• 모든 개념과 문제가 삭제됩니다\n• 변경 알림 기록도 삭제됩니다\n• 이 작업은 되돌릴 수 없습니다\n\nMVP 버전에서는 백업이 없으므로 신중히 결정해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // MVP에서는 실제 초기화 기능 없음
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('MVP 버전에서는 초기화 기능이 비활성화되어 있습니다'),
                  backgroundColor: AppTheme.warningColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}