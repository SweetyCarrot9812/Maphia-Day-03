import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../utils/responsive_utils.dart';

/// 앱 설정 화면
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  String _selectedLanguage = 'ko';
  String _weightUnit = 'kg';
  int _reminderHour = 19; // 7 PM
  int _reminderMinute = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        foldableExpanded: _buildTabletLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      children: [
        _buildGeneralSection(),
        const SizedBox(height: 16),
        _buildWorkoutSection(),
        const SizedBox(height: 16),
        _buildNotificationSection(),
        const SizedBox(height: 16),
        _buildDataSection(),
        const SizedBox(height: 16),
        _buildAboutSection(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left panel - General and workout settings
        Expanded(
          flex: 1,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildGeneralSection(),
              const SizedBox(height: 16),
              _buildWorkoutSection(),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right panel - Notifications, data and about
        Expanded(
          flex: 1,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildNotificationSection(),
              const SizedBox(height: 16),
              _buildDataSection(),
              const SizedBox(height: 16),
              _buildAboutSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSection() {
    return _buildSection(
      title: '일반',
      icon: Icons.settings,
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode,
          title: '다크 모드',
          subtitle: '어두운 테마 사용',
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
            // TODO: 실제 테마 변경 구현
            _showFeatureComingSoon();
          },
        ),
        _buildDropdownTile(
          icon: Icons.language,
          title: '언어',
          subtitle: '앱 언어 설정',
          value: _selectedLanguage,
          items: const [
            DropdownMenuItem(value: 'ko', child: Text('한국어')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
              // TODO: 실제 언어 변경 구현
              _showFeatureComingSoon();
            }
          },
        ),
        _buildDropdownTile(
          icon: Icons.monitor_weight,
          title: '중량 단위',
          subtitle: '운동 중량 표시 단위',
          value: _weightUnit,
          items: const [
            DropdownMenuItem(value: 'kg', child: Text('킬로그램 (kg)')),
            DropdownMenuItem(value: 'lbs', child: Text('파운드 (lbs)')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _weightUnit = value;
              });
              // TODO: 실제 단위 변경 구현
              _showFeatureComingSoon();
            }
          },
        ),
      ],
    );
  }

  Widget _buildWorkoutSection() {
    return _buildSection(
      title: '운동',
      icon: Icons.fitness_center,
      children: [
        _buildSwitchTile(
          icon: Icons.volume_up,
          title: '운동 중 소리',
          subtitle: '타이머와 알림음 활성화',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          icon: Icons.vibration,
          title: '햅틱 피드백',
          subtitle: '터치 시 진동 피드백',
          value: _hapticEnabled,
          onChanged: (value) {
            setState(() {
              _hapticEnabled = value;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: const Text('기본 휴식 시간'),
          subtitle: const Text('세트 간 기본 휴식 시간 설정'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showRestTimeDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('운동 데이터 백업'),
          subtitle: const Text('로컬 데이터를 클라우드에 백업'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _performBackup(),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: '알림',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_active,
          title: '푸시 알림',
          subtitle: '운동 리마인더와 알림 받기',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        if (_notificationsEnabled) ...[
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('운동 리마인더'),
            subtitle: Text('매일 ${_formatTime(_reminderHour, _reminderMinute)}에 알림'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReminderTimeDialog(),
          ),
          _buildSwitchTile(
            icon: Icons.celebration,
            title: 'PR 달성 알림',
            subtitle: '개인 기록 달성 시 축하 알림',
            value: true,
            onChanged: (value) {
              // TODO: PR 알림 설정 구현
              _showFeatureComingSoon();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: '데이터',
      icon: Icons.storage,
      children: [
        _buildSwitchTile(
          icon: Icons.sync,
          title: '자동 동기화',
          subtitle: 'Wi-Fi 연결 시 자동으로 데이터 동기화',
          value: _autoSyncEnabled,
          onChanged: (value) {
            setState(() {
              _autoSyncEnabled = value;
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.cloud_sync),
          title: const Text('수동 동기화'),
          subtitle: const Text('지금 데이터 동기화 실행'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _performManualSync(),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('데이터 내보내기'),
          subtitle: const Text('운동 기록을 CSV 파일로 저장'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _exportData(),
        ),
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.red[700]),
          title: Text('모든 데이터 삭제', style: TextStyle(color: Colors.red[700])),
          subtitle: const Text('복구할 수 없습니다'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDeleteAllDataDialog(),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: '정보',
      icon: Icons.info,
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('앱 버전'),
          subtitle: const Text('AreumFit v1.0.0'),
          trailing: const Text('최신 버전'),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('도움말'),
          subtitle: const Text('사용법과 FAQ 확인'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showFeatureComingSoon(),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('개인정보 처리방침'),
          subtitle: const Text('개인정보 보호 정책'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showFeatureComingSoon(),
        ),
        ListTile(
          leading: const Icon(Icons.gavel),
          title: const Text('서비스 약관'),
          subtitle: const Text('이용약관 및 서비스 정책'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showFeatureComingSoon(),
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('피드백 보내기'),
          subtitle: const Text('개선사항이나 버그 신고'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _sendFeedback(),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile<T>({
    required IconData icon,
    required String title,
    required String subtitle,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showReminderTimeDialog() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
    );

    if (time != null) {
      setState(() {
        _reminderHour = time.hour;
        _reminderMinute = time.minute;
      });
      // TODO: 실제 리마인더 설정 구현
      _showFeatureComingSoon();
    }
  }

  void _showRestTimeDialog() {
    // TODO: 휴식 시간 설정 다이얼로그 구현
    _showFeatureComingSoon();
  }

  void _performBackup() {
    // TODO: 백업 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('백업을 시작합니다...')),
    );
  }

  void _performManualSync() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('동기화를 시작합니다...')),
    );

    try {
      // TODO: 실제 사용자 ID 사용
      await context.read<SyncProvider>().performSync('user-1');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('동기화가 완료되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동기화 실패: $e')),
        );
      }
    }
  }

  void _exportData() {
    // TODO: 데이터 내보내기 기능 구현
    _showFeatureComingSoon();
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 데이터 삭제'),
        content: const Text(
          '정말로 모든 운동 데이터를 삭제하시겠습니까?\n\n'
          '이 작업은 되돌릴 수 없으며, 모든 운동 기록, 개인 기록, '
          '설정이 영구적으로 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _deleteAllData() {
    // TODO: 모든 데이터 삭제 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('데이터 삭제 기능 (개발 예정)')),
    );
  }

  void _sendFeedback() {
    // TODO: 피드백 전송 기능 구현
    _showFeatureComingSoon();
  }

  void _showFeatureComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('곧 출시될 기능입니다')),
    );
  }
}