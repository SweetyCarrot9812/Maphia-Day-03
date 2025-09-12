import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../models/session_v2.dart';
import '../services/coaching_service.dart';
import '../services/formant_analysis_service.dart';

/// 내보내기 서비스
/// 
/// HaneulTone v1 고도화 - 다양한 포맷 내보내기
/// 
/// Features:
/// - CSV 데이터 내보내기
/// - JSON 상세 내보내기
/// - PNG 차트 내보내기
/// - 커스텀 리포트 생성
class ExportService {
  static const String _version = '1.0.0';

  /// CSV 내보내기
  Future<ExportResult> exportToCSV({
    required List<SessionV2> sessions,
    List<VowelStabilityStats>? formantStats,
    String? customPath,
  }) async {
    try {
      final csvData = _generateCSVData(sessions, formantStats);
      final fileName = 'haneultone_data_${_getTimestamp()}.csv';
      final filePath = await _saveFile(csvData, fileName, customPath);
      
      return ExportResult(
        success: true,
        filePath: filePath,
        format: ExportFormat.csv,
        fileSize: csvData.length,
        recordCount: sessions.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'CSV 내보내기 실패: $e',
        format: ExportFormat.csv,
      );
    }
  }

  /// JSON 내보내기
  Future<ExportResult> exportToJSON({
    required List<SessionV2> sessions,
    List<VowelStabilityStats>? formantStats,
    List<CoachingCard>? coachingCards,
    String? customPath,
    bool includeDetailedAnalysis = true,
  }) async {
    try {
      final jsonData = _generateJSONData(
        sessions,
        formantStats,
        coachingCards,
        includeDetailedAnalysis,
      );
      
      final fileName = 'haneultone_export_${_getTimestamp()}.json';
      final filePath = await _saveFile(jsonData, fileName, customPath);
      
      return ExportResult(
        success: true,
        filePath: filePath,
        format: ExportFormat.json,
        fileSize: jsonData.length,
        recordCount: sessions.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'JSON 내보내기 실패: $e',
        format: ExportFormat.json,
      );
    }
  }

  /// PNG 차트 내보내기
  Future<ExportResult> exportChartToPNG({
    required GlobalKey repaintBoundaryKey,
    required String chartTitle,
    String? customPath,
    double pixelRatio = 2.0,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('차트를 찾을 수 없습니다');
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      
      final fileName = 'haneultone_chart_${_sanitizeFileName(chartTitle)}_${_getTimestamp()}.png';
      final filePath = await _saveFile(pngBytes, fileName, customPath);
      
      return ExportResult(
        success: true,
        filePath: filePath,
        format: ExportFormat.png,
        fileSize: pngBytes.length,
        imageWidth: image.width,
        imageHeight: image.height,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'PNG 내보내기 실패: $e',
        format: ExportFormat.png,
      );
    }
  }

  /// 종합 리포트 내보내기
  Future<ExportResult> exportComprehensiveReport({
    required List<SessionV2> sessions,
    List<VowelStabilityStats>? formantStats,
    List<CoachingCard>? coachingCards,
    List<GlobalKey>? chartKeys,
    String? customPath,
  }) async {
    try {
      final reportData = await _generateComprehensiveReport(
        sessions,
        formantStats,
        coachingCards,
        chartKeys,
      );
      
      final fileName = 'haneultone_report_${_getTimestamp()}.html';
      final filePath = await _saveFile(reportData, fileName, customPath);
      
      return ExportResult(
        success: true,
        filePath: filePath,
        format: ExportFormat.html,
        fileSize: reportData.length,
        recordCount: sessions.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: '종합 리포트 내보내기 실패: $e',
        format: ExportFormat.html,
      );
    }
  }

