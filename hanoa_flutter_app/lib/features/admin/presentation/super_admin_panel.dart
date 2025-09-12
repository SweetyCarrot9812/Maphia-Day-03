import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/utils/logger.dart';

/// 슈퍼 관리자 패널
/// 
/// Hanoa 생태계 전체를 관리하는 슈퍼 관리자 전용 패널
/// - 사용자 관리
/// - 프로젝트 관리
/// - 시스템 설정
/// - 분석 데이터 접근
class SuperAdminPanel extends ConsumerStatefulWidget {
  const SuperAdminPanel({super.key});

  @override
  ConsumerState<SuperAdminPanel> createState() => _SuperAdminPanelState();
}

class _SuperAdminPanelState extends ConsumerState<SuperAdminPanel>
    with SingleTickerProviderStateMixin {
  static final _logger = Loggers.admin;
  
  late TabController _tabController;
  bool _isLoading = true;
  bool _isSuperAdmin = false;
  List<Map<String, dynamic>> _adminList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkSuperAdminAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 슈퍼 관리자 권한 확인
  Future<void> _checkSuperAdminAccess() async {
    try {
      _isSuperAdmin = await AdminService.isSuperAdmin();
      
      if (_isSuperAdmin) {
        await _loadAdminList();
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _logger.error('권한 확인 오류', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 관리자 목록 로드
  Future<void> _loadAdminList() async {
    try {
      _adminList = await AdminService.getAllAdmins();
      setState(() {});
    } catch (e) {
      _logger.error('관리자 목록 로드 오류', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('접근 제한'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                '슈퍼 관리자 권한이 필요합니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hanoa 생태계 관리는 슈퍼 관리자만 접근 가능합니다.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Hanoa 슈퍼 관리자 패널'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: '사용자 관리'),
            Tab(icon: Icon(Icons.apps), text: '프로젝트'),
            Tab(icon: Icon(Icons.analytics), text: '분석'),
            Tab(icon: Icon(Icons.settings), text: '시스템'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserManagementTab(),
          _buildProjectManagementTab(),
          _buildAnalyticsTab(),
          _buildSystemSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAdminDialog,
        icon: const Icon(Icons.add),
        label: const Text('관리자 추가'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  /// 사용자 관리 탭
  Widget _buildUserManagementTab() {
    return RefreshIndicator(
      onRefresh: _loadAdminList,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildAdminList(),
        ],
      ),
    );
  }

  /// 통계 카드들
  Widget _buildStatsCards() {
    final superAdmins = _adminList.where((a) => a['adminLevel'] == AdminService.SUPER_ADMIN).length;
    final projectAdmins = _adminList.where((a) => a['adminLevel'] == AdminService.PROJECT_ADMIN).length;
    final totalAdmins = _adminList.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: '슈퍼 관리자',
            count: superAdmins,
            icon: Icons.admin_panel_settings,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: '프로젝트 관리자',
            count: projectAdmins,
            icon: Icons.manage_accounts,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: '전체 관리자',
            count: totalAdmins,
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  /// 통계 카드 위젯
  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 관리자 목록
  Widget _buildAdminList() {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '관리자 목록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _adminList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final admin = _adminList[index];
              return _buildAdminListItem(admin);
            },
          ),
        ],
      ),
    );
  }

  /// 관리자 리스트 아이템
  Widget _buildAdminListItem(Map<String, dynamic> admin) {
    final adminLevel = admin['adminLevel'] as int;
    final permissions = List<String>.from(admin['permissions'] ?? []);
    final managedProjects = List<String>.from(admin['managedProjects'] ?? []);
    
    String levelText;
    Color levelColor;
    IconData levelIcon;
    
    switch (adminLevel) {
      case AdminService.SUPER_ADMIN:
        levelText = '슈퍼 관리자';
        levelColor = Colors.red;
        levelIcon = Icons.admin_panel_settings;
        break;
      case AdminService.PROJECT_ADMIN:
        levelText = '프로젝트 관리자';
        levelColor = Colors.orange;
        levelIcon = Icons.manage_accounts;
        break;
      case AdminService.MODERATOR:
        levelText = '모더레이터';
        levelColor = Colors.blue;
        levelIcon = Icons.shield;
        break;
      default:
        levelText = '사용자';
        levelColor = Colors.grey;
        levelIcon = Icons.person;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: levelColor.withOpacity(0.1),
        child: Icon(levelIcon, color: levelColor),
      ),
      title: Text(admin['displayName'] ?? '이름 없음'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(admin['email'] ?? '이메일 없음'),
          const SizedBox(height: 4),
          Text(
            '관리 프로젝트: ${managedProjects.join(', ')}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              levelText,
              style: TextStyle(
                color: levelColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            admin['status'] == 'active' ? '활성' : '비활성',
            style: TextStyle(
              fontSize: 10,
              color: admin['status'] == 'active' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      onTap: () => _showAdminDetailsDialog(admin),
    );
  }

  /// 프로젝트 관리 탭
  Widget _buildProjectManagementTab() {
    final projects = [
      {'id': 'clintest', 'name': 'Clintest', 'description': '의료 학습 플랫폼', 'status': 'active'},
      {'id': 'lingumo', 'name': 'Lingumo', 'description': '언어 학습 플랫폼', 'status': 'active'},
      {'id': 'areumfit', 'name': 'AreumFit', 'description': '피트니스 플랫폼', 'status': 'active'},
      {'id': 'haneultone', 'name': 'HaneulTone', 'description': '보컬 트레이닝 플랫폼', 'status': 'development'},
      {'id': 'hanoa_hub', 'name': 'Hanoa Hub', 'description': '통합 허브', 'status': 'active'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Hanoa 생태계 프로젝트',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...projects.map((project) => Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: project['status'] == 'active' ? Colors.green : Colors.orange,
              child: const Icon(Icons.apps, color: Colors.white),
            ),
            title: Text(project['name']!),
            subtitle: Text(project['description']!),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: project['status'] == 'active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                project['status'] == 'active' ? '운영중' : '개발중',
                style: TextStyle(
                  color: project['status'] == 'active' ? Colors.green : Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }

  /// 분석 탭
  Widget _buildAnalyticsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '분석 대시보드',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '사용자 통계, 앱 사용량 등의 분석 데이터를\n여기에 표시할 예정입니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 시스템 설정 탭
  Widget _buildSystemSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '시스템 설정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('데이터 백업'),
                subtitle: const Text('시스템 데이터 백업 관리'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 데이터 백업 기능
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('보안 설정'),
                subtitle: const Text('보안 정책 및 인증 설정'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 보안 설정 기능
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('알림 설정'),
                subtitle: const Text('시스템 알림 및 경고 설정'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 알림 설정 기능
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 관리자 생성 다이얼로그
  void _showCreateAdminDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 관리자 추가'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('새로운 관리자 계정을 생성하려면\n사용자가 먼저 로그인해야 합니다.'),
            SizedBox(height: 16),
            Text(
              '참고: 슈퍼 관리자 이메일은 코드에서\n미리 정의된 계정만 자동 승격됩니다.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 관리자 추가 기능 구현
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 관리자 상세 정보 다이얼로그
  void _showAdminDetailsDialog(Map<String, dynamic> admin) {
    final permissions = List<String>.from(admin['permissions'] ?? []);
    final managedProjects = List<String>.from(admin['managedProjects'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(admin['displayName'] ?? '관리자 정보'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('이메일', admin['email']),
              _buildDetailRow('권한 레벨', admin['adminLevel'].toString()),
              _buildDetailRow('상태', admin['status']),
              const SizedBox(height: 16),
              const Text('권한:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...permissions.map((p) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('• $p'),
              )).toList(),
              const SizedBox(height: 16),
              const Text('관리 프로젝트:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...managedProjects.map((p) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('• $p'),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          if (admin['adminLevel'] != AdminService.SUPER_ADMIN)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditAdminDialog(admin);
              },
              child: const Text('편집'),
            ),
        ],
      ),
    );
  }

  /// 상세 정보 행
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// 관리자 편집 다이얼로그
  void _showEditAdminDialog(Map<String, dynamic> admin) {
    // TODO: 관리자 편집 기능 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('관리자 편집'),
        content: const Text('관리자 편집 기능은 향후 구현 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}