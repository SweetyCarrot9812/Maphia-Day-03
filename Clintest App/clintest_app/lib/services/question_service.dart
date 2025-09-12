import 'dart:convert';
import 'package:http/http.dart' as http;

class Question {
  final String id;
  final String subject;
  final String category;
  final List<String> tags;
  final String difficulty;
  final String type;
  final String stem;
  final List<String> choices;
  final int answer;
  final String explanation;
  final String source;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.subject,
    required this.category,
    required this.tags,
    required this.difficulty,
    required this.type,
    required this.stem,
    required this.choices,
    required this.answer,
    required this.explanation,
    required this.source,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] ?? '',
      subject: json['subject'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      difficulty: json['difficulty'] ?? 'medium',
      type: json['type'] ?? 'multiple_choice',
      stem: json['stem'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      answer: json['answer'] ?? 0,
      explanation: json['explanation'] ?? '',
      source: json['source'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class QuestionService {
  static const String baseUrl = 'http://localhost:3001';
  
  // 싱글톤 패턴
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  // 헤더 생성
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 모든 문제 가져오기 - MED 패키지 지원
  Future<List<Question>?> getAllQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/med/nursing/questions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['problems'] != null) {
          List<Question> questions = [];
          for (var questionJson in data['problems']) {
            try {
              questions.add(Question.fromJson(questionJson));
            } catch (e) {
              print('문제 파싱 오류: $e');
              // 개별 문제 파싱 실패해도 다른 문제들은 계속 로드
            }
          }
          return questions;
        }
      } else {
        print('문제 로드 실패: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('문제 로드 오류: $e');
      return null;
    }
  }

  // 과목별 문제 가져오기
  Future<List<Question>?> getQuestionsBySubject(String subject) async {
    try {
      final allQuestions = await getAllQuestions();
      if (allQuestions != null) {
        return allQuestions.where((q) => q.subject == subject).toList();
      }
      return null;
    } catch (e) {
      print('과목별 문제 로드 오류: $e');
      return null;
    }
  }

  // 난이도별 문제 가져오기
  Future<List<Question>?> getQuestionsByDifficulty(String difficulty) async {
    try {
      final allQuestions = await getAllQuestions();
      if (allQuestions != null) {
        return allQuestions.where((q) => q.difficulty == difficulty).toList();
      }
      return null;
    } catch (e) {
      print('난이도별 문제 로드 오류: $e');
      return null;
    }
  }

  // 랜덤 문제 가져오기
  Future<List<Question>?> getRandomQuestions({int count = 5}) async {
    try {
      final allQuestions = await getAllQuestions();
      if (allQuestions != null) {
        allQuestions.shuffle();
        return allQuestions.take(count).toList();
      }
      return null;
    } catch (e) {
      print('랜덤 문제 로드 오류: $e');
      return null;
    }
  }

  // 서버 연결 상태 확인
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('연결 확인 오류: $e');
      return false;
    }
  }

  // 과목 목록 가져오기
  Future<List<String>?> getSubjects() async {
    try {
      final allQuestions = await getAllQuestions();
      if (allQuestions != null) {
        final subjects = allQuestions.map((q) => q.subject).toSet().toList();
        subjects.sort();
        return subjects;
      }
      return null;
    } catch (e) {
      print('과목 목록 로드 오류: $e');
      return null;
    }
  }
}