import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class StudyTimer extends StatefulWidget {
  const StudyTimer({super.key});

  @override
  State<StudyTimer> createState() => _StudyTimerState();
}

class _StudyTimerState extends State<StudyTimer> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;
  DateTime? _startTime;
  Duration _pausedDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadPreviousSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveSession();
    super.dispose();
  }

  /// 이전 세션 로드
  Future<void> _loadPreviousSession() async {
    try {
      final savedSeconds = StorageService.getInt('study_timer_seconds', defaultValue: 0);
      final wasRunning = StorageService.getBool('study_timer_running', defaultValue: false);
      final startTimeMillis = StorageService.getInt('study_timer_start_time', defaultValue: 0);
      
      if (savedSeconds > 0) {
        setState(() {
          _elapsedTime = Duration(seconds: savedSeconds);
        });
      }
      
      // 앱이 종료되었다가 다시 시작된 경우, 타이머를 자동으로 일시정지 상태로 변경
      if (wasRunning && startTimeMillis > 0) {
        final savedStartTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
        final now = DateTime.now();
        final additionalTime = now.difference(savedStartTime);
        
        setState(() {
          _elapsedTime = _elapsedTime + additionalTime;
          _isRunning = false; // 자동으로 일시정지 상태로 변경
        });
        
        await _saveSession();
      }
    } catch (e) {
      print('타이머 세션 로드 오류: $e');
    }
  }

  /// 현재 세션 저장
  Future<void> _saveSession() async {
    try {
      await StorageService.setInt('study_timer_seconds', _elapsedTime.inSeconds);
      await StorageService.setBool('study_timer_running', _isRunning);
      
      if (_isRunning && _startTime != null) {
        await StorageService.setInt('study_timer_start_time', _startTime!.millisecondsSinceEpoch);
      } else {
        await StorageService.remove('study_timer_start_time');
      }
    } catch (e) {
      print('타이머 세션 저장 오류: $e');
    }
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
        _startTime = DateTime.now();
      });
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTime = _elapsedTime + const Duration(seconds: 1);
        });
      });
      
      _saveSession();
      
      // 타이머 시작 시 자동 팝아웃
      _showTimerPopout();
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _startTime = null;
      });
      
      _saveSession();
      
      // 타이머 일시정지 시 자동 팝아웃
      _showTimerPopout();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedTime = Duration.zero;
      _startTime = null;
      _pausedDuration = Duration.zero;
    });
    
    // 저장된 세션 데이터 삭제
    StorageService.remove('study_timer_seconds');
    StorageService.remove('study_timer_running');
    StorageService.remove('study_timer_start_time');
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  /// 오늘의 총 학습시간에 추가
  Future<void> _addToTotalStudyTime() async {
    if (_elapsedTime.inSeconds > 0) {
      try {
        final today = DateTime.now();
        final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final existingSeconds = StorageService.getInt('daily_study_$dateKey', defaultValue: 0);
        final newTotal = existingSeconds + _elapsedTime.inSeconds;
        
        await StorageService.setInt('daily_study_$dateKey', newTotal);
        
        // 전체 누적 학습시간도 업데이트
        final totalSeconds = StorageService.getInt('total_study_time_seconds', defaultValue: 0);
        await StorageService.setInt('total_study_time_seconds', totalSeconds + _elapsedTime.inSeconds);
        
        print('학습시간 저장: ${_elapsedTime.inSeconds}초 (오늘: $newTotal초)');
      } catch (e) {
        print('학습시간 저장 오류: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isRunning ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isRunning ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (_isRunning) {
            _pauseTimer();
          } else {
            _startTimer();
          }
        },
        onLongPress: () => _showTimerMenu(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isRunning ? Icons.pause_circle : Icons.play_circle,
                color: _isRunning ? AppTheme.primaryColor : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDuration(_elapsedTime),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isRunning ? AppTheme.primaryColor : Colors.grey[700],
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.more_vert,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 타이머 시작/일시정지 시 자동 팝아웃
  void _showTimerPopout() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _isRunning ? Icons.play_circle : Icons.pause_circle, 
              color: _isRunning ? Colors.green : Colors.orange
            ),
            const SizedBox(width: 8),
            Text(_isRunning ? '타이머 시작됨' : '타이머 일시정지됨'),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (_isRunning ? Colors.green : Colors.orange).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDuration(_elapsedTime),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _isRunning ? Colors.green : Colors.orange,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRunning ? '학습이 진행되고 있습니다' : '학습이 일시정지되었습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
          if (!_isRunning)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startTimer();
              },
              child: Text('다시 시작', style: TextStyle(color: AppTheme.primaryColor)),
            ),
        ],
      ),
    );
  }

  void _showTimerMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.timer, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('학습 타이머'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_elapsedTime),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRunning ? '진행 중...' : '일시정지',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_isRunning) {
                        _pauseTimer();
                      } else {
                        _startTimer();
                      }
                      Navigator.of(context).pop(); // 팝업 닫기
                    },
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? '일시정지' : '시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? Colors.orange : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elapsedTime.inSeconds > 0 ? () async {
                      await _addToTotalStudyTime();
                      _resetTimer();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('학습시간이 기록되었습니다!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } : null,
                    icon: const Icon(Icons.save),
                    label: const Text('저장 후 정지'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _elapsedTime.inSeconds > 0 ? () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('타이머 초기화'),
                      content: const Text('현재 측정된 시간이 삭제됩니다.\n계속하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetTimer();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('초기화'),
                        ),
                      ],
                    ),
                  );
                } : null,
                icon: const Icon(Icons.refresh, color: Colors.red),
                label: const Text('초기화', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}