import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'student_nurse_home_screen.dart';
import 'home_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  final List<RoleOption> _roles = [
    RoleOption(
      code: 'sn',
      title: '학생간호사',
      subtitle: '간호학과 재학생',
      description: '간호사 국가고시를 준비하는 간호학과 학생',
      icon: Icons.school,
      color: Colors.blue,
    ),
    RoleOption(
      code: 'rn',
      title: '간호사',
      subtitle: '일반간호사',
      description: '병원이나 의료기관에서 근무하는 간호사',
      icon: Icons.local_hospital,
      color: Colors.green,
    ),
    RoleOption(
      code: 'np',
      title: '전문간호사',
      subtitle: '전문 분야 간호사',
      description: '특정 분야의 전문성을 갖춘 고급 간호사',
      icon: Icons.star,
      color: Colors.orange,
    ),
    RoleOption(
      code: 'physician',
      title: '의사',
      subtitle: '의료진',
      description: '의료기관에서 진료를 담당하는 의사',
      icon: Icons.medical_services,
      color: Colors.red,
    ),
    RoleOption(
      code: 'admin',
      title: '슈퍼 관리자',
      subtitle: 'Clintest 관리자',
      description: '시스템 관리 및 사용자 관리 권한을 가진 관리자',
      icon: Icons.admin_panel_settings,
      color: Colors.purple,
    ),
  ];


  Future<void> _completeRoleSelection() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('역할을 선택해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 역할 저장
    await StorageService.saveClintestSettings(
      role: _selectedRole,
      departments: [],
      interests: [],
    );

    // 역할 설정 완료 표시
    await StorageService.setBool('role_selection_completed', true);

    if (mounted) {
      // 선택한 역할에 따라 홈 화면으로 이동
      Widget homeScreen;
      if (_selectedRole == 'sn') {
        homeScreen = const StudentNurseHomeScreen();
      } else {
        homeScreen = const HomeScreen();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => homeScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // 제목
              Text(
                '당신의 역할을 선택해주세요',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '선택하신 역할에 맞는 맞춤형 학습 콘텐츠를 제공해드립니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // 역할 선택 카드들
              ...List.generate(_roles.length, (index) {
                final role = _roles[index];
                final isSelected = _selectedRole == role.code;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: isSelected ? 4 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? role.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedRole = role.code;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: role.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                role.icon,
                                color: role.color,
                                size: 30,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.title,
                                    style: AppTextStyles.heading3,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role.subtitle,
                                    style: AppTextStyles.subtitle2.copyWith(
                                      color: role.color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    role.description,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: role.color,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),


              const SizedBox(height: 40),

              // 완료 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _completeRoleSelection,
                  child: const Text(
                    '설정 완료',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleOption {
  final String code;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  const RoleOption({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}