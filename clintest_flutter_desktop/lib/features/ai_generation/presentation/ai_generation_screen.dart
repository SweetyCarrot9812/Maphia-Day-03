import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../services/ai_pipeline_service.dart';
import '../../../services/sync_management_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../shared/models/question_data.dart';
import '../../../shared/models/concept_data.dart';
import '../../sync_management/presentation/sync_management_screen.dart';

/// AI 문제 생성 화면
/// - 개념 입력 → AI 파이프라인 실행 → 결과 확인 → 수동 Firebase 동기화
class AiGenerationScreen extends ConsumerStatefulWidget {
  const AiGenerationScreen({super.key});

  @override
  ConsumerState<AiGenerationScreen> createState() => _AiGenerationScreenState();
}

class _AiGenerationScreenState extends ConsumerState<AiGenerationScreen> {
  final _conceptController = TextEditingController();
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SyncManagementService _syncService = SyncManagementService();
  
  List<String> _tags = []; // 자동 생성된 태그들
  List<ConceptData> _savedConcepts = [];
  List<QuestionData> _savedQuestions = [];
  bool _isLoadingData = true;
  
  GenerationResult? _generationResult;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _conceptController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      setState(() => _isLoadingData = true);
      
      final concepts = await LocalStorageService.getPendingConcepts();
      final questions = await LocalStorageService.getPendingQuestions();
      
