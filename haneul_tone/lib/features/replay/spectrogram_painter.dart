import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/alignment/dtw_aligner.dart';

/// 스펙트로그램 및 피치 곡선 페인터
/// 
/// HaneulTone v1 고도화 - 세션 리플레이를 위한 시각화 컴포넌트
/// 
/// Features:
/// - 스펙트로그램 배경 렌더링
/// - 레퍼런스 피치 곡선 (회색 라인)
/// - 사용자 피치 곡선 (파란 라인)  
/// - 약점 구간 하이라이트
/// - 확대/축소 지원
/// - 터치 제스처 대응
class SpectrogramPainter extends CustomPainter {
  /// 스펙트로그램 데이터 (주파수 x 시간 매트릭스)
  final List<Float32List>? spectrogramData;
  
  /// 레퍼런스 피치 곡선 (센트)
  final List<double> referenceCents;
  
  /// 사용자 피치 곡선 (센트)  
  final List<double> userCents;
  
  /// DTW 정렬 결과
  final DtwResult? dtwResult;
  
  /// 약점 구간들
  final List<WeakSegment> weakSegments;
  
  /// 현재 재생 위치 (0.0-1.0)
  final double playbackPosition;
  
  /// 확대/축소 레벨
  final double zoomLevel;
  
  /// 가로 스크롤 오프셋 (0.0-1.0)
  final double scrollOffset;
  
  /// 주파수 범위 (Hz)
  final double minFreqHz;
  final double maxFreqHz;
  
  /// 프레임 시간 간격 (ms)
  final double frameTimeMs;
  
  /// 색상 테마
  final ColorScheme colorScheme;

  SpectrogramPainter({
    this.spectrogramData,
    required this.referenceCents,
    required this.userCents,
    this.dtwResult,
    required this.weakSegments,
    this.playbackPosition = 0.0,
    this.zoomLevel = 1.0,
    this.scrollOffset = 0.0,
    this.minFreqHz = 70.0,
    this.maxFreqHz = 1000.0,
    this.frameTimeMs = 10.0,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // 배경색
    final backgroundPaint = Paint()..color = colorScheme.surface;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);
    
    if (referenceCents.isEmpty && userCents.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }
    
    // 스펙트로그램 배경 (있는 경우)
    if (spectrogramData != null && spectrogramData!.isNotEmpty) {
      _drawSpectrogram(canvas, size);
    }
    
    // 약점 구간 하이라이트 (피치 곡선 아래)
    _drawWeakSegmentHighlights(canvas, size);
    
    // 그리드 라인
    _drawGrid(canvas, size);
    
    // 레퍼런스 피치 곡선 (회색)
    if (referenceCents.isNotEmpty) {
      _drawPitchCurve(canvas, size, referenceCents, 
          colorScheme.onSurface.withOpacity(0.6), 2.0, false);
    }
    
    // 사용자 피치 곡선 (파랑)
    if (userCents.isNotEmpty) {
      _drawPitchCurve(canvas, size, userCents,
          colorScheme.primary, 3.0, true);
    }
    
    // 현재 재생 위치 표시
    if (playbackPosition > 0) {
      _drawPlaybackPosition(canvas, size);
    }
    
    // 범례
    _drawLegend(canvas, size);
  }

  /// 빈 상태 표시
  void _drawEmptyState(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: colorScheme.onSurface.withOpacity(0.5),
      fontSize: 16,
    );
    
    final textSpan = TextSpan(
      text: '피치 데이터가 없습니다',
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final centerX = size.width / 2 - textPainter.width / 2;
    final centerY = size.height / 2 - textPainter.height / 2;
    
    textPainter.paint(canvas, Offset(centerX, centerY));
  }

