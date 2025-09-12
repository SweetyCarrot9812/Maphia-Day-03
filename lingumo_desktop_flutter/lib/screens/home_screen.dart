import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/word_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _koreanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _englishController.dispose();
    _koreanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordProvider);
    final stats = ref.watch(wordStatsProvider);
    final todayCount = ref.watch(todayWordsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lingumo 데스크톱',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침 (Hot Reload)',
            onPressed: _performHotReload,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: '재시작 (Hot Restart)',
            onPressed: _performHotRestart,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('설정 기능 개발 중입니다!'),
                  backgroundColor: Color(0xFF1976D2),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E7D32).withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Left Panel - Main Content
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Compact Welcome Header
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.translate,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lingumo 데스크톱',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '영어 단어장 - 단어와 뜻을 함께 저장하세요',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Word/Sentence Input Section
                      Expanded(
                        child: Card(
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '영어 단어 입력',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Column(
                                    children: [
                                      // 영어 단어 입력
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          color: Colors.grey[50],
                                        ),
                                        child: TextField(
                                          controller: _englishController,
                                          decoration: const InputDecoration(
                                            labelText: '🇺🇸 영어 단어',
                                            hintText: 'apple, beautiful, understand...',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(20),
                                          ),
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // 한글 뜻 입력
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          color: const Color(0xFF1976D2).withValues(alpha: 0.05),
                                        ),
                                        child: TextField(
                                          controller: _koreanController,
                                          decoration: const InputDecoration(
                                            labelText: '🇰🇷 한글 뜻',
                                            hintText: '사과, 아름다운, 이해하다...',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(20),
                                          ),
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // 힌트 텍스트
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.blue[200]!, width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '💡 팁: 영어 단어와 한글 뜻을 각각 입력하고 저장하세요',
                                                style: TextStyle(
                                                  color: Colors.blue[800],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _saveWord,
                                    icon: const Icon(Icons.save, size: 28),
                                    label: const Text(
                                      '단어장에 저장',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      backgroundColor: const Color(0xFF2E7D32),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Right Panel - System Dashboard
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.dashboard,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '시스템 현황',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildCompactStatusCard(
                                    '총 저장량',
                                    '${stats['total']}개',
                                    Icons.bookmark,
                                    const Color(0xFF2E7D32),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildCompactStatusCard(
                                    '오늘 추가',
                                    '${todayCount}개',
                                    Icons.today,
                                    const Color(0xFF1976D2),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildCompactStatusCard(
                                    '미학습',
                                    '${stats['new']}개',
                                    Icons.fiber_new,
                                    const Color(0xFF388E3C),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildCompactStatusCard(
                                    '완료',
                                    '${stats['mastered']}개',
                                    Icons.check_circle,
                                    const Color(0xFF7B1FA2),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildCompactStatusCard(
                                    '학습 중',
                                    '${stats['learning']}개',
                                    Icons.school,
                                    const Color(0xFFFF9800),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                          const Color(0xFF1976D2).withValues(alpha: 0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Hive DB 연결됨',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveWord() async {
    final english = _englishController.text.trim();
    final korean = _koreanController.text.trim();
    
    if (english.isEmpty || korean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('영어 단어와 한글 뜻을 모두 입력해주세요!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    try {
      // Hive DB에 실제 저장
      await ref.read(wordProvider.notifier).addWord(english, korean);
      
      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.save, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('\"$english\" → \"$korean\" 저장완료!'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // 입력 필드 클리어
      _englishController.clear();
      _koreanController.clear();
    } catch (e) {
      // 오류 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }


  void _performHotReload() {
    // Hot Reload 시뮬레이션 - setState를 호출하여 UI 새로고침
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text('Hot Reload 실행 중... 🔄'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // UI 상태 새로고침
    setState(() {
      // 애니메이션 재시작
      _animationController.reset();
      _animationController.forward();
    });
    
    // 키보드 포커스 해제
    FocusScope.of(context).unfocus();
    
    // 실제 개발 환경에서는 Flutter DevTools나 IDE에서 'r' 키를 눌러 Hot Reload를 수행
    // 여기서는 시각적 피드백만 제공
  }

  void _performHotRestart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.restart_alt, color: Colors.white),
            SizedBox(width: 8),
            Text('Hot Restart 시뮬레이션 🔄'),
          ],
        ),
        backgroundColor: const Color(0xFF1976D2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Hot Restart 시뮬레이션 - 상태 초기화
    setState(() {
      // 텍스트 컨트롤러 클리어
      _englishController.clear();
      _koreanController.clear();
      
      // 애니메이션 완전 재시작
      _animationController.reset();
      _animationController.forward();
    });
    
    // 키보드 포커스 해제
    FocusScope.of(context).unfocus();
    
    // 실제 개발 환경에서는 Flutter DevTools나 IDE에서 'R' (대문자) 키를 눌러 Hot Restart를 수행
    // 또는 터미널에서 직접 'R' 키 입력
  }
}