      setState(() {
        _savedConcepts = concepts;
        _savedQuestions = questions;
        _isLoadingData = false;
      });
    } catch (e) {
      print('데이터 로드 실패: $e');
      setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('AI 문제 생성'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              _buildHeader(),
              SizedBox(height: 24.h),
              
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 왼쪽: 저장된 개념과 문제
                    Expanded(
                      flex: 1,
                      child: _buildSavedDataPanel(),
                    ),
                    
                    SizedBox(width: 24.w),
                    
                    // 가운데: 간단한 설정
                    Expanded(
                      flex: 1,
                      child: _buildSimpleSettingsPanel(),
                    ),
                    
                    SizedBox(width: 24.w),
                    
                    // 오른쪽: 결과 및 미리보기
                    Expanded(
                      flex: 2,
                      child: _buildResultPanel(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          size: 32.r,
          color: Colors.deepPurple,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI 문제 생성기 v3.1',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              'GPT-5가 저장된 데이터를 분석하여 자동으로 문제를 생성합니다',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const Spacer(),
        
        // 통계 표시
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                '저장된 데이터',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '개념 ${_savedConcepts.length}개 · 문제 ${_savedQuestions.length}개',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavedDataPanel() {
    if (_isLoadingData) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '저장된 데이터',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // 개념 섹션
          Text(
            '개념 (${_savedConcepts.length}개)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8.h),
          
          Expanded(
            flex: 1,
            child: _savedConcepts.isEmpty
                ? Center(
                    child: Text(
                      '저장된 개념이 없습니다',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _savedConcepts.length,
                    itemBuilder: (context, index) {
                      final concept = _savedConcepts[index];
                      return _buildConceptCard(concept);
                    },
                  ),
          ),

          SizedBox(height: 16.h),

          // 문제 섹션
          Text(
            '문제 (${_savedQuestions.length}개)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8.h),
          
          Expanded(
            flex: 1,
            child: _savedQuestions.isEmpty
                ? Center(
                    child: Text(
                      '저장된 문제가 없습니다',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _savedQuestions.length,
                    itemBuilder: (context, index) {
                      final question = _savedQuestions[index];
                      return _buildSavedQuestionCard(question);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSettingsPanel() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI 생성 설정',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // 자동 태그 시스템
          _buildTagSection(),
          SizedBox(height: 20.h),

          // 정보 카드
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue, size: 16.r),
                    SizedBox(width: 8.w),
                    Text(
                      'GPT-5 자동 분석',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '• 난이도: AI가 자동 판단\n• 문제수: 데이터량 기반 최적화\n• 문제유형: 개념별 맞춤 선택',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 생성 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating || (_savedConcepts.isEmpty && _savedQuestions.isEmpty) 
                  ? null 
                  : _generateQuestionsFromSavedData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: _isGenerating
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.auto_awesome, size: 20.r),
              label: Text(
                _isGenerating ? 'AI 분석 중...' : 'GPT-5로 문제 생성',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 개념 카드 생성
  Widget _buildConceptCard(ConceptData concept) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            concept.title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            concept.content.length > 50 
                ? '${concept.content.substring(0, 50)}...'
                : concept.content,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.blue.withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 저장된 문제 카드 생성
  Widget _buildSavedQuestionCard(QuestionData question) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.stem.length > 50 
                ? '${question.stem.substring(0, 50)}...'
                : question.stem,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  question.difficulty,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w500,
                    color: _getDifficultyColor(question.difficulty),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // GPT-5를 사용하여 저장된 데이터로부터 문제 생성
  Future<void> _generateQuestionsFromSavedData() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generationResult = null;
    });

    try {
      // 저장된 개념들을 텍스트로 결합
      final conceptTexts = _savedConcepts.map((c) => '${c.title}: ${c.content}').join('\n\n');
      
      // 저장된 문제들의 패턴 분석을 위한 텍스트
      final questionExamples = _savedQuestions.map((q) => 
        '문제: ${q.stem}\n정답: ${q.correctAnswer}\n난이도: ${q.difficulty}'
      ).join('\n\n');

      // 전체 텍스트 조합
      String combinedText = '';
      if (conceptTexts.isNotEmpty) {
        combinedText += '개념 정보:\n$conceptTexts';
      }
      if (questionExamples.isNotEmpty) {
        if (combinedText.isNotEmpty) combinedText += '\n\n';
        combinedText += '기존 문제 예시:\n$questionExamples';
      }

      // 태그 자동 생성
      await _generateTagsFromContent(combinedText);
      
      // AI 파이프라인 서비스 호출
      final pipelineService = ref.read(aiPipelineServiceProvider);
      final result = await pipelineService.generateFromConcept(
        conceptText: combinedText,
        subject: _tags.isNotEmpty ? _tags.first : 'AUTO', // 첫 번째 태그를 주제로 사용
        difficulty: 'AUTO', // GPT-5가 자동 결정
        questionCount: 0, // GPT-5가 자동 결정
        questionTypes: [], // GPT-5가 자동 결정
        includeImages: false,
      );

      setState(() {
        _generationResult = result;
        _isGenerating = false;
      });

      if (result.questions.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GPT-5가 ${result.questions.length}개 문제를 자동 생성했습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });
    }
  }

  Widget _buildResultPanel() {
    if (_isGenerating) {
      return _buildLoadingPanel();
    } else if (_generationResult != null) {
      return _buildResultView();
    } else if (_errorMessage != null) {
      return _buildErrorPanel();
    } else {
      return _buildEmptyPanel();
    }
  }

  Widget _buildLoadingPanel() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.deepPurple,
            strokeWidth: 3,
          ),
          SizedBox(height: 24.h),
          Text(
            'GPT-5가 데이터를 분석하여 문제를 생성 중입니다...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '자동 분석: 난이도, 문제수, 문제유형\n'
            '모델: GPT-5 Standard\n'
            '예상 시간: 30-60초',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final result = _generationResult!;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 결과 헤더
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'AI 생성 완료!',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getQualityColor(result.qualityScore).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '품질: ${_getQualityGrade(result.qualityScore)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: _getQualityColor(result.qualityScore),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 통계
          Row(
            children: [
              _buildStatChip('생성됨', result.questions.length.toString(), Colors.blue),
              SizedBox(width: 8.w),
              _buildStatChip('차단됨', result.blocked.length.toString(), Colors.red),
              SizedBox(width: 8.w),
              _buildStatChip('전체', result.totalGenerated.toString(), Colors.grey),
            ],
          ),
          SizedBox(height: 20.h),

          // 문제 목록
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '생성된 문제 (${result.questions.length}개)',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: result.questions.length,
                    itemBuilder: (context, index) {
                      final question = result.questions[index];
                      return _buildQuestionCard(question, index);
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 액션 버튼들
          Column(
            children: [
              // 첫 번째 줄: 새로 생성, 동기화 대기 목록에 추가
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _generationResult = null;
                          _errorMessage = null;
                        });
                      },
                      icon: Icon(Icons.refresh, size: 16.r),
                      label: const Text('새로 생성'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: result.questions.isEmpty ? null : () => _addToPendingSync(result.questions),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(Icons.add_to_queue, size: 16.r),
                      label: const Text('동기화 대기 목록에 추가'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // 두 번째 줄: 동기화 관리 화면으로 이동
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToSyncManagement(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(Icons.sync, size: 16.r),
                  label: const Text('통합 동기화 관리 화면으로 이동'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPanel() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.r,
            color: Colors.red,
          ),
          SizedBox(height: 24.h),
          Text(
            'AI 생성 실패',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            icon: Icon(Icons.refresh, size: 16.r),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPanel() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 48.r,
            color: Colors.grey,
          ),
          SizedBox(height: 24.h),
          Text(
            'AI 문제 생성 준비',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '왼쪽에서 개념을 입력하고\n"AI 문제 생성" 버튼을 클릭하세요',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionData question, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  question.stem.length > 80 
                      ? '${question.stem.substring(0, 80)}...'
                      : question.stem,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(question.difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  question.difficulty,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: _getDifficultyColor(question.difficulty),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '정답: ${question.correctAnswer}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _addToPendingSync(List<QuestionData> questions) async {
    try {
      await _syncService.addMultipleToPendingSync(questions);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${questions.length}개 문제를 동기화 대기 목록에 추가했습니다'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: '관리 화면으로',
            onPressed: _navigateToSyncManagement,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('동기화 대기 목록 추가 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToSyncManagement() {
    context.go('/sync-management');
  }


  Color _getQualityColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getQualityGrade(double score) {
    if (score >= 0.8) return 'A';
    if (score >= 0.6) return 'B';
    if (score >= 0.4) return 'C';
    return 'D';
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'HIGH': return Colors.red;
      case 'MID': return Colors.orange;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  // 태그 섹션 UI 빌드
  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 18.r,
              color: Colors.deepPurple,
            ),
            SizedBox(width: 8.w),
            Text(
              '자동 생성 태그',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // 자동 생성된 태그들
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _tags.map((tag) => _buildTagChip(
              tag,
              isRemovable: true,
              onRemove: () => _removeTag(tag),
            )).toList(),
          ),
        
        // 태그가 없을 때 메시지
        if (_tags.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 24.r,
                  color: Colors.grey,
                ),
                SizedBox(height: 8.h),
                Text(
                  'AI가 저장된 데이터를 분석하여\n자동으로 관련 태그를 생성합니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        
        SizedBox(height: 12.h),
        
        // 수동 태그 입력
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: '수동으로 태그 추가',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addManualTag,
                  ),
                ),
                onSubmitted: (_) => _addManualTag(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 태그 칩 위젯
  Widget _buildTagChip(String tag, {bool isRemovable = false, VoidCallback? onRemove}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label,
            size: 14.r,
            color: Colors.deepPurple,
          ),
          SizedBox(width: 4.w),
          Text(
            tag,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRemovable) ...[
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14.r,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 수동 태그 추가
  void _addManualTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  // 태그 제거
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  // 컨텐츠에서 자동 태그 생성
  Future<void> _generateTagsFromContent(String content) async {
    // 간단한 키워드 추출 (실제로는 AI API를 사용할 수 있음)
    final List<String> medicalKeywords = [
      '내과', '외과', '소아과', '산부인과', '정신과', '응급의학',
      '간호학', '성인간호', '모성간호', '아동간호', '정신간호',
      '심장', '뇌혈관', '호흡기', '소화기', '내분비', '신장',
      '감염', '종양', '외상', '수술', '마취', '중환자',
      '진단', '치료', '검사', '처방', '모니터링', '간호중재'
    ];
    
    final generatedTags = <String>[];
    final lowerContent = content.toLowerCase();
    
    for (final keyword in medicalKeywords) {
      if (lowerContent.contains(keyword.toLowerCase())) {
        generatedTags.add(keyword);
      }
    }
    
    // 최대 5개 태그로 제한
    setState(() {
      _tags = generatedTags.take(5).toList();
    });
  }
}