import 'dart:math' as math;
import 'dart:typed_data';

/// DTW (Dynamic Time Warping) 정렬 결과
/// 
/// HaneulTone v1 고도화 - 레퍼런스와 사용자 피치 곡선의 최적 정렬
class DtwResult {
  /// 레퍼런스 곡선의 정렬된 인덱스 경로
  final List<int> pathRefIdx;
  
  /// 사용자 곡선의 정렬된 인덱스 경로
  final List<int> pathUserIdx;
  
  /// 총 DTW 비용 (낮을수록 유사함)
  final double totalCost;
  
  /// 정규화된 DTW 거리 (경로 길이로 정규화)
  final double normalizedDistance;
  
  /// 구간별 오차 리스트 (센트 단위)
  final List<double> segmentErrors;
  
  /// 약점 구간 정보
  final List<WeakSegment> weakSegments;

  const DtwResult({
    required this.pathRefIdx,
    required this.pathUserIdx,
    required this.totalCost,
    required this.normalizedDistance,
    required this.segmentErrors,
    required this.weakSegments,
  });

  /// 정렬 경로의 길이
  int get pathLength => pathRefIdx.length;

  /// 유효한 정렬인지 확인
  bool get isValidAlignment => pathLength > 0 && pathRefIdx.length == pathUserIdx.length;

  /// 평균 오차 (센트)
  double get averageError {
    if (segmentErrors.isEmpty) return 0.0;
    return segmentErrors.reduce((a, b) => a + b) / segmentErrors.length;
  }

  @override
  String toString() {
    return 'DtwResult('
           'pathLength=$pathLength, '
           'totalCost=${totalCost.toStringAsFixed(2)}, '
           'normDistance=${normalizedDistance.toStringAsFixed(3)}, '
           'avgError=${averageError.toStringAsFixed(1)}c, '
           'weakSegments=${weakSegments.length})';
  }
}

/// 약점 구간 정보
class WeakSegment {
  /// 시작 인덱스 (정렬된 경로 기준)
  final int startIdx;
  
  /// 종료 인덱스 (정렬된 경로 기준)
  final int endIdx;
  
  /// 해당 구간의 평균 오차 (센트)
  final double averageError;
  
  /// 오차 유형 (pitch, rhythm, stability 등)
  final String errorType;
  
  /// 개선 제안
  final String suggestion;

  const WeakSegment({
    required this.startIdx,
    required this.endIdx,
    required this.averageError,
    required this.errorType,
    required this.suggestion,
  });

  /// 구간 길이
  int get length => endIdx - startIdx + 1;

  @override
  String toString() {
    return 'WeakSegment($startIdx-$endIdx, ${averageError.toStringAsFixed(1)}c, $errorType)';
  }
}

/// DTW 정렬 알고리즘 구현
/// 
/// HaneulTone v1 고도화 - 시간 축 변형을 허용하는 동적 정렬
/// 
/// Features:
/// - Sakoe-Chiba band 제약을 통한 효율적 계산
/// - 센트 단위 비용 함수
/// - 무성음 구간 가중치 조정
/// - 구간별 오차 분석 및 약점 구간 검출
class DtwAligner {
  final double _bandWidthRatio;
  final double _voicingWeight;
  final double _maxCostThreshold;
  final double _weakSegmentThreshold;
  
  /// DTW 정렬기 생성자
  /// 
  /// [bandWidthRatio]: Sakoe-Chiba band 폭 (시퀀스 길이 대비 비율, 기본 0.1)
  /// [voicingWeight]: 유성음 가중치 (기본 1.0, 무성음은 0.3)
  /// [maxCostThreshold]: 최대 허용 비용 (센트, 기본 100c)
  /// [weakSegmentThreshold]: 약점 구간 임계값 (센트, 기본 30c)
  DtwAligner({
    double bandWidthRatio = 0.1,
    double voicingWeight = 1.0,
    double maxCostThreshold = 100.0,
    double weakSegmentThreshold = 30.0,
  }) : _bandWidthRatio = bandWidthRatio,
       _voicingWeight = voicingWeight,
       _maxCostThreshold = maxCostThreshold,
       _weakSegmentThreshold = weakSegmentThreshold;

