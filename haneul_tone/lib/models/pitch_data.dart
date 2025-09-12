import 'dart:convert';
import 'dart:math' as dart_math;

class PitchData {
  final int id;
  final int audioReferenceId;
  final List<double> pitchCurve;  // Hz 값들
  final List<double> timestamps;  // 시간 (초)
  final List<NoteSegment> noteSegments;  // 음표별 구간
  final double sampleRate;
  final DateTime createdAt;

  PitchData({
    required this.id,
    required this.audioReferenceId,
    required this.pitchCurve,
    required this.timestamps,
    required this.noteSegments,
    required this.sampleRate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audio_reference_id': audioReferenceId,
      'pitch_curve': jsonEncode(pitchCurve),
      'timestamps': jsonEncode(timestamps),
      'note_segments': jsonEncode(noteSegments.map((e) => e.toMap()).toList()),
      'sample_rate': sampleRate,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PitchData.fromMap(Map<String, dynamic> map) {
    return PitchData(
      id: map['id'],
      audioReferenceId: map['audio_reference_id'],
      pitchCurve: List<double>.from(jsonDecode(map['pitch_curve'])),
      timestamps: List<double>.from(jsonDecode(map['timestamps'])),
      noteSegments: (jsonDecode(map['note_segments']) as List)
          .map((e) => NoteSegment.fromMap(e))
          .toList(),
      sampleRate: map['sample_rate'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() => toMap();
  
  factory PitchData.fromJson(Map<String, dynamic> json) => PitchData.fromMap(json);

  // 피치를 센트(cents)로 변환
  List<double> getPitchInCents(double referenceFreq) {
    return pitchCurve.map((freq) {
      if (freq <= 0) return 0.0;
      return 1200 * (dart_math.log(freq / referenceFreq) / dart_math.log(2));
    }).toList();
  }

  // 특정 시간 구간의 평균 피치 계산
  double getAveragePitchInRange(double startTime, double endTime) {
    List<double> validPitches = [];
    for (int i = 0; i < timestamps.length; i++) {
      if (timestamps[i] >= startTime && timestamps[i] <= endTime && pitchCurve[i] > 0) {
        validPitches.add(pitchCurve[i]);
      }
    }
    if (validPitches.isEmpty) return 0.0;
    return validPitches.reduce((a, b) => a + b) / validPitches.length;
  }
}

class NoteSegment {
  final String noteName;  // 예: "C4", "D#4"
  final double startTime; // 시작 시간 (초)
  final double endTime;   // 끝 시간 (초)
  final double expectedFrequency; // 예상 주파수 (Hz)
  final double actualFrequency;   // 실제 평균 주파수 (Hz)

  NoteSegment({
    required this.noteName,
    required this.startTime,
    required this.endTime,
    required this.expectedFrequency,
    required this.actualFrequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'note_name': noteName,
      'start_time': startTime,
      'end_time': endTime,
      'expected_frequency': expectedFrequency,
      'actual_frequency': actualFrequency,
    };
  }

  factory NoteSegment.fromMap(Map<String, dynamic> map) {
    return NoteSegment(
      noteName: map['note_name'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      expectedFrequency: map['expected_frequency'],
      actualFrequency: map['actual_frequency'],
    );
  }

  // 정확도 계산 (센트 단위)
  double getAccuracyInCents() {
    if (actualFrequency <= 0 || expectedFrequency <= 0) return 0.0;
    return 1200 * (dart_math.log(actualFrequency / expectedFrequency) / dart_math.log(2));
  }
}