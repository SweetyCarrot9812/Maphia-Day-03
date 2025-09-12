import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_providers.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/metrics_card.dart';
import '../widgets/achievements_card.dart';
import '../utils/responsive_utils.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: 실제 사용자 ID 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserProfile('user-1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        foldableExpanded: _buildFoldableExpandedLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = userProvider.currentProfile;
        final metrics = userProvider.currentMetrics;
        final workoutStats = userProvider.workoutStats;

        if (profile == null) {
          return _buildEmptyProfile();
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(profile),
            SliverPadding(
              padding: ResponsiveUtils.getAdaptivePadding(context),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ProfileInfoCard(profile: profile),
                  const SizedBox(height: 16),
                  if (metrics != null) MetricsCard(metrics: metrics),
                  const SizedBox(height: 16),
                  if (workoutStats != null) AchievementsCard(stats: workoutStats),
                  const SizedBox(height: 16),
                  // TODO: MongoDB 동기화 상태 위젯 추가 예정
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = userProvider.currentProfile;
        final metrics = userProvider.currentMetrics;
        final workoutStats = userProvider.workoutStats;

        if (profile == null) {
          return _buildEmptyProfile();
        }

        return Row(
          children: [
            // Left panel - Profile info and metrics
            Expanded(
              flex: 2,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(profile),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        ProfileInfoCard(profile: profile),
                        const SizedBox(height: 16),
                        if (metrics != null) MetricsCard(metrics: metrics),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            // Right panel - Achievements and actions
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (workoutStats != null) 
                      Expanded(child: AchievementsCard(stats: workoutStats)),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFoldableExpandedLayout() {
    return _buildTabletLayout(); // Same as tablet for now
  }

  Widget _buildAppBar(UserProfile profile) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          profile.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Account for app bar
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editProfile(profile),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _openSettings(),
        ),
      ],
    );
  }

  Widget _buildEmptyProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_add,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '프로필을 설정해주세요',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '운동 기록과 개인화된 추천을 받으려면\n프로필을 먼저 설정해주세요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createProfile(),
            icon: const Icon(Icons.add),
            label: const Text('프로필 만들기'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '빠른 실행',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.fitness_center,
              title: '운동 기록 보기',
              subtitle: '지난 운동 기록들을 확인해보세요',
              onTap: () => _viewWorkoutHistory(),
            ),
            _buildActionTile(
              icon: Icons.trending_up,
              title: '성과 분석',
              subtitle: '운동 성과와 발전 상황을 분석해보세요',
              onTap: () => _viewProgressAnalysis(),
            ),
            _buildActionTile(
              icon: Icons.psychology,
              title: 'AI 코치 상담',
              subtitle: '개인화된 운동 조언을 받아보세요',
              onTap: () => _startCoaching(),
            ),
            _buildActionTile(
              icon: Icons.share,
              title: '성과 공유',
              subtitle: '친구들과 운동 성과를 공유해보세요',
              onTap: () => _shareProgress(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _editProfile(UserProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    );
  }

  void _createProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _viewWorkoutHistory() {
    // TODO: Navigate to workout history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('운동 기록 화면으로 이동 (개발 예정)')),
    );
  }

  void _viewProgressAnalysis() {
    // TODO: Navigate to progress analysis screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('성과 분석 화면으로 이동 (개발 예정)')),
    );
  }

  void _startCoaching() {
    // Navigate to AI coach screen (which we just implemented)
    DefaultTabController.of(context)?.animateTo(3); // AI Coach tab
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI 코치 탭으로 이동합니다')),
    );
  }

  void _shareProgress() {
    // TODO: Implement progress sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('성과 공유 기능 (개발 예정)')),
    );
  }
}