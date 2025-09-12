import 'dart:math' as math;

class NoteUtils {
  // 음계 이름과 반음 수 매핑
  static const Map<String, int> noteToSemitone = {
    'C': 0, 'C#': 1, 'Db': 1,
    'D': 2, 'D#': 3, 'Eb': 3,
    'E': 4,
    'F': 5, 'F#': 6, 'Gb': 6,
    'G': 7, 'G#': 8, 'Ab': 8,
    'A': 9, 'A#': 10, 'Bb': 10,
    'B': 11,
  };

  // 반음 수를 음계 이름으로 변환
  static const List<String> semitoneToNote = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 
    'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  // 스케일 패턴 정의 (반음 수)
  static const Map<String, List<int>> scalePatterns = {
    'Major': [0, 2, 4, 5, 7, 9, 11],           // 도레미파솔라시
    'Minor': [0, 2, 3, 5, 7, 8, 10],           // 자연 단음계
    'Pentatonic': [0, 2, 4, 7, 9],             // 펜타토닉
    'Chromatic': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], // 반음계
  };

  // 주파수에서 음계 이름 계산
  static String frequencyToNoteName(double frequency, double a4Freq) {
    if (frequency <= 0) return '';
    
    // A4를 기준으로 반음 수 계산
    final semitones = 12 * (math.log(frequency / a4Freq) / math.log(2));
    final nearestSemitone = semitones.round();
    
    // A4는 A(9) + 4옥타브 = 57번째 키
    final a4KeyNumber = 57; // A4 = 57
    final keyNumber = a4KeyNumber + nearestSemitone;
    
    final octave = (keyNumber / 12).floor();
    final noteIndex = keyNumber % 12;
    
    if (noteIndex < 0 || noteIndex >= semitoneToNote.length) {
      return '';
    }
    
    return '${semitoneToNote[noteIndex]}$octave';
  }

  // 음계 이름에서 주파수 계산
  static double noteNameToFrequency(String noteName, double a4Freq) {
    if (noteName.isEmpty) return 0.0;
    
    // 노트명과 옥타브 분리
    final noteMatch = RegExp(r'([A-G][#b]?)(\d+)').firstMatch(noteName);
    if (noteMatch == null) return 0.0;
    
    final noteStr = noteMatch.group(1)!;
    final octave = int.tryParse(noteMatch.group(2)!) ?? 4;
    
    final semitone = noteToSemitone[noteStr];
    if (semitone == null) return 0.0;
    
    // A4를 기준으로 키 번호 계산
    final keyNumber = octave * 12 + semitone;
    final a4KeyNumber = 57; // A4 = 57
    
    final semitoneDiff = keyNumber - a4KeyNumber;
    return a4Freq * math.pow(2, semitoneDiff / 12.0);
  }

  // 스케일 생성
  static List<Map<String, dynamic>> generateScale(
    String rootKey, 
    String scaleType, 
    int octaves,
    double a4Freq,
  ) {
    final notes = <Map<String, dynamic>>[];
    
    // 키 정리 (C#/Db → C#)
    final cleanKey = rootKey.split('/')[0];
    final rootSemitone = noteToSemitone[cleanKey];
    if (rootSemitone == null) return notes;
    
    final pattern = scalePatterns[scaleType];
    if (pattern == null) return notes;
    
    // 시작 옥타브 계산 (C4부터 시작)
    const startOctave = 4;
    
    for (int octave = 0; octave < octaves; octave++) {
      for (int patternIndex = 0; patternIndex < pattern.length; patternIndex++) {
        final semitoneOffset = pattern[patternIndex];
        final totalSemitone = rootSemitone + semitoneOffset;
        final noteIndex = totalSemitone % 12;
        final currentOctave = startOctave + octave + (totalSemitone ~/ 12);
        
        final noteName = '${semitoneToNote[noteIndex]}$currentOctave';
        final frequency = noteNameToFrequency(noteName, a4Freq);
        
        notes.add({
          'note': noteName,
          'frequency': frequency,
          'semitone': totalSemitone,
          'octave': currentOctave,
        });
        
        // 마지막 옥타브의 첫 번째 음 추가 (완성된 스케일을 위해)
        if (octave == octaves - 1 && patternIndex == 0) {
          final nextOctaveNote = '${semitoneToNote[noteIndex]}${currentOctave + 1}';
          final nextFrequency = noteNameToFrequency(nextOctaveNote, a4Freq);
          notes.add({
            'note': nextOctaveNote,
            'frequency': nextFrequency,
            'semitone': totalSemitone + 12,
            'octave': currentOctave + 1,
          });
        }
      }
    }
    
    // 중복 제거 및 정렬
    final uniqueNotes = <Map<String, dynamic>>[];
    final addedFrequencies = <double>{};
    
    for (final note in notes) {
      final freq = note['frequency'] as double;
      if (!addedFrequencies.contains(freq)) {
        addedFrequencies.add(freq);
        uniqueNotes.add(note);
      }
    }
    
    // 주파수별 정렬
    uniqueNotes.sort((a, b) => 
      (a['frequency'] as double).compareTo(b['frequency'] as double));
    
    return uniqueNotes;
  }

  // 센트 계산
  static double calculateCents(double actualFreq, double expectedFreq) {
    if (actualFreq <= 0 || expectedFreq <= 0) return 0.0;
    return 1200 * (math.log(actualFreq / expectedFreq) / math.log(2));
  }

  // 센트를 읽기 쉬운 문자열로 변환
  static String centsToString(double cents) {
    final absCents = cents.abs();
    final sign = cents >= 0 ? '+' : '-';
    
    if (absCents < 1.0) {
      return '0¢';
    } else if (absCents < 10.0) {
      return '$sign${absCents.toStringAsFixed(1)}¢';
    } else {
      return '$sign${absCents.round()}¢';
    }
  }

  // 주파수를 가장 가까운 음표로 스냅
  static Map<String, dynamic> snapToNearestNote(
    double frequency, 
    double a4Freq,
  ) {
    if (frequency <= 0) {
      return {
        'note': '',
        'frequency': 0.0,
        'cents': 0.0,
      };
    }
    
    // A4를 기준으로 반음 수 계산
    final exactSemitones = 12 * (math.log(frequency / a4Freq) / math.log(2));
    final nearestSemitone = exactSemitones.round();
    
    // 가장 가까운 음표의 주파수 계산
    final nearestFreq = a4Freq * math.pow(2, nearestSemitone / 12.0);
    
    // 음표 이름 계산
    final a4KeyNumber = 57; // A4 = 57번째 키
    final keyNumber = a4KeyNumber + nearestSemitone;
    final octave = (keyNumber / 12).floor();
    final noteIndex = keyNumber % 12;
    
    String noteName = '';
    if (noteIndex >= 0 && noteIndex < semitoneToNote.length) {
      noteName = '${semitoneToNote[noteIndex]}$octave';
    }
    
    // 센트 차이 계산
    final cents = calculateCents(frequency, nearestFreq);
    
    return {
      'note': noteName,
      'frequency': nearestFreq,
      'cents': cents,
      'originalFrequency': frequency,
    };
  }

  // 지원되는 키 목록 반환
  static List<String> getSupportedKeys() {
    return [
      'C', 'C#/Db', 'D', 'D#/Eb', 'E', 'F', 
      'F#/Gb', 'G', 'G#/Ab', 'A', 'A#/Bb', 'B'
    ];
  }

  // 지원되는 스케일 타입 목록 반환
  static List<String> getSupportedScaleTypes() {
    return scalePatterns.keys.toList();
  }

  // 스케일 패턴 정보 반환
  static Map<String, dynamic>? getScaleInfo(String scaleType) {
    final pattern = scalePatterns[scaleType];
    if (pattern == null) return null;
    
    return {
      'name': scaleType,
      'pattern': pattern,
      'steps': pattern.length,
      'intervalPattern': _getIntervalPattern(pattern),
    };
  }

  // 인터벌 패턴 계산 (각 음 사이의 반음 수)
  static List<int> _getIntervalPattern(List<int> pattern) {
    final intervals = <int>[];
    for (int i = 1; i < pattern.length; i++) {
      intervals.add(pattern[i] - pattern[i - 1]);
    }
    return intervals;
  }
  
  // frequencyToNote 메서드 추가 (기본 A4 = 440Hz)
  static String frequencyToNote(double frequency) {
    return frequencyToNoteName(frequency, 440.0);
  }
}