  /// 스펙트로그램 배경 그리기
  void _drawSpectrogram(Canvas canvas, Size size) {
    final specData = spectrogramData!;
    if (specData.isEmpty) return;
    
    final timeFrames = specData.length;
    final freqBins = specData[0].length;
    
    // 표시할 시간 범위 계산 (줌/스크롤 고려)
    final totalTimeMs = timeFrames * frameTimeMs;
    final visibleTimeMs = totalTimeMs / zoomLevel;
    final startTimeMs = scrollOffset * (totalTimeMs - visibleTimeMs);
    final endTimeMs = startTimeMs + visibleTimeMs;
    
    final startFrame = (startTimeMs / frameTimeMs).floor().clamp(0, timeFrames - 1);
    final endFrame = (endTimeMs / frameTimeMs).ceil().clamp(0, timeFrames - 1);
    
    // 주파수 매핑
    final logMinFreq = math.log(minFreqHz);
    final logMaxFreq = math.log(maxFreqHz);
    
    // 스펙트로그램 타일 그리기
    for (int t = startFrame; t < endFrame; t++) {
      final x = ((t - startFrame) / (endFrame - startFrame)) * size.width;
      final tileWidth = size.width / (endFrame - startFrame);
      
      for (int f = 0; f < freqBins; f++) {
        final magnitude = specData[t][f];
        if (magnitude <= 0) continue;
        
        // 주파수 bin을 로그 스케일로 매핑
        final binFreq = minFreqHz * math.pow(maxFreqHz / minFreqHz, f / freqBins);
        final logFreq = math.log(binFreq);
        
        if (logFreq < logMinFreq || logFreq > logMaxFreq) continue;
        
        final y = size.height * (1 - (logFreq - logMinFreq) / (logMaxFreq - logMinFreq));
        final tileHeight = size.height / freqBins;
        
        // 크기를 색상 강도로 변환
        final intensity = math.min(1.0, magnitude / 100.0); // 정규화
        final color = colorScheme.surfaceVariant.withOpacity(intensity * 0.3);
        
        final paint = Paint()..color = color;
        canvas.drawRect(
          Rect.fromLTWH(x, y, tileWidth, tileHeight),
          paint,
        );
      }
    }
  }

  /// 그리드 라인 그리기
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = colorScheme.outline.withOpacity(0.2)
      ..strokeWidth = 1.0;
    
    // 수직 그리드 (시간축) - 1초 간격
    final totalTimeMs = math.max(
      referenceCents.length * frameTimeMs,
      userCents.length * frameTimeMs,
    );
    final visibleTimeMs = totalTimeMs / zoomLevel;
    final startTimeMs = scrollOffset * (totalTimeMs - visibleTimeMs);
    
