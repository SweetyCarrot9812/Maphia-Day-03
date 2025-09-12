import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/question_data.dart';
import '../../shared/models/concept_data.dart';

class LocalStorageService {
  static const String _questionsKey = 'pending_questions';
  static const String _conceptsKey = 'pending_concepts';

  // 문제 데이터 관련 메서드
  static Future<void> saveQuestion(QuestionData question) async {
    final prefs = await SharedPreferences.getInstance();
    final questions = await getPendingQuestions();
    
    // 기존 문제 업데이트 또는 새로 추가
    final index = questions.indexWhere((q) => q.id == question.id);
    if (index != -1) {
      questions[index] = question;
    } else {
      questions.add(question);
    }

    final jsonList = questions.map((q) => q.toJson()).toList();
    await prefs.setString(_questionsKey, jsonEncode(jsonList));
  }

  static Future<List<QuestionData>> getPendingQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_questionsKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => QuestionData.fromJson(json)).toList();
    } catch (e) {
      print('문제 데이터 로드 실패: $e');
      return [];
    }
  }

  static Future<void> updateQuestionStatus(String questionId, QuestionStatus status) async {
    final questions = await getPendingQuestions();
    final index = questions.indexWhere((q) => q.id == questionId);
    
    if (index != -1) {
      questions[index] = questions[index].copyWith(status: status);
      await _saveQuestions(questions);
    }
  }

  static Future<void> deleteQuestion(String questionId) async {
    final questions = await getPendingQuestions();
    questions.removeWhere((q) => q.id == questionId);
    await _saveQuestions(questions);
  }

  // 개념 데이터 관련 메서드
  static Future<void> saveConcept(ConceptData concept) async {
    final prefs = await SharedPreferences.getInstance();
    final concepts = await getPendingConcepts();
    
    // 기존 개념 업데이트 또는 새로 추가
    final index = concepts.indexWhere((c) => c.id == concept.id);
    if (index != -1) {
      concepts[index] = concept;
    } else {
      concepts.add(concept);
    }

    final jsonList = concepts.map((c) => c.toJson()).toList();
    await prefs.setString(_conceptsKey, jsonEncode(jsonList));
  }

  static Future<List<ConceptData>> getPendingConcepts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_conceptsKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => ConceptData.fromJson(json)).toList();
    } catch (e) {
      print('개념 데이터 로드 실패: $e');
      return [];
    }
  }

  static Future<void> updateConceptStatus(String conceptId, ConceptStatus status) async {
    final concepts = await getPendingConcepts();
    final index = concepts.indexWhere((c) => c.id == conceptId);
    
    if (index != -1) {
      concepts[index] = concepts[index].copyWith(status: status);
      await _saveConcepts(concepts);
    }
  }

  static Future<void> deleteConcept(String conceptId) async {
    final concepts = await getPendingConcepts();
    concepts.removeWhere((c) => c.id == conceptId);
    await _saveConcepts(concepts);
  }

  // 이미지 파일 관리
  static Future<String> saveImageFile(File imageFile, String fileName) async {
    try {
      final directory = await _getImagesDirectory();
      final newPath = '${directory.path}/$fileName';
      final newFile = await imageFile.copy(newPath);
      return newFile.path;
    } catch (e) {
      print('이미지 저장 실패: $e');
      rethrow;
    }
  }

  static Future<Directory> _getImagesDirectory() async {
    const folderName = 'clintest_images';
    final directory = Directory(folderName);
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }

  // Private helper methods
  static Future<void> _saveQuestions(List<QuestionData> questions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = questions.map((q) => q.toJson()).toList();
    await prefs.setString(_questionsKey, jsonEncode(jsonList));
  }

  static Future<void> _saveConcepts(List<ConceptData> concepts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = concepts.map((c) => c.toJson()).toList();
    await prefs.setString(_conceptsKey, jsonEncode(jsonList));
  }

  // 통계 정보
  static Future<Map<String, int>> getStorageStats() async {
    final questions = await getPendingQuestions();
    final concepts = await getPendingConcepts();
    
    return {
      'totalQuestions': questions.length,
      'pendingQuestions': questions.where((q) => q.status == QuestionStatus.pending).length,
      'reviewedQuestions': questions.where((q) => q.status == QuestionStatus.reviewed).length,
      'syncedQuestions': questions.where((q) => q.status == QuestionStatus.synced).length,
      'totalConcepts': concepts.length,
      'pendingConcepts': concepts.where((c) => c.status == ConceptStatus.pending).length,
      'reviewedConcepts': concepts.where((c) => c.status == ConceptStatus.reviewed).length,
      'syncedConcepts': concepts.where((c) => c.status == ConceptStatus.synced).length,
    };
  }
}