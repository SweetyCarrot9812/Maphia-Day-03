import 'package:flutter/material.dart';
import '../models/concept.dart';
import '../services/concept_service.dart';
import '../theme/app_theme.dart';

/// 개념 학습 화면
class ConceptLearningScreen extends StatefulWidget {
  final String subjectCode;
  final String subjectName;
  
  const ConceptLearningScreen({
    super.key,
    required this.subjectCode,
    required this.subjectName,
  });

  @override
  State<ConceptLearningScreen> createState() => _ConceptLearningScreenState();
}

class _ConceptLearningScreenState extends State<ConceptLearningScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<Concept> _availableConcepts = [];
  List<Concept> _learnedConcepts = [];
  List<Concept> _reviewConcepts = [];
  ConceptLearningStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConceptData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConceptData() async {
    setState(() => _isLoading = true);
    
    try {
      final available = await ConceptService.getAvailableConcepts(widget.subjectCode);
      final learned = await ConceptService.getConceptsBySubject(widget.subjectCode)
          .then((concepts) => concepts.where((c) => c.isLearned).toList());
      final review = await ConceptService.getConceptsForReview();
      final stats = await ConceptService.getConceptStats(widget.subjectCode);
      
      setState(() {
        _availableConcepts = available;
        _learnedConcepts = learned;
        _reviewConcepts = review.where((c) => c.subjectCode == widget.subjectCode).toList();
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('개념 데이터 로드 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.subjectName} 개념 학습',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: _isLoading ? null : PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // 진행률 표시
              _buildProgressHeader(),
              
              // 탭바
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.play_arrow),
                    text: '학습하기 (${_availableConcepts.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.check_circle),
                    text: '완료됨 (${_learnedConcepts.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.refresh),
                    text: '복습 (${_reviewConcepts.length})',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLearningTab(),
                _buildLearnedTab(),
                _buildReviewTab(),
              ],
            ),
    );
  }

  Widget _buildProgressHeader() {
    if (_stats == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('전체', '${_stats!.totalConcepts}개', Icons.library_books),
              _buildStatItem('학습완료', '${_stats!.learnedConcepts}개', Icons.check_circle),
              _buildStatItem('진행률', '${(_stats!.progressRate * 100).toInt()}%', Icons.trending_up),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _stats!.progressRate,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLearningTab() {
    return RefreshIndicator(
      onRefresh: _loadConceptData,
      child: _availableConcepts.isEmpty
          ? _buildEmptyState(
              '학습 가능한 개념이 없습니다',
              '모든 개념을 완료했거나 선수 개념을 먼저 학습해주세요.',
              Icons.school,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableConcepts.length,
              itemBuilder: (context, index) {
                final concept = _availableConcepts[index];
                return _buildConceptCard(concept, ConceptCardType.learn);
              },
            ),
    );
  }

  Widget _buildLearnedTab() {
    return _learnedConcepts.isEmpty
        ? _buildEmptyState(
            '완료한 개념이 없습니다',
            '개념 학습을 시작해보세요.',
            Icons.psychology,
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _learnedConcepts.length,
            itemBuilder: (context, index) {
              final concept = _learnedConcepts[index];
              return _buildConceptCard(concept, ConceptCardType.learned);
            },
          );
  }

  Widget _buildReviewTab() {
    return RefreshIndicator(
      onRefresh: _loadConceptData,
      child: _reviewConcepts.isEmpty
          ? _buildEmptyState(
              '복습할 개념이 없습니다',
              '복습이 필요한 개념이 있을 때 여기에 표시됩니다.',
              Icons.refresh,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reviewConcepts.length,
              itemBuilder: (context, index) {
                final concept = _reviewConcepts[index];
                return _buildConceptCard(concept, ConceptCardType.review);
              },
            ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConceptCard(Concept concept, ConceptCardType type) {
    Color cardColor;
    Color accentColor;
    IconData actionIcon;
    String actionText;
    
    switch (type) {
      case ConceptCardType.learn:
        cardColor = Colors.blue[50]!;
        accentColor = Colors.blue;
        actionIcon = Icons.play_arrow;
        actionText = '학습하기';
        break;
      case ConceptCardType.learned:
        cardColor = Colors.green[50]!;
        accentColor = Colors.green;
        actionIcon = Icons.visibility;
        actionText = '복습하기';
        break;
      case ConceptCardType.review:
        cardColor = Colors.orange[50]!;
        accentColor = Colors.orange;
        actionIcon = Icons.refresh;
        actionText = '복습하기';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getDifficultyIcon(concept.difficulty),
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        concept.conceptName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildDifficultyBadge(concept.difficulty),
                          const SizedBox(width: 8),
                          _buildImportanceBadge(concept.importance),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 내용
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concept.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (concept.keywords.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: concept.keywords.take(4).map((keyword) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        keyword,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // 액션 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleConceptAction(concept, type),
                    icon: Icon(actionIcon, size: 20),
                    label: Text(actionText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    
    switch (difficulty) {
      case 'easy':
        color = Colors.green;
        label = '기초';
        break;
      case 'medium':
        color = Colors.orange;
        label = '중급';
        break;
      case 'hard':
        color = Colors.red;
        label = '고급';
        break;
      default:
        color = Colors.grey;
        label = difficulty;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImportanceBadge(int importance) {
    final stars = '★' * importance + '☆' * (5 - importance);
    return Text(
      stars,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.amber,
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help;
    }
  }

  void _handleConceptAction(Concept concept, ConceptCardType type) {
    switch (type) {
      case ConceptCardType.learn:
        _showConceptDetail(concept);
        break;
      case ConceptCardType.learned:
      case ConceptCardType.review:
        _showConceptReview(concept);
        break;
    }
  }

  void _showConceptDetail(Concept concept) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildConceptDetailSheet(concept),
    );
  }

  void _showConceptReview(Concept concept) {
    // 복습 모드로 개념 상세 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildConceptDetailSheet(concept, isReview: true),
    );
  }

  Widget _buildConceptDetailSheet(Concept concept, {bool isReview = false}) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 헤더
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getDifficultyIcon(concept.difficulty),
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            concept.conceptName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildDifficultyBadge(concept.difficulty),
                              const SizedBox(width: 8),
                              _buildImportanceBadge(concept.importance),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 내용
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailSection('개념 설명', concept.description, Icons.description),
                    
                    if (concept.keywords.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildKeywordsSection(concept.keywords),
                    ],
                    
                    if (concept.prerequisites.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildRelatedConceptsSection('선수 개념', concept.prerequisites, Colors.orange),
                    ],
                    
                    if (concept.followUps.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildRelatedConceptsSection('후속 개념', concept.followUps, Colors.blue),
                    ],
                  ],
                ),
              ),
              
              // 액션 버튼들
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (!isReview) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ConceptService.markConceptAsLearned(concept.conceptCode);
                            Navigator.pop(context);
                            _loadConceptData();
                            _showCompletionMessage(concept.conceptName);
                          },
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text('학습 완료'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ConceptService.completeConceptReview(concept.conceptCode, true);
                            Navigator.pop(context);
                            _loadConceptData();
                            _showReviewCompleteMessage(concept.conceptName);
                          },
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text('복습 성공'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ConceptService.completeConceptReview(concept.conceptCode, false);
                            Navigator.pop(context);
                            _loadConceptData();
                          },
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('다시 복습'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeywordsSection(List<String> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.label, size: 20, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              '핵심 키워드',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((keyword) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              keyword,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildRelatedConceptsSection(String title, List<String> conceptCodes, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_tree, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...conceptCodes.map((code) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            code, // 실제로는 개념명을 조회해서 표시
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        )),
      ],
    );
  }

  void _showCompletionMessage(String conceptName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 "$conceptName" 학습을 완료했습니다!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showReviewCompleteMessage(String conceptName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "$conceptName" 복습을 완료했습니다!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

enum ConceptCardType { learn, learned, review }