  /// 레퍼런스와 사용자 피치 곡선 정렬
  /// 
  /// [referenceCents]: 레퍼런스 피치 곡선 (센트 단위)
  /// [userCents]: 사용자 피치 곡선 (센트 단위)
  /// [referenceVoicing]: 레퍼런스 유성음 확률 (선택사항)
  /// [userVoicing]: 사용자 유성음 확률 (선택사항)
  /// [returns]: DTW 정렬 결과
  DtwResult align(
    List<double> referenceCents,
    List<double> userCents, {
    List<double>? referenceVoicing,
    List<double>? userVoicing,
  }) {
    if (referenceCents.isEmpty || userCents.isEmpty) {
      return DtwResult(
        pathRefIdx: [],
        pathUserIdx: [],
        totalCost: double.infinity,
        normalizedDistance: double.infinity,
        segmentErrors: [],
        weakSegments: [],
      );
    }

    final refLength = referenceCents.length;
    final userLength = userCents.length;
    
    // Sakoe-Chiba band 폭 계산
    final bandWidth = (_bandWidthRatio * math.max(refLength, userLength)).round();
    
    // DTW 매트릭스 계산
    final dtwResult = _computeDtwMatrix(
      referenceCents,
      userCents,
      bandWidth,
      referenceVoicing,
      userVoicing,
    );
    
    if (dtwResult.totalCost == double.infinity) {
      return DtwResult(
        pathRefIdx: [],
        pathUserIdx: [],
        totalCost: double.infinity,
        normalizedDistance: double.infinity,
        segmentErrors: [],
        weakSegments: [],
      );
    }
    
    // 백트래킹으로 최적 경로 찾기
    final path = _backtrack(dtwResult.costMatrix, refLength, userLength, bandWidth);
    
    // 구간별 오차 계산
    final segmentErrors = _calculateSegmentErrors(
      referenceCents,
      userCents,
      path.pathRefIdx,
      path.pathUserIdx,
    );
    
    // 약점 구간 검출
    final weakSegments = _detectWeakSegments(
      segmentErrors,
      path.pathRefIdx,
      path.pathUserIdx,
      referenceCents,
      userCents,
    );
    
    return DtwResult(
      pathRefIdx: path.pathRefIdx,
      pathUserIdx: path.pathUserIdx,
      totalCost: dtwResult.totalCost,
      normalizedDistance: dtwResult.totalCost / path.pathRefIdx.length,
      segmentErrors: segmentErrors,
      weakSegments: weakSegments,
    );
  }

  /// DTW 매트릭스 계산
  _DtwMatrixResult _computeDtwMatrix(
    List<double> referenceCents,
    List<double> userCents,
    int bandWidth,
    List<double>? referenceVoicing,
    List<double>? userVoicing,
  ) {
    final refLength = referenceCents.length;
    final userLength = userCents.length;
    
    // 비용 매트릭스 초기화 (infinity로)
    final costMatrix = List.generate(
      refLength,
      (i) => Float64List.fromList(List.filled(userLength, double.infinity)),
    );
    
    // 시작점 초기화
    costMatrix[0][0] = _computeLocalCost(
      referenceCents[0],
      userCents[0],
      referenceVoicing?[0] ?? 1.0,
      userVoicing?[0] ?? 1.0,
    );
    
    // DP를 이용한 최소 비용 경로 계산
    for (int i = 0; i < refLength; i++) {
      // Sakoe-Chiba band 제약
      final jStart = math.max(0, i - bandWidth);
      final jEnd = math.min(userLength - 1, i + bandWidth);
      
      for (int j = jStart; j <= jEnd; j++) {
        if (i == 0 && j == 0) continue; // 이미 초기화됨
        
        // 지역 비용 계산
        final localCost = _computeLocalCost(
          referenceCents[i],
          userCents[j],
          referenceVoicing?[i] ?? 1.0,
          userVoicing?[j] ?? 1.0,
        );
        
        // 이전 경로들의 최소 비용 찾기
        double minPrevCost = double.infinity;
        
        // (i-1, j-1): 대각선 (매칭)
        if (i > 0 && j > 0) {
          minPrevCost = math.min(minPrevCost, costMatrix[i - 1][j - 1]);
        }
        
        // (i-1, j): 수직 (레퍼런스 삽입)
        if (i > 0) {
          minPrevCost = math.min(minPrevCost, costMatrix[i - 1][j]);
        }
        
        // (i, j-1): 수평 (사용자 삽입)
        if (j > 0) {
          minPrevCost = math.min(minPrevCost, costMatrix[i][j - 1]);
        }
        
        // 시작 지점에서의 특별 처리
        if ((i == 0 || j == 0) && minPrevCost == double.infinity) {
          minPrevCost = 0.0;
        }
        
        costMatrix[i][j] = localCost + minPrevCost;
      }
    }
    
    final totalCost = costMatrix[refLength - 1][userLength - 1];
    
    return _DtwMatrixResult(
      costMatrix: costMatrix,
      totalCost: totalCost,
    );
  }

