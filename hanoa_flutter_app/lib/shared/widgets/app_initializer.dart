import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pending_change_provider.dart';
import '../providers/app_state_provider.dart';

/// 앱 초기화 담당 위젯 - MVP 버전: 로컬 데이터베이스 관리
class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  
  const AppInitializer({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // MVP: 로컬 데이터베이스만 사용, 별도 초기화 불필요
      // 주기적인 만료된 변경사항 정리 작업 시작
      _startPeriodicCleanup();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _initError = e.toString();
        _isInitialized = true; // 에러가 있어도 앱은 실행
      });
    }
  }

  void _startPeriodicCleanup() {
    // 30분마다 만료된 PendingChange 정리
    Future.delayed(const Duration(minutes: 30), () {
      if (mounted) {
        ref.read(pendingChangesProvider.notifier).cleanupExpiredChanges();
        _startPeriodicCleanup(); // 다음 정리 예약
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Hanoa MVP 초기화 중...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    
    if (_initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  '초기화 중 오류가 발생했습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _initError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isInitialized = false;
                      _initError = null;
                    });
                    _initializeApp();
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    
    return widget.child;
  }
}