  /// 사용자 정의 내보내기
  Future<ExportResult> exportCustom({
    required List<SessionV2> sessions,
    required ExportConfig config,
    String? customPath,
  }) async {
    try {
      switch (config.format) {
        case ExportFormat.csv:
          return await exportToCSV(
            sessions: sessions,
            customPath: customPath,
          );
        case ExportFormat.json:
          return await exportToJSON(
            sessions: sessions,
            customPath: customPath,
            includeDetailedAnalysis: config.includeDetailedAnalysis,
          );
        case ExportFormat.png:
          if (config.chartKey != null) {
            return await exportChartToPNG(
              repaintBoundaryKey: config.chartKey!,
              chartTitle: config.chartTitle ?? '차트',
              customPath: customPath,
              pixelRatio: config.imageQuality,
            );
          } else {
            throw Exception('PNG 내보내기를 위해서는 차트 키가 필요합니다');
          }
        case ExportFormat.html:
          return await exportComprehensiveReport(
            sessions: sessions,
            customPath: customPath,
          );
      }
    } catch (e) {
      return ExportResult(
        success: false,
        error: '사용자 정의 내보내기 실패: $e',
        format: config.format,
      );
    }
  }

  /// CSV 데이터 생성
  String _generateCSVData(List<SessionV2> sessions, List<VowelStabilityStats>? formantStats) {
    final buffer = StringBuffer();
    
    // CSV 헤더
    buffer.writeln([
      'Session ID',
      'Reference ID',
      'Created At',
      'Accuracy (cents)',
      'Stability (cents)',
      'Vibrato Rate (Hz)',
      'Vibrato Extent (cents)',
      'Voiced Ratio',
      'Overall Score',
      'F1 Avg (Hz)',
      'F2 Avg (Hz)',
      'F3 Avg (Hz)',
      'Vowel Stability',
      'Dominant Vowel',
      'Practice Duration (min)',
      'Weak Segments Count',
    ].map(_escapeCSV).join(','));
    
    // 데이터 행들
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final metrics = session.metrics;
      final formantStat = formantStats != null && i < formantStats.length 
          ? formantStats[i] 
          : null;
      
      buffer.writeln([
        session.id,
        session.referenceId,
        session.createdAt.toIso8601String(),
        metrics?.accuracyCents?.toStringAsFixed(2) ?? '',
        metrics?.stabilityCents?.toStringAsFixed(2) ?? '',
        metrics?.vibratoRateHz?.toStringAsFixed(2) ?? '',
        metrics?.vibratoExtentCents?.toStringAsFixed(2) ?? '',
        metrics?.voicedRatio?.toStringAsFixed(3) ?? '',
        metrics?.overallScore?.toStringAsFixed(1) ?? '',
        _calculateAverageFormant(formantStat?.vowelStabilities, 'F1'),
        _calculateAverageFormant(formantStat?.vowelStabilities, 'F2'),
        _calculateAverageFormant(formantStat?.vowelStabilities, 'F3'),
        (formantStat?.overallStability ?? 0).toStringAsFixed(3),
        _findDominantVowel(formantStat?.vowelStabilities),
        _calculatePracticeDuration(session).toStringAsFixed(1),
        session.segments.length.toString(),
      ].map(_escapeCSV).join(','));
    }
    
