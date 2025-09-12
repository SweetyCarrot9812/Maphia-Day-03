import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

/// 슈퍼 관리자 서비스
/// 
/// Hanoa 생태계 전체의 슈퍼 관리자 계정 관리
/// 모든 프로젝트(Clintest, Lingumo, AreumFit 등)에서 공유 사용 가능
class AdminService {
  static final _logger = Loggers.admin;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 슈퍼 관리자 권한 레벨
  static const int SUPER_ADMIN = 100;
  static const int PROJECT_ADMIN = 50;
  static const int MODERATOR = 25;
  static const int USER = 1;
  
  /// 슈퍼 관리자 이메일 목록 (환경변수로 관리 예정)
  static const List<String> _superAdminEmails = [
    'tkandpf26@gmail.com',         // 메인 슈퍼 관리자 (개인 계정)
    'hanoa.superadmin@gmail.com',  // 예비 관리자
    'admin@hanoa.kr',              // 백업 관리자
    // 추가 관리자 계정은 여기에 추가
  ];

  /// 현재 사용자의 관리자 권한 레벨 확인
  static Future<int> getCurrentUserAdminLevel() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return USER;
      
      return await getUserAdminLevel(user.uid);
    } catch (e) {
      _logger.error('관리자 권한 확인 오류', e);
      return USER;
    }
  }

  /// 특정 사용자의 관리자 권한 레벨 확인
  static Future<int> getUserAdminLevel(String uid) async {
    try {
      final doc = await _firestore
          .collection('hanoa_admins')
          .doc(uid)
          .get();

      if (!doc.exists) {
        // 기본 사용자인지 슈퍼 관리자 이메일인지 확인
        final user = await FirebaseAuth.instance.currentUser;
        if (user != null && _superAdminEmails.contains(user.email)) {
          // 슈퍼 관리자 계정 자동 생성
          await createSuperAdmin(uid, user.email!, user.displayName ?? 'Super Admin');
          return SUPER_ADMIN;
        }
        return USER;
      }

      final data = doc.data()!;
      return data['adminLevel'] as int? ?? USER;
    } catch (e) {
      _logger.error('사용자 권한 확인 오류', e);
      return USER;
    }
  }

  /// 슈퍼 관리자 계정 생성
  static Future<void> createSuperAdmin(String uid, String email, String displayName) async {
    try {
      _logger.info('슈퍼 관리자 계정 생성: $email');
      
      final adminData = {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'adminLevel': SUPER_ADMIN,
        'permissions': [
          'user_management',      // 사용자 관리
          'content_management',   // 콘텐츠 관리
          'system_settings',      // 시스템 설정
          'analytics_access',     // 분석 데이터 접근
          'project_management',   // 프로젝트 관리
          'super_admin_access',   // 슈퍼 관리자 전용 기능
        ],
        'managedProjects': [
          'clintest',    // 의료 학습 플랫폼
          'lingumo',     // 언어 학습 플랫폼
          'areumfit',    // 피트니스 플랫폼
          'haneultone',  // 보컬 트레이닝 플랫폼
          'hanoa_hub',   // 통합 허브
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'notes': 'Hanoa 생태계 슈퍼 관리자',
      };

      await _firestore
          .collection('hanoa_admins')
          .doc(uid)
          .set(adminData);

      _logger.info('슈퍼 관리자 계정 생성 완료: $email');
    } catch (e) {
      _logger.error('슈퍼 관리자 생성 오류', e);
      rethrow;
    }
  }

  /// 프로젝트 관리자 계정 생성
  static Future<void> createProjectAdmin(
    String uid,
    String email,
    String displayName,
    List<String> managedProjects,
  ) async {
    try {
      _logger.info('프로젝트 관리자 계정 생성: $email');
      
      final adminData = {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'adminLevel': PROJECT_ADMIN,
        'permissions': [
          'content_management',
          'user_moderation',
          'project_analytics',
        ],
        'managedProjects': managedProjects,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'notes': '프로젝트 관리자',
      };

      await _firestore
          .collection('hanoa_admins')
          .doc(uid)
          .set(adminData);

      _logger.info('프로젝트 관리자 계정 생성 완료');
    } catch (e) {
      _logger.error('프로젝트 관리자 생성 오류', e);
      rethrow;
    }
  }

  /// 관리자 권한 확인 (특정 권한 체크)
  static Future<bool> hasPermission(String permission) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('hanoa_admins')
          .doc(user.uid)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final permissions = List<String>.from(data['permissions'] ?? []);
      
      return permissions.contains(permission);
    } catch (e) {
      _logger.error('권한 확인 오류', e);
      return false;
    }
  }

  /// 프로젝트 관리 권한 확인
  static Future<bool> canManageProject(String projectId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('hanoa_admins')
          .doc(user.uid)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final managedProjects = List<String>.from(data['managedProjects'] ?? []);
      
      // 슈퍼 관리자는 모든 프로젝트 관리 가능
      if (data['adminLevel'] == SUPER_ADMIN) return true;
      
      return managedProjects.contains(projectId);
    } catch (e) {
      _logger.error('프로젝트 권한 확인 오류', e);
      return false;
    }
  }

  /// 모든 관리자 목록 조회 (슈퍼 관리자만 가능)
  static Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final currentLevel = await getCurrentUserAdminLevel();
      if (currentLevel != SUPER_ADMIN) {
        throw Exception('슈퍼 관리자 권한이 필요합니다');
      }

      final snapshot = await _firestore
          .collection('hanoa_admins')
          .orderBy('adminLevel', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      _logger.error('관리자 목록 조회 오류', e);
      rethrow;
    }
  }

  /// 관리자 권한 업데이트 (슈퍼 관리자만 가능)
  static Future<void> updateAdminPermissions(
    String uid,
    int adminLevel,
    List<String> permissions,
    List<String> managedProjects,
  ) async {
    try {
      final currentLevel = await getCurrentUserAdminLevel();
      if (currentLevel != SUPER_ADMIN) {
        throw Exception('슈퍼 관리자 권한이 필요합니다');
      }

      await _firestore
          .collection('hanoa_admins')
          .doc(uid)
          .update({
            'adminLevel': adminLevel,
            'permissions': permissions,
            'managedProjects': managedProjects,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      _logger.info('관리자 권한 업데이트 완료: $uid');
    } catch (e) {
      _logger.error('관리자 권한 업데이트 오류', e);
      rethrow;
    }
  }

  /// 관리자 계정 비활성화 (슈퍼 관리자만 가능)
  static Future<void> deactivateAdmin(String uid, String reason) async {
    try {
      final currentLevel = await getCurrentUserAdminLevel();
      if (currentLevel != SUPER_ADMIN) {
        throw Exception('슈퍼 관리자 권한이 필요합니다');
      }

      await _firestore
          .collection('hanoa_admins')
          .doc(uid)
          .update({
            'status': 'inactive',
            'deactivatedAt': FieldValue.serverTimestamp(),
            'deactivationReason': reason,
          });

      _logger.warning('관리자 계정 비활성화: $uid, 이유: $reason');
    } catch (e) {
      _logger.error('관리자 비활성화 오류', e);
      rethrow;
    }
  }

  /// 관리자 활동 로그 기록
  static Future<void> logAdminActivity(String action, Map<String, dynamic> details) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestore
          .collection('hanoa_admin_logs')
          .add({
            'adminUid': user.uid,
            'adminEmail': user.email,
            'action': action,
            'details': details,
            'timestamp': FieldValue.serverTimestamp(),
            'ipAddress': 'unknown', // 실제 구현시 IP 주소 수집
          });
    } catch (e) {
      _logger.error('관리자 활동 로그 오류', e);
    }
  }

  /// 현재 사용자가 슈퍼 관리자인지 확인
  static Future<bool> isSuperAdmin() async {
    final level = await getCurrentUserAdminLevel();
    return level == SUPER_ADMIN;
  }

  /// 현재 사용자가 관리자인지 확인 (프로젝트 관리자 이상)
  static Future<bool> isAdmin() async {
    final level = await getCurrentUserAdminLevel();
    return level >= PROJECT_ADMIN;
  }

  /// 슈퍼 관리자 계정 자동 초기화 (앱 시작시 호출)
  static Future<void> initializeSuperAdminIfNeeded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 슈퍼 관리자 이메일인지 확인
      if (_superAdminEmails.contains(user.email)) {
        final currentLevel = await getUserAdminLevel(user.uid);
        
        // 아직 슈퍼 관리자로 등록되지 않았다면 자동 생성
        if (currentLevel != SUPER_ADMIN) {
          await createSuperAdmin(
            user.uid, 
            user.email!, 
            user.displayName ?? 'Super Admin'
          );
          
          _logger.info('슈퍼 관리자 계정 자동 초기화 완료: ${user.email}');
        }
      }
    } catch (e) {
      _logger.error('슈퍼 관리자 자동 초기화 오류', e);
    }
  }
}