    for (double timeMs = 0; timeMs <= visibleTimeMs; timeMs += 1000) {
      final actualTimeMs = startTimeMs + timeMs;
      if (actualTimeMs > totalTimeMs) break;
      
      final x = (timeMs / visibleTimeMs) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    // 수평 그리드 (주파수축) - 반음계 간격
    const semitonesPerOctave = 12;
    final a4Hz = 440.0;
    final a4Cents = 0.0;
    
    for (int semitone = -36; semitone <= 36; semitone += 6) { // 반옥타브 간격
      final cents = semitone * 100.0;
      final freq = a4Hz * math.pow(2, cents / 1200.0);
      
      if (freq < minFreqHz || freq > maxFreqHz) continue;
      
      final y = _centsToY(cents, size.height);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  /// 피치 곡선 그리기
  void _drawPitchCurve(
    Canvas canvas,
    Size size,
    List<double> cents,
    Color color,
    double strokeWidth,
    bool showDots,
  ) {
    if (cents.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // 표시할 시간 범위 계산
    final totalTimeMs = cents.length * frameTimeMs;
    final visibleTimeMs = totalTimeMs / zoomLevel;
    final startTimeMs = scrollOffset * (totalTimeMs - visibleTimeMs);
    final endTimeMs = startTimeMs + visibleTimeMs;
    
    final startFrame = (startTimeMs / frameTimeMs).floor().clamp(0, cents.length - 1);
    final endFrame = (endTimeMs / frameTimeMs).ceil().clamp(0, cents.length - 1);
    
    final path = Path();
    bool pathStarted = false;
    
    for (int i = startFrame; i <= endFrame; i++) {
      final cent = cents[i];
      if (cent == 0) {
        // 무성음 구간 - 경로 끊기
        pathStarted = false;
        continue;
      }
      
      final timeMs = i * frameTimeMs;
      final x = ((timeMs - startTimeMs) / visibleTimeMs) * size.width;
      final y = _centsToY(cent, size.height);
      
      if (!pathStarted) {
        path.moveTo(x, y);
        pathStarted = true;
      } else {
        path.lineTo(x, y);
      }
      
      // 점 표시 (필요시)
      if (showDots && zoomLevel > 2.0) {
        canvas.drawCircle(Offset(x, y), 2.0, dotPaint);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  /// 약점 구간 하이라이트
  void _drawWeakSegmentHighlights(Canvas canvas, Size size) {
    if (weakSegments.isEmpty || dtwResult == null) return;
    
    for (final segment in weakSegments) {
      final startIdx = segment.startIdx;
      final endIdx = segment.endIdx;
      
      if (startIdx >= dtwResult!.pathLength || endIdx >= dtwResult!.pathLength) continue;
      
      // 시간 범위 계산
      final startTimeMs = startIdx * frameTimeMs;
      final endTimeMs = endIdx * frameTimeMs;
      
      final totalTimeMs = dtwResult!.pathLength * frameTimeMs;
      final visibleTimeMs = totalTimeMs / zoomLevel;
      final viewStartTimeMs = scrollOffset * (totalTimeMs - visibleTimeMs);
      
      if (endTimeMs < viewStartTimeMs || startTimeMs > viewStartTimeMs + visibleTimeMs) {
        continue; // 보이는 범위 밖
      }
      
      final x1 = math.max(0, ((startTimeMs - viewStartTimeMs) / visibleTimeMs) * size.width);
      final x2 = math.min(size.width, ((endTimeMs - viewStartTimeMs) / visibleTimeMs) * size.width);
      
      // 오차 정도에 따른 색상
      Color highlightColor;
      if (segment.averageError > 50) {
        highlightColor = Colors.red.withOpacity(0.2);
      } else if (segment.averageError > 30) {
        highlightColor = Colors.orange.withOpacity(0.15);
      } else {
        highlightColor = Colors.yellow.withOpacity(0.1);
      }
      
      final highlightPaint = Paint()..color = highlightColor;
      canvas.drawRect(
        Rect.fromLTWH(x1, 0, x2 - x1, size.height),
        highlightPaint,
      );
      
      // 상단에 오차 정보 표시 (줌 레벨이 높을 때)
      if (zoomLevel > 3.0 && x2 - x1 > 50) {
        final textStyle = TextStyle(
          color: colorScheme.error,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        );
        
        final textSpan = TextSpan(
          text: '${segment.averageError.toStringAsFixed(0)}c',
          style: textStyle,
        );
        
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        final textX = (x1 + x2) / 2 - textPainter.width / 2;
        textPainter.paint(canvas, Offset(textX, 5));
      }
    }
  }

  /// 현재 재생 위치 표시
  void _drawPlaybackPosition(Canvas canvas, Size size) {
    final totalTimeMs = math.max(
      referenceCents.length * frameTimeMs,
      userCents.length * frameTimeMs,
    );
    final visibleTimeMs = totalTimeMs / zoomLevel;
    final viewStartTimeMs = scrollOffset * (totalTimeMs - visibleTimeMs);
    
    final currentTimeMs = playbackPosition * totalTimeMs;
    
    if (currentTimeMs < viewStartTimeMs || currentTimeMs > viewStartTimeMs + visibleTimeMs) {
      return; // 보이는 범위 밖
    }
    
    final x = ((currentTimeMs - viewStartTimeMs) / visibleTimeMs) * size.width;
    
    final playbackPaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 2.0;
    
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      playbackPaint,
    );
    
    // 재생 위치 삼각형 마커
    final markerPath = Path()
      ..moveTo(x - 6, 0)
      ..lineTo(x + 6, 0)
      ..lineTo(x, 12)
      ..close();
    
    final markerPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(markerPath, markerPaint);
  }

  /// 범례 그리기
  void _drawLegend(Canvas canvas, Size size) {
    const legendMargin = 10.0;
    const legendSpacing = 8.0;
    
    // 레퍼런스 라인
    final refLinePaint = Paint()
      ..color = colorScheme.onSurface.withOpacity(0.6)
      ..strokeWidth = 2.0;
    
    canvas.drawLine(
      Offset(legendMargin, size.height - 40),
      Offset(legendMargin + 20, size.height - 40),
      refLinePaint,
    );
    
    _drawText(canvas, '레퍼런스', 
        Offset(legendMargin + 25, size.height - 45),
        colorScheme.onSurface.withOpacity(0.7), 12);
    
    // 사용자 라인
    final userLinePaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 3.0;
    
    canvas.drawLine(
      Offset(legendMargin, size.height - 20),
      Offset(legendMargin + 20, size.height - 20),
      userLinePaint,
    );
    
    _drawText(canvas, '내 목소리', 
        Offset(legendMargin + 25, size.height - 25),
        colorScheme.primary, 12);
  }

  /// 텍스트 그리기 헬퍼
  void _drawText(Canvas canvas, String text, Offset position, Color color, double fontSize) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
    
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  /// 센트를 Y 좌표로 변환
  double _centsToY(double cents, double height) {
    const minCents = -2400.0; // 4옥타브 아래
    const maxCents = 2400.0;  // 4옥타브 위
    
    final normalizedCents = (cents - minCents) / (maxCents - minCents);
    return height * (1 - normalizedCents.clamp(0.0, 1.0));
  }

  @override
  bool shouldRepaint(covariant SpectrogramPainter oldDelegate) {
    return oldDelegate.referenceCents != referenceCents ||
           oldDelegate.userCents != userCents ||
           oldDelegate.dtwResult != dtwResult ||
           oldDelegate.playbackPosition != playbackPosition ||
           oldDelegate.zoomLevel != zoomLevel ||
           oldDelegate.scrollOffset != scrollOffset ||
           oldDelegate.weakSegments != weakSegments;
  }
}