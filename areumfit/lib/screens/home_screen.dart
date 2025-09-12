import 'package:flutter/material.dart';
import '../screens/recommendation_screen.dart';
import '../screens/workout_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/coach_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/localization_helper.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const RecommendationScreen(),
    const WorkoutScreen(),
    const CalendarScreen(),
    const CoachScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              context.l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '헬스 & 크로스핏',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ResponsiveBuilder(
        mobile: _screens[_selectedIndex],
        tablet: _buildTabletLayout(),
        foldableExpanded: _buildFoldableExpandedLayout(),
      ),
      bottomNavigationBar: ResponsiveUtils.supportsDualPanel(context) 
          ? null 
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home),
                  label: context.l10n.navRecommendation,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.fitness_center),
                  label: context.l10n.navWorkout,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_today),
                  label: context.l10n.navCalendar,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.psychology),
                  label: 'AI 코치',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person),
                  label: context.l10n.navProfile,
                ),
              ],
            ),
      drawer: ResponsiveUtils.supportsDualPanel(context) 
          ? null 
          : _buildNavigationDrawer(),
    );
  }

  // 갤럭시 폴드 펼친 상태를 위한 레이아웃
  Widget _buildFoldableExpandedLayout() {
    return DualPanelLayout(
      primaryPanel: _screens[_selectedIndex],
      secondaryPanel: _buildSecondaryPanel(),
      ratio: 0.65,
    );
  }

  // 태블릿 레이아웃
  Widget _buildTabletLayout() {
    return Row(
      children: [
        _buildSideNavigation(),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: _screens[_selectedIndex],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 1,
          child: _buildSecondaryPanel(),
        ),
      ],
    );
  }

  // 보조 패널 (오른쪽에 표시되는 내용)
  Widget _buildSecondaryPanel() {
    switch (_selectedIndex) {
      case 0: // 홈/추천
        return _buildQuickStatsPanel();
      case 1: // 운동
        return _buildWorkoutTimerPanel();
      case 2: // 캘린더
        return _buildUpcomingWorkoutsPanel();
      case 3: // AI 코치
        return _buildCoachSuggestionsPanel();
      case 4: // 프로필
        return _buildAchievementsPanel();
      default:
        return _buildQuickStatsPanel();
    }
  }

  // 사이드 네비게이션 (태블릿용)
  Widget _buildSideNavigation() {
    return Container(
      width: 200,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 20),
          ...List.generate(5, (index) {
            final isSelected = _selectedIndex == index;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(_getNavIcon(index)),
                title: Text(_getNavTitle(context, index)),
                selected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // 네비게이션 드로어 (모바일용)
  Widget _buildNavigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '헬스 & 크로스핏 통합 훈련',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(5, (index) {
            return ListTile(
              leading: Icon(_getNavIcon(index)),
              title: Text(_getNavTitle(context, index)),
              selected: _selectedIndex == index,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  // 보조 패널들
  Widget _buildQuickStatsPanel() {
    return Container(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 통계',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('이번 주 운동', '3회', Icons.fitness_center),
          const SizedBox(height: 8),
          _buildStatCard('총 운동 시간', '4시간 30분', Icons.schedule),
          const SizedBox(height: 8),
          _buildStatCard('칼로리 소모', '1,250 kcal', Icons.local_fire_department),
          const SizedBox(height: 8),
          _buildStatCard('목표 달성률', '75%', Icons.track_changes),
        ],
      ),
    );
  }

  Widget _buildWorkoutTimerPanel() {
    return Container(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '운동 타이머',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '03:45',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.pause),
                        iconSize: 32,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.stop),
                        iconSize: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingWorkoutsPanel() {
    return Container(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '다가오는 운동',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUpcomingWorkoutItem('내일', '상체 운동', '오후 7:00'),
          _buildUpcomingWorkoutItem('월요일', '하체 운동', '오후 6:30'),
          _buildUpcomingWorkoutItem('화요일', '유산소', '오전 7:00'),
        ],
      ),
    );
  }

  Widget _buildCoachSuggestionsPanel() {
    return Container(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI 코치 기능',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCoachFeatureCard('성과 분석', '운동 기록을 분석하여 개선점을 제시합니다', Icons.analytics),
          const SizedBox(height: 8),
          _buildCoachFeatureCard('개인화 추천', '당신만을 위한 맞춤형 운동을 추천합니다', Icons.recommend),
          const SizedBox(height: 8),
          _buildCoachFeatureCard('부상 예방', '위험도를 분석하여 부상을 미리 예방합니다', Icons.health_and_safety),
          const SizedBox(height: 8),
          _buildCoachFeatureCard('실시간 코칭', '운동 중 실시간으로 조언을 받아보세요', Icons.chat),
        ],
      ),
    );
  }

  Widget _buildAchievementsPanel() {
    return Container(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 성과',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAchievementItem('운동 연속 7일', Icons.local_fire_department),
          _buildAchievementItem('1RM 기록 갱신', Icons.trending_up),
          _buildAchievementItem('목표 체중 달성', Icons.flag),
        ],
      ),
    );
  }

  // 헬퍼 위젯들
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingWorkoutItem(String day, String workout, String time) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            day[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(workout),
        subtitle: Text(time),
      ),
    );
  }

  Widget _buildQuestionButton(String question) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () {
          // TODO: 채팅 화면으로 이동하며 질문 전송
        },
        child: Text(
          question,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildAchievementItem(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.amber),
        title: Text(title),
        trailing: const Icon(Icons.star, color: Colors.amber),
      ),
    );
  }
  
  Widget _buildCoachFeatureCard(String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                icon, 
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNavIcon(int index) {
    switch (index) {
      case 0: return Icons.home;
      case 1: return Icons.fitness_center;
      case 2: return Icons.calendar_today;
      case 3: return Icons.psychology;
      case 4: return Icons.person;
      default: return Icons.home;
    }
  }

  String _getNavTitle(BuildContext context, int index) {
    switch (index) {
      case 0: return context.l10n.navRecommendation;
      case 1: return context.l10n.navWorkout;
      case 2: return context.l10n.navCalendar;
      case 3: return 'AI 코치';
      case 4: return context.l10n.navProfile;
      default: return '';
    }
  }
}