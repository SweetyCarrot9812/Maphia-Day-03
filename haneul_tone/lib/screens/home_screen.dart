import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cross_platform_storage_service.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../models/audio_reference.dart';
import '../models/session.dart';
import 'upload_reference_screen.dart';
import 'realtime_tuner_screen.dart';
import 'scale_practice_screen.dart';
import '../widgets/vocal_coach_dashboard.dart';
import '../services/personalized_vocal_coach.dart';
import '../services/session_replay_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AudioReference> _audioReferences = [];
  List<Session> _recentSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storageService = context.read<CrossPlatformStorageService>();
    
    try {
      final audioRefs = await storageService.getAllAudioReferences();
      final sessions = await storageService.getAllSessions();
      
      setState(() {
        _audioReferences = audioRefs;
        _recentSessions = sessions.take(5).toList(); // 최근 5개만
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로딩 중 오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HaneulTone'),
        elevation: 0,
        actions: [
          Consumer<AuthService>(
            builder: (context, authService, child) {
              final user = authService.currentUser;
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    user?.displayName?.isNotEmpty == true 
                        ? user!.displayName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'profile':
                      // TODO: 프로필 화면으로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('프로필 화면 구현 예정')),
                      );
                      break;
                    case 'sync':
                      await _handleSync(context);
                      break;
                    case 'settings':
                      // TODO: 설정 화면으로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('설정 화면 구현 예정')),
                      );
                      break;
                    case 'logout':
                      await authService.logout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.displayName ?? '사용자',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'sync',
                    child: Row(
                      children: [
                        Icon(Icons.sync, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('오프라인 데이터 동기화'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined),
                        SizedBox(width: 8),
                        Text('설정'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('로그아웃', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 환영 메시지
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.music_note,
                                size: 32,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '보컬 트레이닝을 시작하세요',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AI가 당신의 음정을 분석하고 개선점을 제시합니다',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 빠른 시작 버튼들
                  Text(
                    '빠른 시작',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 첫 번째 줄 - AI 코치 (강조)
                  SizedBox(
                    width: double.infinity,
                    child: _QuickActionCard(
                      icon: Icons.smart_toy,
                      title: 'AI 보컬 코치',
                      subtitle: '개인화된 보컬 트레이닝 및 종합 분석',
                      isHighlighted: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VocalCoachDashboard(
                              vocalCoach: PersonalizedVocalCoach(),
                              replayService: SessionReplayService(),
                              userId: 'current_user', // TODO: 실제 사용자 ID 사용
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.upload_file,
                          title: '레퍼런스\n업로드',
                          subtitle: '스케일 오디오\n파일 추가',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UploadReferenceScreen(),
                              ),
                            );
                            
                            // 업로드 완료 후 데이터 새로고침
                            if (result == true) {
                              _loadData();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.tune,
                          title: '실시간\n튜너',
                          subtitle: '피치 정확도\n실시간 확인',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RealtimeTunerScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 레퍼런스 오디오 목록
                  Text(
                    '레퍼런스 오디오 (${_audioReferences.length}개)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_audioReferences.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.library_music_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '등록된 레퍼런스 오디오가 없습니다',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '피아노로 녹음한 스케일을 업로드하여 시작하세요',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._audioReferences.map((ref) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            ref.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(ref.title),
                        subtitle: Text('${ref.scaleType} • ${ref.octaves}옥타브'),
                        trailing: Text(
                          _formatDate(ref.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScalePracticeScreen(
                                audioReference: ref,
                              ),
                            ),
                          );
                        },
                      ),
                    )),
                  
                  const SizedBox(height: 24),
                  
                  // 최근 연습 기록
                  Text(
                    '최근 연습 기록',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_recentSessions.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '아직 연습 기록이 없습니다',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._recentSessions.map((session) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getAccuracyColor(session.accuracyMean),
                          child: Text(
                            '${session.accuracyMean.round()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text('정확도: ${session.accuracyMean.toStringAsFixed(1)}c'),
                        subtitle: Text('안정도: ${session.stabilitySd.toStringAsFixed(1)}c'),
                        trailing: Text(
                          _formatDate(session.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          // TODO: 세션 상세 보기
                          _showComingSoon();
                        },
                      ),
                    )),
                ],
              ),
            ),
    );
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('준비 중'),
        content: const Text('이 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '${difference}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy < 20) return Colors.green;
    if (accuracy < 50) return Colors.orange;
    return Colors.red;
  }

  // 오프라인 데이터 동기화 처리
  Future<void> _handleSync(BuildContext context) async {
    try {
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('오프라인 데이터를 동기화하는 중...'),
            ],
          ),
        ),
      );

      // 동기화 실행
      final syncCount = await SyncService.instance.flushQueued();
      
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
        
        // 결과 메시지 표시
        String message;
        if (syncCount > 0) {
          message = '$syncCount개의 세션이 성공적으로 동기화되었습니다.';
        } else {
          message = '동기화할 오프라인 데이터가 없습니다.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: syncCount > 0 ? Colors.green : Colors.grey[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // 데이터 새로고침
        _loadData();
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('동기화 중 오류가 발생했습니다. 네트워크 연결을 확인해주세요.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      print('Sync error: $e');
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isHighlighted ? 4 : 2,
      color: isHighlighted ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
      child: Container(
        decoration: isHighlighted ? BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ) : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: isHighlighted ? 48 : 40,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isHighlighted ? 16 : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: isHighlighted ? 13 : null,
                  ),
                ),
                if (isHighlighted) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
