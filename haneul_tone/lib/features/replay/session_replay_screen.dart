import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'spectrogram_painter.dart';
import '../../core/alignment/dtw_aligner.dart';
import '../../core/metrics/metrics_calculator.dart';

/// 세션 리플레이 화면
/// 
/// HaneulTone v1 고도화 - 연습 세션의 시각적 분석 및 리플레이
/// 
/// Features:
/// - 스펙트로그램 + 피치 곡선 오버레이
/// - 약점 구간 자동 하이라이트 및 스마트 루프
/// - 핀치 줌, 드래그 제스처
/// - 재생/일시정지 컨트롤
/// - 메트릭 요약 표시
/// - 구간별 점프 네비게이션
class SessionReplayScreen extends StatefulWidget {
  /// 세션 데이터
  final SessionReplayData sessionData;

  const SessionReplayScreen({
    super.key,
    required this.sessionData,
  });

  @override
  State<SessionReplayScreen> createState() => _SessionReplayScreenState();
}

class _SessionReplayScreenState extends State<SessionReplayScreen>
    with TickerProviderStateMixin {
  
  // 컨트롤러들
  late AnimationController _playbackController;
  late AnimationController _zoomController;
  
  // 상태 변수들
  bool _isPlaying = false;
  double _zoomLevel = 1.0;
  double _scrollOffset = 0.0;
  int? _selectedWeakSegment;
  bool _isSmartLoopEnabled = false;
  bool _showMetricsPanel = true;
  
  // 제스처 관련
  double _lastPanUpdate = 0.0;
  double _initialScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    
    _playbackController = AnimationController(
      duration: Duration(
        milliseconds: (widget.sessionData.totalDurationMs).round(),
      ),
      vsync: this,
    );
    
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _playbackController.addListener(() {
      setState(() {});
    });
    
    // 스마트 루프 설정 (약점 구간이 있으면 자동 활성화)
    if (widget.sessionData.dtwResult.weakSegments.isNotEmpty) {
      _isSmartLoopEnabled = true;
      _selectedWeakSegment = 0;
    }
  }

  @override
  void dispose() {
    _playbackController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 메트릭 패널 (접을 수 있음)
          if (_showMetricsPanel) _buildMetricsPanel(context),
          
          // 메인 비주얼라이저 영역
          Expanded(child: _buildVisualizerArea(context)),
          
          // 컨트롤 패널
          _buildControlPanel(context),
        ],
      ),
    );
  }

  /// 앱바 구성
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('세션 리플레이'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: [
        IconButton(
          icon: Icon(_showMetricsPanel ? Icons.expand_less : Icons.expand_more),
          onPressed: () => setState(() => _showMetricsPanel = !_showMetricsPanel),
          tooltip: '메트릭 패널 ${_showMetricsPanel ? '숨기기' : '보기'}',
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelpDialog(context),
          tooltip: '도움말',
        ),
      ],
    );
  }

  /// 메트릭 패널
  Widget _buildMetricsPanel(BuildContext context) {
    final metrics = widget.sessionData.metrics;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 전체 점수
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '${metrics.overallScore.toStringAsFixed(0)}점',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 3대 지표
          Row(
            children: [
              Expanded(child: _buildMetricCard(
                context, '정확도', '${metrics.accuracyCents.toStringAsFixed(1)}c',
                metrics.accuracyGrade, Icons.my_location,
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricCard(
                context, '안정도', '${metrics.stabilityCents.toStringAsFixed(1)}c',
                metrics.stabilityGrade, Icons.water_drop,
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricCard(
                context, '비브라토', '${metrics.vibratoRateHz.toStringAsFixed(1)}Hz',
                metrics.vibratoGrade, Icons.graphic_eq,
              )),
            ],
          ),
          
          // 약점 구간 요약 (있는 경우)
          if (widget.sessionData.dtwResult.weakSegments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.priority_high, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '약점 구간 ${widget.sessionData.dtwResult.weakSegments.length}개',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 개별 메트릭 카드
  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String grade,
    IconData icon,
  ) {
    Color gradeColor;
    switch (grade) {
      case 'S':
        gradeColor = Colors.purple;
        break;
      case 'A':
        gradeColor = Colors.green;
        break;
      case 'B':
        gradeColor = Colors.blue;
        break;
      case 'C':
        gradeColor = Colors.orange;
        break;
      default:
        gradeColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gradeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gradeColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: gradeColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: gradeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: gradeColor,
            ),
          ),
          Text(
            grade,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: gradeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 메인 비주얼라이저 영역
  Widget _buildVisualizerArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onPanStart: (details) {
            _lastPanUpdate = details.globalPosition.dx;
            _initialScrollOffset = _scrollOffset;
            HapticFeedback.selectionClick();
          },
          onPanUpdate: (details) {
            final delta = details.globalPosition.dx - _lastPanUpdate;
            final sensitivity = 1.0 / _zoomLevel; // 줌이 클수록 민감도 감소
            
            setState(() {
              _scrollOffset = (_initialScrollOffset - delta * sensitivity / context.size!.width)
                  .clamp(0.0, 1.0 - 1.0 / _zoomLevel);
            });
          },
          onScaleStart: (details) {
            HapticFeedback.selectionClick();
          },
          onScaleUpdate: (details) {
            setState(() {
              _zoomLevel = (_zoomLevel * details.scale).clamp(1.0, 10.0);
              
              // 줌 중심점 고려한 스크롤 조정
              final focalPointX = details.focalPoint.dx / context.size!.width;
              _scrollOffset = (focalPointX - focalPointX / _zoomLevel).clamp(0.0, 1.0 - 1.0 / _zoomLevel);
            });
          },
          onTapUp: (details) {
            // 탭한 위치로 재생 위치 이동
            final tapX = details.localPosition.dx;
            final relativeX = tapX / context.size!.width;
            final totalTimeMs = widget.sessionData.totalDurationMs;
            final visibleTimeMs = totalTimeMs / _zoomLevel;
            final viewStartTimeMs = _scrollOffset * (totalTimeMs - visibleTimeMs);
            
            final targetTimeMs = viewStartTimeMs + relativeX * visibleTimeMs;
            final targetPosition = (targetTimeMs / totalTimeMs).clamp(0.0, 1.0);
            
            setState(() {
              _playbackController.value = targetPosition;
            });
            
            HapticFeedback.lightImpact();
          },
          child: CustomPaint(
            painter: SpectrogramPainter(
              spectrogramData: widget.sessionData.spectrogramData,
              referenceCents: widget.sessionData.referenceCents,
              userCents: widget.sessionData.userCents,
              dtwResult: widget.sessionData.dtwResult,
              weakSegments: widget.sessionData.dtwResult.weakSegments,
              playbackPosition: _playbackController.value,
              zoomLevel: _zoomLevel,
              scrollOffset: _scrollOffset,
              colorScheme: Theme.of(context).colorScheme,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  /// 컨트롤 패널
  Widget _buildControlPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 재생 컨트롤
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _isSmartLoopEnabled ? _goToPreviousWeakSegment : null,
                tooltip: '이전 약점 구간',
              ),
              
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 48,
                onPressed: _togglePlayback,
                tooltip: _isPlaying ? '일시정지' : '재생',
              ),
              
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _isSmartLoopEnabled ? _goToNextWeakSegment : null,
                tooltip: '다음 약점 구간',
              ),
            ],
          ),
          
          // 진행률 슬라이더
          Slider(
            value: _playbackController.value,
            onChanged: (value) {
              setState(() {
                _playbackController.value = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          
          // 시간 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_playbackController.value * widget.sessionData.totalDurationMs),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _formatTime(widget.sessionData.totalDurationMs),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 추가 컨트롤
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 줌 컨트롤
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.zoom_out),
                        onPressed: _zoomLevel > 1.0 ? _zoomOut : null,
                        iconSize: 20,
                      ),
                      Text(
                        '${_zoomLevel.toStringAsFixed(1)}x',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.zoom_in),
                        onPressed: _zoomLevel < 10.0 ? _zoomIn : null,
                        iconSize: 20,
                      ),
                    ],
                  ),
                  Text(
                    '줌',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              // 스마트 루프 토글
              Column(
                children: [
                  Switch(
                    value: _isSmartLoopEnabled,
                    onChanged: widget.sessionData.dtwResult.weakSegments.isNotEmpty
                        ? (value) => setState(() => _isSmartLoopEnabled = value)
                        : null,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    '스마트 루프',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              // 재생 속도
              Column(
                children: [
                  DropdownButton<double>(
                    value: 1.0,
                    items: [0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
                      return DropdownMenuItem(
                        value: speed,
                        child: Text('${speed}x'),
                      );
                    }).toList(),
                    onChanged: (speed) {
                      // TODO: 재생 속도 변경 구현
                    },
                    underline: Container(),
                  ),
                  Text(
                    '속도',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== 컨트롤 메서드들 ==========

  void _togglePlayback() {
    setState(() {
      if (_isPlaying) {
        _playbackController.stop();
      } else {
        if (_playbackController.value >= 1.0) {
          _playbackController.reset();
        }
        _playbackController.forward();
      }
      _isPlaying = !_isPlaying;
    });
    
    HapticFeedback.lightImpact();
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = math.min(10.0, _zoomLevel * 1.5);
    });
    HapticFeedback.selectionClick();
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = math.max(1.0, _zoomLevel / 1.5);
      _scrollOffset = _scrollOffset.clamp(0.0, 1.0 - 1.0 / _zoomLevel);
    });
    HapticFeedback.selectionClick();
  }

  void _goToNextWeakSegment() {
    final weakSegments = widget.sessionData.dtwResult.weakSegments;
    if (weakSegments.isEmpty) return;
    
    _selectedWeakSegment = ((_selectedWeakSegment ?? -1) + 1) % weakSegments.length;
    _jumpToWeakSegment(_selectedWeakSegment!);
  }

  void _goToPreviousWeakSegment() {
    final weakSegments = widget.sessionData.dtwResult.weakSegments;
    if (weakSegments.isEmpty) return;
    
    _selectedWeakSegment = ((_selectedWeakSegment ?? 1) - 1 + weakSegments.length) % weakSegments.length;
    _jumpToWeakSegment(_selectedWeakSegment!);
  }

  void _jumpToWeakSegment(int segmentIndex) {
    final segment = widget.sessionData.dtwResult.weakSegments[segmentIndex];
    final totalFrames = widget.sessionData.dtwResult.pathLength;
    
    if (totalFrames == 0) return;
    
    final segmentCenter = (segment.startIdx + segment.endIdx) / 2;
    final targetPosition = segmentCenter / totalFrames;
    
    setState(() {
      _playbackController.value = targetPosition.clamp(0.0, 1.0);
      
      // 줌 레벨에 따라 스크롤 조정
      final visibleRatio = 1.0 / _zoomLevel;
      _scrollOffset = (targetPosition - visibleRatio / 2).clamp(0.0, 1.0 - visibleRatio);
    });
    
    HapticFeedback.mediumImpact();
    
    // 약점 구간 정보 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '약점 구간 ${segmentIndex + 1}: ${segment.suggestion}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(double milliseconds) {
    final totalSeconds = (milliseconds / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용법'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossRef.start,
            children: [
              Text('📱 제스처:'),
              Text('• 좌우 드래그: 스크롤'),
              Text('• 핀치: 확대/축소'),
              Text('• 탭: 해당 위치로 이동'),
              SizedBox(height: 16),
              Text('🎵 곡선:'),
              Text('• 회색 라인: 레퍼런스'),
              Text('• 파란 라인: 내 목소리'),
              SizedBox(height: 16),
              Text('⚡ 스마트 루프:'),
              Text('• 약점 구간만 자동 반복'),
              Text('• 이전/다음 버튼으로 이동'),
              SizedBox(height: 16),
              Text('🎯 하이라이트:'),
              Text('• 빨강: 큰 오차 (50c+)'),
              Text('• 주황: 중간 오차 (30-50c)'),
              Text('• 노랑: 작은 오차 (30c 미만)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 세션 리플레이 데이터 모델
class SessionReplayData {
  /// 스펙트로그램 데이터 (선택사항)
  final List<Float32List>? spectrogramData;
  
  /// 레퍼런스 피치 곡선 (센트)
  final List<double> referenceCents;
  
  /// 사용자 피치 곡선 (센트)
  final List<double> userCents;
  
  /// DTW 정렬 결과
  final DtwResult dtwResult;
  
  /// 계산된 메트릭
  final Metrics metrics;
  
  /// 총 지속 시간 (밀리초)
  final double totalDurationMs;

  const SessionReplayData({
    this.spectrogramData,
    required this.referenceCents,
    required this.userCents,
    required this.dtwResult,
    required this.metrics,
    required this.totalDurationMs,
  });
}