import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/user_role.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  void _selectRole(BuildContext context, UserRole role) {
    // Navigate to appropriate dashboard based on role
    switch (role) {
      case UserRole.student:
        context.go('/student-dashboard');
        break;
      case UserRole.parent:
        context.go('/parent-dashboard');
        break;
      case UserRole.teacher:
        context.go('/teacher-dashboard');
        break;
      case UserRole.admin:
        context.go('/admin-dashboard');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('역할 선택'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            final maxWidth = isDesktop ? 800.0 : constraints.maxWidth;
            final padding = isDesktop ? 40.0 : 20.0;
            
            return Center(
              child: Container(
                width: maxWidth,
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.9,
                ),
                padding: EdgeInsets.all(padding),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header - 간소화
                      Text(
                        '역할을 선택하세요',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '각 역할에 따라 다른 기능을 사용할 수 있습니다',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Role cards - 컴팩트 디자인
                      ...UserRole.values.map((role) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CompactRoleCard(
                          role: role,
                          onTap: () => _selectRole(context, role),
                        ),
                      )),

                      const SizedBox(height: 20),
                      
                      // Back button
                      TextButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('뒤로 가기'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 컴팩트한 역할 선택 카드 (모바일&웹 최적화)
class _CompactRoleCard extends StatelessWidget {
  final UserRole role;
  final VoidCallback onTap;

  const _CompactRoleCard({
    required this.role,
    required this.onTap,
  });

  // 역할별 아이콘과 색상 매핑
  IconData get _icon {
    switch (role) {
      case UserRole.student:
        return Icons.school_outlined;
      case UserRole.parent:
        return Icons.family_restroom_outlined;
      case UserRole.teacher:
        return Icons.person_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  Color get _color {
    switch (role) {
      case UserRole.student:
        return Colors.blue;
      case UserRole.parent:
        return Colors.green;
      case UserRole.teacher:
        return Colors.orange;
      case UserRole.admin:
        return Colors.purple;
    }
  }

  String get _description {
    switch (role) {
      case UserRole.student:
        return '출석 체크, 단어 학습, 스피킹 연습';
      case UserRole.parent:
        return '자녀 학습 현황, 차량 위치 확인';
      case UserRole.teacher:
        return '출석 승인, 학생 관리, 진도 관리';
      case UserRole.admin:
        return '시스템 관리, 사용자 관리, 분석';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80, // 고정 높이로 오버플로우 방지
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _icon,
                    size: 24,
                    color: _color,
                  ),
                ),
                const SizedBox(width: 16),
                
                // 텍스트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        role.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // 화살표 아이콘
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}