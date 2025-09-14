import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/question.dart';

class ClintestService extends ChangeNotifier {
  static final ClintestService _instance = ClintestService._internal();
  factory ClintestService() => _instance;
  ClintestService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clintest_questions';
  final String _jobCollection = 'analysis_jobs';

  List<Question> _questions = [];
  bool _isLoading = false;
  String? _error;

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 간호학 과목 목록
  static const List<String> categories = [
    '성인간호학',
    '모성간호학',
    '아동간호학',
    '지역사회간호학',
    '정신간호학',
    '간호관리학',
    '기본간호학',
    '보건의약법규',
  ];

  // 난이도 목록
  static const List<String> difficulties = [
    'easy',
    'medium',
    'hard',
  ];

  // 문제 추가
  Future<String?> addQuestion(Question question) async {
    try {
      _setLoading(true);
      _setError(null);

      // 중복 검사
      final isDuplicate = await _checkDuplicate(question);
      if (isDuplicate) {
        _setError('이미 존재하는 문제입니다.');
        return null;
      }

      // Firestore에 저장
      final docRef = await _firestore.collection(_collection).add(question.toMap());

      // 로컬 리스트에 추가
      final newQuestion = question.copyWith(id: docRef.id);
      _questions.add(newQuestion);

      // GPT-5 분석을 위한 job 생성
      await _createAnalysisJob(docRef.id, newQuestion);

      notifyListeners();
      return docRef.id;
    } catch (e) {
      _setError('문제 저장 중 오류가 발생했습니다: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 문제 수정
  Future<bool> updateQuestion(String questionId, Question updatedQuestion) async {
    try {
      _setLoading(true);
      _setError(null);

      // 중복 검사 (자기 자신 제외)
      final isDuplicate = await _checkDuplicate(updatedQuestion, excludeId: questionId);
      if (isDuplicate) {
        _setError('이미 존재하는 문제입니다.');
        return false;
      }

      // Firestore 업데이트
      final updateData = updatedQuestion.toMap();
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collection).doc(questionId).update(updateData);

      // 로컬 리스트 업데이트
      final index = _questions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        _questions[index] = updatedQuestion.copyWith(
          id: questionId,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('문제 수정 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 문제 삭제
  Future<bool> deleteQuestion(String questionId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Firestore에서 삭제
      await _firestore.collection(_collection).doc(questionId).delete();

      // 로컬 리스트에서 제거
      _questions.removeWhere((q) => q.id == questionId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('문제 삭제 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 모든 문제 불러오기
  Future<void> loadQuestions() async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔍 전체 문제 로딩 시작');

      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      _questions = snapshot.docs
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();

      print('✅ 전체 문제 ${_questions.length}개 로드됨');

      // 디버그: 실제 저장된 모든 subject 값들 확인
      if (_questions.isNotEmpty) {
        final subjects = _questions.map((q) => q.subject).toSet();
        print('📋 데이터베이스의 모든 subject 값들: $subjects');
      }

      notifyListeners();
    } catch (e) {
      print('❌ 전체 문제 로딩 오류: $e');
      _setError('문제를 불러오는 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 과목별 문제 불러오기
  Future<void> loadQuestionsBySubject(String subject) async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔍 과목별 문제 로딩: $subject');

      final snapshot = await _firestore
          .collection(_collection)
          .where('subject', isEqualTo: subject)
          .orderBy('createdAt', descending: true)
          .get();

      _questions = snapshot.docs
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();

      print('✅ $subject 문제 ${_questions.length}개 로드됨');

      // 디버그: 실제 저장된 subject 값들 확인
      if (_questions.isNotEmpty) {
        final subjects = _questions.map((q) => q.subject).toSet();
        print('📋 실제 저장된 subject 값들: $subjects');
      }

      notifyListeners();
    } catch (e) {
      print('❌ 과목별 문제 로딩 오류: $e');
      _setError('문제를 불러오는 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 문제 검색
  Future<void> searchQuestions(String query) async {
    try {
      _setLoading(true);
      _setError(null);

      // Firestore는 full-text search를 지원하지 않으므로 클라이언트에서 필터링
      await loadQuestions();

      if (query.isNotEmpty) {
        _questions = _questions.where((question) {
          return question.questionText.toLowerCase().contains(query.toLowerCase()) ||
                 question.subject.toLowerCase().contains(query.toLowerCase()) ||
                 question.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('문제 검색 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 중복 검사
  Future<bool> _checkDuplicate(Question question, {String? excludeId}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('questionText', isEqualTo: question.questionText)
          .get();

      for (final doc in snapshot.docs) {
        if (excludeId != null && doc.id == excludeId) continue;

        final existingQuestion = Question.fromMap(doc.data(), doc.id);
        if (existingQuestion == question) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('중복 검사 중 오류: $e');
      return false;
    }
  }

  // 통계 정보 가져오기
  Future<Map<String, int>> getStatistics() async {
    try {
      await loadQuestions();

      final stats = <String, int>{};
      stats['total'] = _questions.length;

      for (final subject in categories) {
        stats[subject] = _questions.where((q) => q.subject == subject).length;
      }

      for (final difficulty in difficulties) {
        stats[difficulty] = _questions.where((q) => q.difficulty == difficulty).length;
      }

      return stats;
    } catch (e) {
      return {'total': 0};
    }
  }

  // 내부 메서드들
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) notifyListeners();
  }

  // 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// GPT-5 분석을 위한 job 생성
  Future<void> _createAnalysisJob(String questionId, Question question) async {
    try {
      final jobData = {
        'type': 'question_analysis',
        'status': 'pending',
        'questionId': questionId,
        'questionData': {
          'questionText': question.questionText,
          'choices': question.choices,
          'correctAnswer': question.correctAnswer,
          'subject': question.subject,
          'createdBy': question.createdBy,
        },
        'analysisRequests': [
          'difficulty_assessment', // 난이도 분석
          'concept_extraction',    // 개념 추출
          'explanation_generation', // 해설 생성
          'keyword_tagging',       // 키워드 태그 생성
          'similar_question_matching' // 유사 문제 매칭
        ],
        'aiModel': 'gpt-5',
        'priority': 'normal',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'results': {},
        'errors': {},
      };

      await _firestore.collection(_jobCollection).add(jobData);
      print('✅ 분석 job 생성 완료: $questionId');
    } catch (e) {
      print('❌ 분석 job 생성 실패: $e');
      // job 생성 실패는 문제 저장을 막지 않음
    }
  }
}