  /// 지역 비용 계산 (센트 차이 기반)
  double _computeLocalCost(
    double refCents,
    double userCents,
    double refVoicing,
    double userVoicing,
  ) {
    // 둘 다 무성음인 경우 (센트가 0)
    if (refCents == 0 && userCents == 0) {
      return 0.0; // 무성음끼리는 완벽한 매치
    }
    
    // 하나는 유성음, 하나는 무성음인 경우
    if (refCents == 0 || userCents == 0) {
      return _maxCostThreshold * 0.5; // 중간 정도의 페널티
    }
    
    // 둘 다 유성음인 경우
    final centsDiff = (refCents - userCents).abs();
    
    // 유성음 확률 기반 가중치
    final voicingFactor = (refVoicing + userVoicing) / 2.0;
    final weightedCost = centsDiff * (_voicingWeight * voicingFactor + (1 - _voicingWeight));
    
    return math.min(weightedCost, _maxCostThreshold);
  }

  /// 백트래킹으로 최적 경로 찾기
  _AlignmentPath _backtrack(
    List<Float64List> costMatrix,
    int refLength,
    int userLength,
    int bandWidth,
  ) {
    final pathRefIdx = <int>[];
    final pathUserIdx = <int>[];
    
    int i = refLength - 1;
    int j = userLength - 1;
    
    while (i > 0 || j > 0) {
      pathRefIdx.add(i);
      pathUserIdx.add(j);
      
      // 가능한 이전 상태들의 비용 확인
      double minCost = double.infinity;
      int nextI = i;
      int nextJ = j;
      
      // 대각선 (매칭)
      if (i > 0 && j > 0 && costMatrix[i - 1][j - 1] < minCost) {
        minCost = costMatrix[i - 1][j - 1];
        nextI = i - 1;
        nextJ = j - 1;
      }
      
      // 수직 (레퍼런스 삽입)
      if (i > 0 && costMatrix[i - 1][j] < minCost) {
        minCost = costMatrix[i - 1][j];
        nextI = i - 1;
        nextJ = j;
      }
      
      // 수평 (사용자 삽입)
      if (j > 0 && costMatrix[i][j - 1] < minCost) {
        minCost = costMatrix[i][j - 1];
        nextI = i;
        nextJ = j - 1;
      }
      
      i = nextI;
      j = nextJ;
    }
    
    // 시작점 추가
    pathRefIdx.add(0);
    pathUserIdx.add(0);
    
    // 경로를 시간 순서대로 뒤집기
    final reversedPathRefIdx = pathRefIdx.reversed.toList();
    final reversedPathUserIdx = pathUserIdx.reversed.toList();
    
    return _AlignmentPath(
      pathRefIdx: reversedPathRefIdx,
      pathUserIdx: reversedPathUserIdx,
    );
  }

