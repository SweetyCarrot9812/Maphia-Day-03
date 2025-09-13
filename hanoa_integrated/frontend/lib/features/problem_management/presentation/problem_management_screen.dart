import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../models/problem.dart';
import '../../../services/database_service.dart';

class ProblemManagementScreen extends ConsumerStatefulWidget {
  final String category;

  const ProblemManagementScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<ProblemManagementScreen> createState() => _ProblemManagementScreenState();
}

class _ProblemManagementScreenState extends ConsumerState<ProblemManagementScreen> {
  List<Problem> _problems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDifficulty = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadProblems();
  }

  Future<void> _loadProblems() async {
    setState(() => _isLoading = true);
    
    try {
      final problems = await DatabaseService.instance.getProblems();
      final filteredProblems = problems.where((p) {
        if (widget.category == 'nursing' && p.type != ProblemType.nursing) return false;
        if (widget.category == 'essay' && p.type != ProblemType.essay) return false;
        return true;
      }).toList();
      
      setState(() {
        _problems = filteredProblems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문제 로드 실패: $e')),
        );
      }
    }
  }

  List<Problem> get _filteredProblems {
    return _problems.where((problem) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!problem.title.toLowerCase().contains(query) &&
            !problem.content.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Difficulty filter
      if (_selectedDifficulty != 'all' && problem.difficulty.name != _selectedDifficulty) {
        return false;
      }
      
      // Status filter
      if (_selectedStatus != 'all' && problem.status.name != _selectedStatus) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProblemsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateProblemDialog,
        icon: const Icon(Icons.add),
        label: Text(widget.category == 'nursing' ? '새 문제 생성' : 'Essay 생성'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader() {
    final title = widget.category == 'nursing' ? '간호학 객관식 문제' : 'Essay/Simulation';
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.category == 'nursing' ? Icons.quiz : Icons.assignment,
                size: 32,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.category == 'nursing' 
                ? 'AI를 활용한 간호학 객관식 문제 생성 및 관리'
                : 'Essay 형태 문제와 시뮬레이션 케이스 관리',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: '문제 제목이나 내용으로 검색...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Filter row
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownFilter(
                      label: '난이도',
                      value: _selectedDifficulty,
                      items: const [
                        {'value': 'all', 'label': '전체'},
                        {'value': 'beginner', 'label': '초급'},
                        {'value': 'intermediate', 'label': '중급'},
                        {'value': 'advanced', 'label': '고급'},
                        {'value': 'expert', 'label': '전문'},
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value ?? 'all';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownFilter(
                      label: '상태',
                      value: _selectedStatus,
                      items: const [
                        {'value': 'all', 'label': '전체'},
                        {'value': 'draft', 'label': '초안'},
                        {'value': 'review', 'label': '검토중'},
                        {'value': 'approved', 'label': '승인'},
                        {'value': 'published', 'label': '출간'},
                        {'value': 'archived', 'label': '보관'},
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value ?? 'all';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedDifficulty = 'all';
                        _selectedStatus = 'all';
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('초기화'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildProblemsList() {
    final filteredProblems = _filteredProblems;
    
    if (filteredProblems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedDifficulty != 'all' || _selectedStatus != 'all'
                  ? '검색 조건에 맞는 문제가 없습니다'
                  : '아직 생성된 문제가 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새 문제를 생성해보세요!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '총 ${filteredProblems.length}개의 문제',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProblems.length,
              itemBuilder: (context, index) {
                final problem = filteredProblems[index];
                return _buildProblemCard(problem);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(Problem problem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showProblemDetail(problem),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      problem.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(problem.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                problem.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.signal_cellular_alt, _getDifficultyText(problem.difficulty)),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.category, _getTypeText(problem.type)),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.schedule, _formatDate(problem.createdAt)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showEditProblemDialog(problem),
                    icon: const Icon(Icons.edit),
                    tooltip: '편집',
                  ),
                  IconButton(
                    onPressed: () => _confirmDeleteProblem(problem),
                    icon: const Icon(Icons.delete),
                    tooltip: '삭제',
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProblemStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case ProblemStatus.draft:
        color = Colors.grey;
        text = '초안';
        break;
      case ProblemStatus.review:
        color = Colors.orange;
        text = '검토중';
        break;
      case ProblemStatus.approved:
        color = Colors.blue;
        text = '승인';
        break;
      case ProblemStatus.published:
        color = AppTheme.successGreen;
        text = '출간';
        break;
      case ProblemStatus.archived:
        color = Colors.grey.shade600;
        text = '보관';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '고급';
      case Difficulty.expert:
        return '전문';
    }
  }

  String _getTypeText(ProblemType type) {
    switch (type) {
      case ProblemType.nursing:
        return '간호학';
      case ProblemType.essay:
        return 'Essay';
      case ProblemType.simulation:
        return 'Simulation';
      case ProblemType.multiple_choice:
        return '객관식';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showProblemDetail(Problem problem) {
    context.push('/problem-detail/${problem.id}');
  }

  void _showCreateProblemDialog() {
    _showProblemDialog();
  }

  void _showEditProblemDialog(Problem problem) {
    _showProblemDialog(problem: problem);
  }

  void _showProblemDialog({Problem? problem}) {
    showDialog(
      context: context,
      builder: (context) => _ProblemDialog(
        category: widget.category,
        problem: problem,
        onSaved: () {
          Navigator.of(context).pop();
          _loadProblems();
        },
      ),
    );
  }

  void _confirmDeleteProblem(Problem problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문제 삭제'),
        content: Text('정말로 "${problem.title}"을(를) 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await DatabaseService.instance.deleteProblem(problem.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _loadProblems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('문제가 삭제되었습니다')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _ProblemDialog extends StatefulWidget {
  final String category;
  final Problem? problem;
  final VoidCallback onSaved;

  const _ProblemDialog({
    required this.category,
    this.problem,
    required this.onSaved,
  });

  @override
  State<_ProblemDialog> createState() => _ProblemDialogState();
}

class _ProblemDialogState extends State<_ProblemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _explanationController = TextEditingController();
  
  late Difficulty _selectedDifficulty;
  late ProblemStatus _selectedStatus;
  late ProblemType _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.problem != null) {
      _titleController.text = widget.problem!.title;
      _contentController.text = widget.problem!.content;
      _explanationController.text = widget.problem!.explanation ?? '';
      _selectedDifficulty = widget.problem!.difficulty;
      _selectedStatus = widget.problem!.status;
      _selectedType = widget.problem!.type;
    } else {
      _selectedDifficulty = Difficulty.intermediate;
      _selectedStatus = ProblemStatus.draft;
      _selectedType = widget.category == 'nursing' ? ProblemType.nursing : ProblemType.essay;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.problem != null;
    
    return AlertDialog(
      title: Text(isEdit ? '문제 편집' : '새 문제 생성'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '문제 제목',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '제목을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '문제 내용',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '내용을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(
                    labelText: '해설 (선택사항)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Difficulty>(
                        initialValue: _selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: '난이도',
                          border: OutlineInputBorder(),
                        ),
                        items: Difficulty.values.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(_getDifficultyText(difficulty)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<ProblemStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: '상태',
                          border: OutlineInputBorder(),
                        ),
                        items: ProblemStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProblem,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? '수정' : '생성'),
        ),
      ],
    );
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '고급';
      case Difficulty.expert:
        return '전문';
    }
  }

  String _getStatusText(ProblemStatus status) {
    switch (status) {
      case ProblemStatus.draft:
        return '초안';
      case ProblemStatus.review:
        return '검토중';
      case ProblemStatus.approved:
        return '승인';
      case ProblemStatus.published:
        return '출간';
      case ProblemStatus.archived:
        return '보관';
    }
  }

  Future<void> _saveProblem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isEdit = widget.problem != null;
      
      if (isEdit) {
        final updatedProblem = widget.problem!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          explanation: _explanationController.text.trim().isEmpty 
              ? null 
              : _explanationController.text.trim(),
          difficulty: _selectedDifficulty,
          status: _selectedStatus,
          updatedAt: DateTime.now(),
        );
        await DatabaseService.instance.updateProblem(updatedProblem);
      } else {
        final newProblem = Problem()
          ..problemId = 'prob_${DateTime.now().millisecondsSinceEpoch}'
          ..title = _titleController.text.trim()
          ..content = _contentController.text.trim()
          ..explanation = _explanationController.text.trim().isEmpty 
              ? null 
              : _explanationController.text.trim()
          ..type = _selectedType
          ..difficulty = _selectedDifficulty
          ..status = _selectedStatus
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        
        await DatabaseService.instance.createProblem(newProblem);
      }

      widget.onSaved();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? '문제가 수정되었습니다' : '문제가 생성되었습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}