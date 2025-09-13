import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Mock user data provider
final usersProvider = StateProvider<List<Map<String, dynamic>>>((ref) => [
  {
    'id': '1',
    'email': 'doctor1@hanoa.com',
    'name': '김의사',
    'app': 'Clintest',
    'role': 'doctor',
    'status': 'active',
    'joinDate': DateTime(2024, 1, 15),
    'lastActive': DateTime.now().subtract(const Duration(hours: 2)),
  },
  {
    'id': '2', 
    'email': 'nurse1@hanoa.com',
    'name': '박간호사',
    'app': 'Clintest',
    'role': 'nurse',
    'status': 'active',
    'joinDate': DateTime(2024, 2, 3),
    'lastActive': DateTime.now().subtract(const Duration(minutes: 30)),
  },
  {
    'id': '3',
    'email': 'student1@hanoa.com',
    'name': '이학생',
    'app': 'Lingumo',
    'role': 'student',
    'status': 'active',
    'joinDate': DateTime(2024, 3, 10),
    'lastActive': DateTime.now().subtract(const Duration(hours: 5)),
  },
  {
    'id': '4',
    'email': 'trainer1@hanoa.com',
    'name': '정트레이너',
    'app': 'AreumFit',
    'role': 'trainer',
    'status': 'inactive',
    'joinDate': DateTime(2024, 2, 20),
    'lastActive': DateTime.now().subtract(const Duration(days: 7)),
  },
  {
    'id': '5',
    'email': 'singer1@hanoa.com',
    'name': '최성악가',
    'app': 'HaneulTone',
    'role': 'artist',
    'status': 'banned',
    'joinDate': DateTime(2024, 1, 8),
    'lastActive': DateTime.now().subtract(const Duration(days: 30)),
  },
]);

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _selectedApp = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredUsers {
    final users = ref.watch(usersProvider);
    
    return users.where((user) {
      final matchesApp = _selectedApp == 'All' || user['app'] == _selectedApp;
      final matchesStatus = _selectedStatus == 'All' || user['status'] == _selectedStatus;
      final matchesSearch = _searchQuery.isEmpty ||
          user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesApp && matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUserList = filteredUsers;
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '회원 관리',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '전체 ${filteredUserList.length}명',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('새 사용자 추가'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filters and search
            Row(
              children: [
                // App filter
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _selectedApp,
                    decoration: const InputDecoration(
                      labelText: '앱 필터',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Clintest', 'Lingumo', 'AreumFit', 'HaneulTone']
                        .map((app) => DropdownMenuItem(
                              value: app,
                              child: Text(app == 'All' ? '전체' : app),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedApp = value ?? 'All';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Status filter
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: '상태 필터',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'active', 'inactive', 'banned']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(_getStatusText(status)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? 'All';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Search
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: '사용자 검색',
                      hintText: '이름 또는 이메일로 검색',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Users table
            Expanded(
              child: Card(
                elevation: 2,
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 40), // Avatar space
                          Expanded(flex: 2, child: Text('사용자', style: TextStyle(fontWeight: FontWeight.w600))),
                          Expanded(flex: 1, child: Text('앱', style: TextStyle(fontWeight: FontWeight.w600))),
                          Expanded(flex: 1, child: Text('역할', style: TextStyle(fontWeight: FontWeight.w600))),
                          Expanded(flex: 1, child: Text('상태', style: TextStyle(fontWeight: FontWeight.w600))),
                          Expanded(flex: 1, child: Text('가입일', style: TextStyle(fontWeight: FontWeight.w600))),
                          Expanded(flex: 1, child: Text('마지막 활동', style: TextStyle(fontWeight: FontWeight.w600))),
                          SizedBox(width: 100), // Actions space
                        ],
                      ),
                    ),
                    
                    // Table rows
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredUserList.length,
                        itemBuilder: (context, index) {
                          final user = filteredUserList[index];
                          return _buildUserRow(user, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user, int index) {
    final isEven = index % 2 == 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: _getAppColor(user['app']),
            child: Text(
              user['name'][0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user['email'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // App
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getAppColor(user['app']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user['app'],
                style: TextStyle(
                  color: _getAppColor(user['app']),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Role
          Expanded(
            flex: 1,
            child: Text(
              _getRoleText(user['role']),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(user['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(user['status']),
                style: TextStyle(
                  color: _getStatusColor(user['status']),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Join date
          Expanded(
            flex: 1,
            child: Text(
              DateFormat('yy.MM.dd').format(user['joinDate']),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Last active
          Expanded(
            flex: 1,
            child: Text(
              _formatLastActive(user['lastActive']),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showEditUserDialog(context, user),
                  tooltip: '수정',
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'block',
                      child: Text(user['status'] == 'banned' ? '차단 해제' : '차단'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('삭제'),
                    ),
                  ],
                  onSelected: (value) => _handleUserAction(user, value as String),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAppColor(String app) {
    switch (app) {
      case 'Clintest':
        return Colors.blue.shade600;
      case 'Lingumo':
        return Colors.green.shade600;
      case 'AreumFit':
        return Colors.orange.shade600;
      case 'HaneulTone':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade600;
      case 'inactive':
        return Colors.orange.shade600;
      case 'banned':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'All':
        return '전체';
      case 'active':
        return '활성';
      case 'inactive':
        return '비활성';
      case 'banned':
        return '차단됨';
      default:
        return status;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'doctor':
        return '의사';
      case 'nurse':
        return '간호사';
      case 'student':
        return '학생';
      case 'trainer':
        return '트레이너';
      case 'artist':
        return '성악가';
      default:
        return role;
    }
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 사용자 추가'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add user logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사용자 추가 기능은 개발 중입니다')),
              );
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user['name']} 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: user['name']),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: user['email']),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Edit user logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사용자 수정 기능은 개발 중입니다')),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(Map<String, dynamic> user, String action) {
    switch (action) {
      case 'block':
        final newStatus = user['status'] == 'banned' ? 'active' : 'banned';
        final message = newStatus == 'banned' ? '차단되었습니다' : '차단이 해제되었습니다';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user['name']}님이 $message')),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('사용자 삭제'),
            content: Text('${user['name']}님을 정말 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${user['name']}님이 삭제되었습니다')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
        );
        break;
    }
  }
}