    return buffer.toString();
  }

  /// JSON 데이터 생성
  String _generateJSONData(
    List<SessionV2> sessions,
    List<VowelStabilityStats>? formantStats,
    List<CoachingCard>? coachingCards,
    bool includeDetailedAnalysis,
  ) {
    final data = {
      'metadata': {
        'version': _version,
        'exported_at': DateTime.now().toIso8601String(),
        'total_sessions': sessions.length,
        'include_detailed_analysis': includeDetailedAnalysis,
      },
      'sessions': sessions.map((session) => {
        'session': session.toJson(),
        if (includeDetailedAnalysis) 'detailed_metrics': _generateDetailedMetrics(session),
      }).toList(),
      if (formantStats != null) 'formant_statistics': formantStats.map((stat) => {
        'overall_stability': stat.overallStability,
        'vowel_stabilities': stat.vowelStabilities.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        'total_frames': stat.totalFrames,
        'analysis_time_ms': stat.analysisTimeMs,
      }).toList(),
      if (coachingCards != null) 'coaching_cards': coachingCards.map((card) => {
        'id': card.id,
        'session_id': card.sessionId,
        'created_at': card.createdAt.toIso8601String(),
        'priority': card.priority.toString(),
        'goals': card.goals.map((goal) => {
          'title': goal.title,
          'description': goal.description,
          'current_score': goal.currentScore,
          'target_score': goal.targetScore,
          'category': goal.category,
          'difficulty': goal.difficulty.toString(),
          'estimated_days': goal.estimatedDays,
        }).toList(),
        'estimated_practice_time': card.estimatedPracticeTime,
      }).toList(),
      'summary': _generateSessionsSummary(sessions, formantStats),
    };
    
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// 종합 리포트 생성 (HTML)
  Future<String> _generateComprehensiveReport(
    List<SessionV2> sessions,
    List<VowelStabilityStats>? formantStats,
    List<CoachingCard>? coachingCards,
    List<GlobalKey>? chartKeys,
  ) async {
    final summary = _generateSessionsSummary(sessions, formantStats);
    
    final html = '''
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HaneulTone 연습 리포트</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', roboto, sans-serif; margin: 40px; line-height: 1.6; }
        .header { text-align: center; margin-bottom: 40px; border-bottom: 2px solid #007AFF; padding-bottom: 20px; }
        .summary { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; }
        .metric-value { font-size: 2em; font-weight: bold; color: #007AFF; }
        .metric-label { color: #666; margin-top: 5px; }
        .session-list { margin: 20px 0; }
        .session-item { background: white; padding: 15px; margin: 10px 0; border-radius: 8px; border-left: 4px solid #007AFF; }
        .grade-S { border-left-color: #8B5CF6; }
        .grade-A { border-left-color: #10B981; }
        .grade-B { border-left-color: #3B82F6; }
        .grade-C { border-left-color: #F59E0B; }
        .grade-D { border-left-color: #EF4444; }
        .footer { text-align: center; margin-top: 40px; color: #666; border-top: 1px solid #ddd; padding-top: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎵 HaneulTone 연습 리포트</h1>
        <p>생성일: ${DateTime.now().toString().substring(0, 19)}</p>
        <p>분석 기간: ${sessions.isNotEmpty ? sessions.first.createdAt.toString().substring(0, 10) : ''} ~ ${sessions.isNotEmpty ? sessions.last.createdAt.toString().substring(0, 10) : ''}</p>
    </div>

    <div class="summary">
        <h2>📊 요약 통계</h2>
        <div class="metrics">
            <div class="metric-card">
                <div class="metric-value">${sessions.length}</div>
                <div class="metric-label">총 연습 세션</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">${summary['avg_score']?.toStringAsFixed(1) ?? '0'}</div>
                <div class="metric-label">평균 점수</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">${summary['avg_accuracy']?.toStringAsFixed(1) ?? '0'}¢</div>
                <div class="metric-label">평균 정확도</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">${summary['avg_stability']?.toStringAsFixed(1) ?? '0'}¢</div>
                <div class="metric-label">평균 안정성</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">${summary['total_practice_time']?.toStringAsFixed(0) ?? '0'}</div>
                <div class="metric-label">총 연습 시간 (분)</div>
            </div>
        </div>
    </div>

    <div class="session-list">
        <h2>📝 세션 상세 내역</h2>
        ${sessions.map((session) {
          final metrics = session.metrics;
          final grade = metrics != null ? _calculateGrade(metrics.overallScore) : 'N/A';
          return '''
            <div class="session-item grade-$grade">
                <h3>세션: ${session.id.substring(0, 8)}... ($grade등급)</h3>
                <p><strong>날짜:</strong> ${session.createdAt.toString().substring(0, 19)}</p>
                <p><strong>점수:</strong> ${metrics?.overallScore.toStringAsFixed(1) ?? 'N/A'}</p>
                <p><strong>정확도:</strong> ${metrics?.accuracyCents.toStringAsFixed(1) ?? 'N/A'}¢</p>
                <p><strong>안정성:</strong> ${metrics?.stabilityCents.toStringAsFixed(1) ?? 'N/A'}¢</p>
                <p><strong>비브라토:</strong> ${metrics?.vibratoRateHz.toStringAsFixed(1) ?? 'N/A'}Hz</p>
                <p><strong>약한 구간:</strong> ${session.segments.length}개</p>
            </div>
          ''';
        }).join('')}
    </div>

    <div class="footer">
        <p>🎤 HaneulTone v$_version - AI 보컬 트레이너</p>
        <p>이 리포트는 자동으로 생성되었습니다.</p>
    </div>
</body>
</html>
''';
    
    return html;
  }

  /// 파일 저장
  Future<String> _saveFile(dynamic data, String fileName, String? customPath) async {
    String filePath;
    
    if (customPath != null) {
      // 사용자 지정 경로
      filePath = '$customPath/$fileName';
    } else {
      // 기본 Documents 폴더
      final directory = await getApplicationDocumentsDirectory();
      final haneulToneDir = Directory('${directory.path}/HaneulTone');
      if (!await haneulToneDir.exists()) {
        await haneulToneDir.create(recursive: true);
      }
      filePath = '${haneulToneDir.path}/$fileName';
    }
    
    final file = File(filePath);
    
    if (data is String) {
      await file.writeAsString(data, encoding: utf8);
    } else if (data is Uint8List) {
      await file.writeAsBytes(data);
    } else {
      throw ArgumentError('지원되지 않는 데이터 타입: ${data.runtimeType}');
    }
    
    return filePath;
  }

  /// 사용자에게 저장 위치 선택하게 하기
  Future<String?> pickSaveLocation({String? suggestedFileName}) async {
    try {
      return await FilePicker.platform.saveFile(
        dialogTitle: '저장 위치 선택',
        fileName: suggestedFileName,
        allowedExtensions: ['csv', 'json', 'png', 'html'],
        type: FileType.custom,
      );
    } catch (e) {
      print('파일 저장 위치 선택 실패: $e');
      return null;
    }
  }

  /// 헬퍼 메서드들
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  String _escapeCSV(dynamic value) {
    final str = value?.toString() ?? '';
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  String _calculateAverageFormant(Map<VowelClass, double>? stabilities, String formant) {
    if (stabilities == null || stabilities.isEmpty) return '';
    
    // 실제 구현에서는 포먼트별 평균을 계산
    // 여기서는 간단히 안정성 평균을 반환
    final avg = stabilities.values.reduce((a, b) => a + b) / stabilities.length;
    return (avg * 1000).toStringAsFixed(1); // Hz로 변환
  }

  String _findDominantVowel(Map<VowelClass, double>? stabilities) {
    if (stabilities == null || stabilities.isEmpty) return '';
    
    var maxVowel = stabilities.keys.first;
    var maxValue = stabilities.values.first;
    
    for (final entry in stabilities.entries) {
      if (entry.value > maxValue) {
        maxValue = entry.value;
        maxVowel = entry.key;
      }
    }
    
    return _getVowelName(maxVowel);
  }

  String _getVowelName(VowelClass vowel) {
    switch (vowel) {
      case VowelClass.a: return 'ㅏ';
      case VowelClass.ae: return 'ㅐ';
      case VowelClass.e: return 'ㅔ';
      case VowelClass.i: return 'ㅣ';
      case VowelClass.o: return 'ㅓ';
      case VowelClass.u: return 'ㅜ';
      default: return '기타';
    }
  }

  double _calculatePracticeDuration(SessionV2 session) {
    // 세션 지속 시간을 분으로 계산 (임시 구현)
    return 5.0; // 기본 5분
  }

  Map<String, dynamic> _generateDetailedMetrics(SessionV2 session) {
    final metrics = session.metrics;
    if (metrics == null) return {};
    
    return {
      'pitch_analysis': {
        'accuracy_cents': metrics.accuracyCents,
        'stability_cents': metrics.stabilityCents,
        'grade': _calculateGrade(metrics.overallScore),
      },
      'vibrato_analysis': {
        'rate_hz': metrics.vibratoRateHz,
        'extent_cents': metrics.vibratoExtentCents,
        'quality_score': _calculateVibratoQuality(metrics.vibratoRateHz, metrics.vibratoExtentCents),
      },
      'voice_quality': {
        'voiced_ratio': metrics.voicedRatio,
        'quality_score': metrics.voicedRatio * 100,
      },
      'weak_segments': session.segments.map((segment) => {
        'start_time_ms': segment.startTimeMs,
        'end_time_ms': segment.endTimeMs,
        'error_type': segment.errorType,
        'severity': segment.severity,
        'suggestion': segment.suggestion,
      }).toList(),
    };
  }

  Map<String, dynamic> _generateSessionsSummary(
    List<SessionV2> sessions, 
    List<VowelStabilityStats>? formantStats,
  ) {
    if (sessions.isEmpty) return {};
    
    final validSessions = sessions.where((s) => s.metrics != null).toList();
    if (validSessions.isEmpty) return {};
    
    final accuracies = validSessions.map((s) => s.metrics!.accuracyCents).toList();
    final stabilities = validSessions.map((s) => s.metrics!.stabilityCents).toList();
    final scores = validSessions.map((s) => s.metrics!.overallScore).toList();
    
    return {
      'total_sessions': sessions.length,
      'valid_sessions': validSessions.length,
      'avg_accuracy': accuracies.reduce((a, b) => a + b) / accuracies.length,
      'avg_stability': stabilities.reduce((a, b) => a + b) / stabilities.length,
      'avg_score': scores.reduce((a, b) => a + b) / scores.length,
      'best_score': scores.reduce((a, b) => a > b ? a : b),
      'total_practice_time': sessions.length * 5.0, // 임시: 세션당 5분
      'improvement_trend': _calculateImprovementTrend(scores),
    };
  }

  String _calculateGrade(double score) {
    if (score >= 90) return 'S';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    return 'D';
  }

  double _calculateVibratoQuality(double rate, double extent) {
    // 이상적인 비브라토: 5-7Hz, 50-100cents
    double rateScore = 100;
    if (rate < 5 || rate > 7) {
      rateScore = 100 - (rate - 6).abs() * 10;
    }
    
    double extentScore = 100;
    if (extent < 50 || extent > 100) {
      extentScore = 100 - ((extent - 75).abs() / 75) * 50;
    }
    
    return (rateScore + extentScore) / 2;
  }

  double _calculateImprovementTrend(List<double> scores) {
    if (scores.length < 2) return 0;
    
    // 선형 회귀로 트렌드 계산
    final n = scores.length;
    var sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumX2 = 0.0;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += scores[i];
      sumXY += i * scores[i];
      sumX2 += i * i;
    }
    
    return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  }
}

/// 내보내기 결과
class ExportResult {
  final bool success;
  final String? filePath;
  final ExportFormat format;
  final String? error;
  final int? fileSize;
  final int? recordCount;
  final int? imageWidth;
  final int? imageHeight;

  ExportResult({
    required this.success,
    this.filePath,
    required this.format,
    this.error,
    this.fileSize,
    this.recordCount,
    this.imageWidth,
    this.imageHeight,
  });
}

/// 내보내기 설정
class ExportConfig {
  final ExportFormat format;
  final bool includeDetailedAnalysis;
  final GlobalKey? chartKey;
  final String? chartTitle;
  final double imageQuality;
  final List<String> includedFields;

  ExportConfig({
    required this.format,
    this.includeDetailedAnalysis = true,
    this.chartKey,
    this.chartTitle,
    this.imageQuality = 2.0,
    this.includedFields = const [],
  });
}

/// 내보내기 포맷
enum ExportFormat {
  csv,
  json,
  png,
  html,
}

// VowelClass enum (다른 파일에 있다고 가정)
enum VowelClass { a, ae, e, i, o, u, high_mid, mid, unknown }