  /// 구간별 오차 계산
  List<double> _calculateSegmentErrors(
    List<double> referenceCents,
    List<double> userCents,
    List<int> pathRefIdx,
    List<int> pathUserIdx,
  ) {
    final errors = <double>[];
    
    for (int i = 0; i < pathRefIdx.length; i++) {
      final refIdx = pathRefIdx[i];
      final userIdx = pathUserIdx[i];
      
      final refCents = referenceCents[refIdx];
      final userCentsValue = userCents[userIdx];
      
      // 무성음 구간은 오차 0으로 처리
      if (refCents == 0 && userCentsValue == 0) {
        errors.add(0.0);
      } else if (refCents == 0 || userCentsValue == 0) {
        errors.add(_weakSegmentThreshold); // 유/무성음 불일치
      } else {
        errors.add((refCents - userCentsValue).abs());
      }
    }
    
    return errors;
  }

  /// 약점 구간 검출
  List<WeakSegment> _detectWeakSegments(
    List<double> segmentErrors,
    List<int> pathRefIdx,
    List<int> pathUserIdx,
    List<double> referenceCents,
    List<double> userCents,
  ) {
    final weakSegments = <WeakSegment>[];
    
    if (segmentErrors.isEmpty) return weakSegments;
    
    int? segmentStart;
    List<double> currentErrors = [];
    
    for (int i = 0; i < segmentErrors.length; i++) {
      final error = segmentErrors[i];
      
      if (error > _weakSegmentThreshold) {
        // 약점 구간 시작 또는 계속
        segmentStart ??= i;
        currentErrors.add(error);
      } else {
        // 약점 구간 종료
        if (segmentStart != null && currentErrors.isNotEmpty) {
          final avgError = currentErrors.reduce((a, b) => a + b) / currentErrors.length;
          
          // 약점 구간이 의미 있는 길이인지 확인 (최소 3프레임)
          if (currentErrors.length >= 3) {
            final segment = _analyzeWeakSegment(
              segmentStart,
              i - 1,
              avgError,
              pathRefIdx,
              pathUserIdx,
              referenceCents,
              userCents,
            );
            weakSegments.add(segment);
          }
          
          segmentStart = null;
          currentErrors.clear();
        }
      }
    }
    
    // 마지막 구간 처리
    if (segmentStart != null && currentErrors.isNotEmpty && currentErrors.length >= 3) {
      final avgError = currentErrors.reduce((a, b) => a + b) / currentErrors.length;
      final segment = _analyzeWeakSegment(
        segmentStart,
        segmentErrors.length - 1,
        avgError,
        pathRefIdx,
        pathUserIdx,
        referenceCents,
        userCents,
      );
      weakSegments.add(segment);
    }
    
    return weakSegments;
  }

  /// 약점 구간 분석
  WeakSegment _analyzeWeakSegment(
    int startIdx,
    int endIdx,
    double avgError,
    List<int> pathRefIdx,
    List<int> pathUserIdx,
    List<double> referenceCents,
    List<double> userCents,
  ) {
    // 오차 패턴 분석
    String errorType = 'pitch';
    String suggestion = '피치 정확도를 향상시키세요';
    
    if (avgError > 50) {
      errorType = 'pitch';
      suggestion = '음정이 많이 벗어났습니다. 천천히 정확한 음정을 찾아보세요';
    } else if (avgError > 30) {
      errorType = 'stability';
      suggestion = '음정이 불안정합니다. 호흡과 발성을 안정화하세요';
    } else {
      errorType = 'fine_tuning';
      suggestion = '미세한 음정 조정이 필요합니다';
    }
    
    return WeakSegment(
      startIdx: startIdx,
      endIdx: endIdx,
      averageError: avgError,
      errorType: errorType,
      suggestion: suggestion,
    );
  }
}

// ========== 내부 데이터 클래스들 ==========

/// DTW 매트릭스 계산 결과
class _DtwMatrixResult {
  final List<Float64List> costMatrix;
  final double totalCost;

  _DtwMatrixResult({
    required this.costMatrix,
    required this.totalCost,
  });
}

/// 정렬 경로
class _AlignmentPath {
  final List<int> pathRefIdx;
  final List<int> pathUserIdx;

  _AlignmentPath({
    required this.pathRefIdx,
    required this.pathUserIdx,
  });
}