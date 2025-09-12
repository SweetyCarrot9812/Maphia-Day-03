import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 개발 모드에서만 표시되는 플로팅 새로고침 버튼
/// 
/// Hot Reload 기능을 제공하는 간단한 버튼입니다.
/// kDebugMode에서만 작동하며, 릴리즈 빌드에서는 숨겨집니다.
class FloatingRefreshButton extends StatefulWidget {
  const FloatingRefreshButton({super.key});

  @override
  State<FloatingRefreshButton> createState() => _FloatingRefreshButtonState();
}

class _FloatingRefreshButtonState extends State<FloatingRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // 회전 애니메이션 시작
    _animationController.forward();

    // 시각적 피드백을 위한 지연
    await Future.delayed(const Duration(milliseconds: 500));

    // Hot Reload 기능 시뮬레이션
    // 실제 Hot Reload는 IDE나 CLI에서 수행되므로,
    // 여기서는 앱 상태 새로고침이나 캐시 클리어 등을 수행할 수 있습니다.
    _performRefresh();

    await Future.delayed(const Duration(milliseconds: 500));

    // 애니메이션 완료 후 상태 리셋
    _animationController.reset();
    setState(() {
      _isRefreshing = false;
    });

    // 사용자에게 피드백 제공
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('새로고침 완료! (Hot Reload는 IDE에서 R 키 사용)'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _performRefresh() {
    // 여기에 실제 새로고침 로직을 구현할 수 있습니다.
    // 예: 캐시 클리어, 상태 초기화, API 재호출 등
    
    // 현재는 간단한 로깅만 수행
    if (kDebugMode) {
      print('FloatingRefreshButton: Refresh triggered at ${DateTime.now()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 디버그 모드가 아니면 버튼을 표시하지 않음
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100, // AppBar 아래 위치
      right: 20, // 우측 여백
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2.0 * 3.14159, // 360도 회전
                child: IconButton(
                  onPressed: _isRefreshing ? null : _handleRefresh,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 28,
                  ),
                  splashColor: Colors.white24,
                  highlightColor: Colors.white12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}