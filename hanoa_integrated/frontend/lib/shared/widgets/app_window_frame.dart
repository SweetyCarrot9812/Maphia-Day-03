import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import 'floating_dev_button.dart';

class AppWindowFrame extends ConsumerStatefulWidget {
  final Widget child;

  const AppWindowFrame({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppWindowFrame> createState() => _AppWindowFrameState();
}

class _AppWindowFrameState extends ConsumerState<AppWindowFrame>
    with WindowListener {
  bool _isMaximized = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _updateWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _updateWindowState() async {
    final isMaximized = await windowManager.isMaximized();
    final isFullScreen = await windowManager.isFullScreen();
    
    if (mounted) {
      setState(() {
        _isMaximized = isMaximized;
        _isFullScreen = isFullScreen;
      });
    }
  }

  @override
  void onWindowMaximize() {
    setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => _isMaximized = false);
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() => _isFullScreen = true);
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() => _isFullScreen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main app layout
          Column(
            children: [
              if (!_isFullScreen) _buildTitleBar(),
              Expanded(
                child: Row(
                  children: [
                    _buildSidebar(),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
          
          // Floating dev button overlay (debug mode only)
          const FloatingDevButton(),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // App icon and title
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => windowManager.startDragging(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.hub,
                      size: 20,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🏠 Hanoa Hub - Educational Platform',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Window controls
          _buildWindowControls(),
        ],
      ),
    );
  }

  Widget _buildWindowControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowButton(
          icon: Icons.minimize,
          onPressed: () => windowManager.minimize(),
          tooltip: '최소화',
        ),
        _WindowButton(
          icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
          onPressed: () {
            if (_isMaximized) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
          tooltip: _isMaximized ? '복원' : '최대화',
        ),
        _WindowButton(
          icon: Icons.close,
          onPressed: () => windowManager.close(),
          tooltip: '닫기',
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(child: _buildNavigationMenu()),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 30,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '관리자',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '시스템 관리자',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu() {
    final currentLocation = GoRouterState.of(context).uri.toString();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        _buildNavItem(
          icon: Icons.dashboard,
          title: '대시보드',
          route: '/dashboard',
          isActive: currentLocation == '/dashboard',
        ),
        _buildNavItem(
          icon: Icons.add_circle,
          title: '문제 생성',
          route: '/problem-creation',
          isActive: currentLocation == '/problem-creation',
        ),
        _buildNavSection('인증'),
        _buildNavItem(
          icon: Icons.login,
          title: 'Hub ID 로그인',
          route: '/auth',
          isActive: currentLocation == '/auth',
        ),
        _buildNavSection('회원 관리'),
        _buildNavItem(
          icon: Icons.people,
          title: '회원 관리',
          route: '/users',
          isActive: currentLocation == '/users',
        ),
        _buildNavItem(
          icon: Icons.settings,
          title: '설정',
          route: '/settings',
          isActive: currentLocation == '/settings',
        ),
      ],
    );
  }

  Widget _buildNavSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String route,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isActive
              ? AppTheme.primaryBlue
              : Theme.of(context).iconTheme.color,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isActive
                ? AppTheme.primaryBlue
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => context.go(route),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 8),
              Text(
                'v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isDestructive;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 46,
            height: 32,
            child: Icon(
              icon,
              size: 16,
              color: isDestructive 
                  ? Colors.red.shade600 
                  : Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}