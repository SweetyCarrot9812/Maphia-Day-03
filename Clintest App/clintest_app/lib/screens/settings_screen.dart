import 'package:flutter/material.dart';

import '../services/storage_service.dart';
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
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              SizedBox(height: 24),
              Text(
                'AI 자동 최적화',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Clintest는 AI 기반으로\n사용자의 학습 패턴을 자동으로 분석하여\n최적화된 학습 환경을 제공합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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