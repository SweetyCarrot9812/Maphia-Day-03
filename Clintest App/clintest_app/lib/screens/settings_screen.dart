import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../models/country.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CountryCode _selectedCountry = CountryCode.KR;
  LabelLocale _selectedLocale = LabelLocale.ko;
  String _selectedRole = 'sn';
  List<String> _selectedDepartments = [];
  List<String> _selectedInterests = [];

  final List<String> _availableRoles = [
    'sn',   // Student Nurse
    'rn',   // Registered Nurse
    'np',   // Nurse Practitioner
    'physician'
  ];

  final Map<String, String> _roleNames = {
    'sn': '학생간호사',
    'rn': '간호사',
    'np': '전문간호사',
    'physician': '의사',
  };

  final List<String> _availableDepartments = [
    '내과', '외과', '소아과', '산부인과', '정형외과', 
    '신경과', '정신과', '응급의학과', '마취통증의학과', '영상의학과',
    'ICU', 'ER', '수술실', '병동', '외래'
  ];

  final List<String> _availableInterests = [
    '심혈관계', '호흡기계', '소화기계', '비뇨기계', '내분비계',
    '신경계', '근골격계', '피부계', '감염관리', '응급처치',
    '수술간호', '중환자간호', '소아간호', '모성간호', '정신간호',
    '지역사회간호', '간호관리', '간호교육', '간호연구'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _selectedCountry = CountryCode.fromCode(
        StorageService.clintestCountryOfPractice ?? 'KR'
      );
      _selectedLocale = LabelLocale.fromCode(
        StorageService.clintestLabelLocale ?? 'ko'
      );
      _selectedRole = StorageService.clintestRole ?? 'sn';
      _selectedDepartments = StorageService.clintestDepartments;
      _selectedInterests = StorageService.clintestInterests;
    });
  }

  Future<void> _saveSettings() async {
    await StorageService.saveClintestSettings(
      countryOfPractice: _selectedCountry.code,
      labelLocale: _selectedLocale.code,
      role: _selectedRole,
      departments: _selectedDepartments,
      interests: _selectedInterests,
      enableAIParsing: true,  // GPT-5 Standard가 자동 처리
      enableAutoTagging: true,  // GPT-5 Standard가 자동 처리
      autoTaggingThreshold: 0.85,  // GPT-5 Standard 최적값
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정이 저장되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clintest 설정'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        // 저장 버튼 제거 - AI 자동화 모드
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 로그인 정보 섹션
                _buildSectionCard(
                  title: '로그인 정보',
                  icon: Icons.person,
                  children: [
                    _buildUserInfo(authService),
                  ],
                ),

                const SizedBox(height: 16),

                // AI 자동 최적화 섹션
                _buildSectionCard(
                  title: 'AI 자동 최적화',
                  icon: Icons.auto_awesome,
                  children: [
                    _buildAIAutomationInfo(),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(AuthService authService) {
    final user = authService.currentUser;
    final isLoggedIn = authService.isLoggedIn;

    if (!isLoggedIn || user == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '로그인이 필요합니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 프로필 사진 & 기본 정보
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
              child: user.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 30,
                    color: AppTheme.primaryColor,
                  )
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? user.email?.split('@').first ?? '사용자',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '이메일 없음',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 계정 정보
        _buildInfoRow(
          icon: Icons.email_outlined,
          label: '이메일',
          value: user.email ?? '없음',
        ),

        _buildInfoRow(
          icon: Icons.verified_user_outlined,
          label: '이메일 인증',
          value: user.emailVerified ? '인증됨' : '미인증',
          valueColor: user.emailVerified ? Colors.green : Colors.orange,
        ),

        _buildInfoRow(
          icon: Icons.access_time,
          label: '생성일',
          value: user.metadata.creationTime != null
            ? _formatDateTime(user.metadata.creationTime!)
            : '알 수 없음',
        ),

        _buildInfoRow(
          icon: Icons.login,
          label: '마지막 로그인',
          value: user.metadata.lastSignInTime != null
            ? _formatDateTime(user.metadata.lastSignInTime!)
            : '알 수 없음',
        ),

        _buildInfoRow(
          icon: Icons.fingerprint,
          label: '사용자 ID',
          value: user.uid,
          isMonospace: true,
        ),

        const SizedBox(height: 24),

        // 로그아웃 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authService.isLoading ? null : () => _handleLogout(authService),
            icon: authService.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
            label: Text(authService.isLoading ? '로그아웃 중...' : '로그아웃'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMonospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  Future<void> _handleLogout(AuthService authService) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final success = await authService.logout();

      if (success && mounted) {
        // 로그아웃 성공 시 로그인 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error ?? '로그아웃에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('활동 국가', style: AppTextStyles.subtitle1),
        const SizedBox(height: 8),
        DropdownButtonFormField<CountryCode>(
          initialValue: _selectedCountry,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.flag),
          ),
          items: CountryCode.values.map((country) {
            return DropdownMenuItem(
              value: country,
              child: Text(country.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCountry = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocaleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('의료 용어 언어', style: AppTextStyles.subtitle1),
        const SizedBox(height: 8),
        DropdownButtonFormField<LabelLocale>(
          initialValue: _selectedLocale,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.translate),
          ),
          items: LabelLocale.values.map((locale) {
            return DropdownMenuItem(
              value: locale,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(locale.displayName),
                  Text(
                    locale.description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLocale = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('직책', style: AppTextStyles.subtitle1),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedRole,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.badge),
          ),
          items: _availableRoles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(_roleNames[role] ?? role),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedRole = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDepartmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('근무 부서 (다중 선택 가능)', style: AppTextStyles.subtitle1),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableDepartments.map((dept) {
            final isSelected = _selectedDepartments.contains(dept);
            return FilterChip(
              label: Text(dept),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDepartments.add(dept);
                  } else {
                    _selectedDepartments.remove(dept);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('관심 분야 (다중 선택 가능)', style: AppTextStyles.subtitle1),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
              selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.secondaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAIAutomationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'GPT-5 Standard 자동 최적화',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          const Text(
            'AI 기능이 자동으로 최적화되어 제공됩니다:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildFeatureItem(
            icon: Icons.auto_fix_high,
            title: '스마트 문제 분석',
            description: '난이도별 자동 분류 및 맞춤형 학습',
          ),
          _buildFeatureItem(
            icon: Icons.psychology,
            title: '지능형 학습 최적화',
            description: '개인별 학습 패턴 분석 및 추천',
          ),
          _buildFeatureItem(
            icon: Icons.tag,
            title: '자동 태깅 시스템',
            description: '85% 신뢰도로 정확한 태그 자동 생성',
          ),
          _buildFeatureItem(
            icon: Icons.analytics,
            title: '실시간 성과 분석',
            description: '학습 진도와 이해도 자동 추적',
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '별도 설정 없이 최고 성능으로 동작합니다',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}