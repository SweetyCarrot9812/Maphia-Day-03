import 'package:flutter/material.dart';
import '../services/export_service.dart';
import '../models/session_v2.dart';

/// 내보내기 다이얼로그
/// 
/// 사용자가 내보내기 형식과 옵션을 선택할 수 있는 다이얼로그
class ExportDialog extends StatefulWidget {
  final List<SessionV2> sessions;
  final GlobalKey? chartKey;
  final String? chartTitle;

  const ExportDialog({
    Key? key,
    required this.sessions,
    this.chartKey,
    this.chartTitle,
  }) : super(key: key);

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final ExportService _exportService = ExportService();
  
  ExportFormat _selectedFormat = ExportFormat.csv;
  bool _includeDetailedAnalysis = true;
  bool _useCustomPath = false;
  double _imageQuality = 2.0;
  bool _isExporting = false;
  
  final List<ExportFormatOption> _formatOptions = [
    ExportFormatOption(
      format: ExportFormat.csv,
      title: 'CSV 파일',
      description: '표 형식 데이터 (Excel에서 열기 가능)',
      icon: Icons.table_chart,
      fileSize: '작음 (~50KB)',
      pros: ['Excel/Google Sheets 호환', '데이터 분석 용이', '작은 파일 크기'],
      cons: ['기본 정보만 포함', '차트/이미지 없음'],
    ),
    ExportFormatOption(
      format: ExportFormat.json,
      title: 'JSON 파일',
      description: '구조화된 데이터 (프로그래밍 친화적)',
      icon: Icons.code,
      fileSize: '중간 (~200KB)',
      pros: ['모든 데이터 포함', '프로그래밍 활용 가능', '정확한 구조'],
      cons: ['일반 사용자에게 복잡', '특별한 뷰어 필요'],
    ),
    ExportFormatOption(
      format: ExportFormat.png,
      title: 'PNG 이미지',
      description: '차트를 이미지로 저장',
      icon: Icons.image,
      fileSize: '중간 (~500KB)',
      pros: ['시각적 표현', '공유 용이', '인쇄 가능'],
      cons: ['차트만 포함', '데이터 편집 불가'],
      requiresChart: true,
    ),
    ExportFormatOption(
      format: ExportFormat.html,
      title: '종합 리포트',
      description: '웹 페이지 형태의 완전한 리포트',
      icon: Icons.description,
      fileSize: '큰 (~1MB)',
      pros: ['완전한 리포트', '웹브라우저에서 열기', '인쇄 최적화'],
      cons: ['큰 파일 크기', '로딩 시간 필요'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormatSelection(),
                    const SizedBox(height: 20),
                    _buildFormatDetails(),
                    const SizedBox(height: 20),
                    _buildOptions(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.file_download,
            color: Colors.blue.shade700,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '데이터 내보내기',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.sessions.length}개 세션 데이터',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내보내기 형식 선택',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...ExportFormat.values.map((format) {
          final option = _formatOptions.firstWhere((o) => o.format == format);
          final isDisabled = option.requiresChart && widget.chartKey == null;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<ExportFormat>(
              value: format,
              groupValue: _selectedFormat,
              onChanged: isDisabled ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              title: Row(
                children: [
                  Icon(
                    option.icon,
                    color: isDisabled ? Colors.grey : null,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDisabled ? Colors.grey : null,
                          ),
                        ),
                        Text(
                          option.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDisabled ? Colors.grey : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDisabled ? Colors.grey.shade200 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      option.fileSize,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDisabled ? Colors.grey : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFormatDetails() {
    final selectedOption = _formatOptions.firstWhere((o) => o.format == _selectedFormat);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(selectedOption.icon, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '${selectedOption.title} 세부사항',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '장점',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    ...selectedOption.pros.map((pro) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check, color: Colors.green, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pro,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '단점',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    ...selectedOption.cons.map((con) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              con,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가 옵션',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // JSON 전용 옵션
        if (_selectedFormat == ExportFormat.json)
          CheckboxListTile(
            title: const Text('상세 분석 데이터 포함'),
            subtitle: const Text('포먼트, DTW 정렬, 세그먼트 분석 등 포함'),
            value: _includeDetailedAnalysis,
            onChanged: (value) {
              setState(() {
                _includeDetailedAnalysis = value ?? true;
              });
            },
          ),
        
        // PNG 전용 옵션
        if (_selectedFormat == ExportFormat.png) ...[
          ListTile(
            title: const Text('이미지 품질'),
            subtitle: Text('현재: ${_imageQuality == 1.0 ? '표준' : _imageQuality == 2.0 ? '고화질' : '초고화질'}'),
          ),
          Slider(
            value: _imageQuality,
            min: 1.0,
            max: 3.0,
            divisions: 2,
            labels: const {1.0: '표준', 2.0: '고화질', 3.0: '초고화질'},
            onChanged: (value) {
              setState(() {
                _imageQuality = value;
              });
            },
          ),
        ],
        
        // 공통 옵션
        CheckboxListTile(
          title: const Text('저장 위치 직접 선택'),
          subtitle: const Text('기본값: Documents/HaneulTone 폴더'),
          value: _useCustomPath,
          onChanged: (value) {
            setState(() {
              _useCustomPath = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _performExport,
          icon: _isExporting 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.download),
          label: Text(_isExporting ? '내보내는 중...' : '내보내기'),
        ),
      ],
    );
  }

  Future<void> _performExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      String? customPath;
      if (_useCustomPath) {
        final suggestedName = _getSuggestedFileName();
        customPath = await _exportService.pickSaveLocation(
          suggestedFileName: suggestedName,
        );
        if (customPath == null) {
          // 사용자가 취소함
          setState(() {
            _isExporting = false;
          });
          return;
        }
      }

      final config = ExportConfig(
        format: _selectedFormat,
        includeDetailedAnalysis: _includeDetailedAnalysis,
        chartKey: widget.chartKey,
        chartTitle: widget.chartTitle,
        imageQuality: _imageQuality,
      );

      final result = await _exportService.exportCustom(
        sessions: widget.sessions,
        config: config,
        customPath: customPath != null ? _extractDirectoryPath(customPath) : null,
      );

      if (result.success) {
        _showSuccessDialog(result);
      } else {
        _showErrorDialog(result.error ?? '알 수 없는 오류가 발생했습니다');
      }
    } catch (e) {
      _showErrorDialog('내보내기 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _showSuccessDialog(ExportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('내보내기 완료'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('파일이 성공적으로 저장되었습니다.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '저장 위치:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.filePath ?? '알 수 없음',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (result.fileSize != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '파일 크기: ${_formatFileSize(result.fileSize!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 성공 다이얼로그 닫기
              Navigator.of(context).pop(); // 내보내기 다이얼로그 닫기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('내보내기 실패'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _getSuggestedFileName() {
    final timestamp = DateTime.now().toString().substring(0, 19).replaceAll(':', '-');
    final extension = _getFileExtension(_selectedFormat);
    return 'haneultone_${_selectedFormat.name}_$timestamp.$extension';
  }

  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv: return 'csv';
      case ExportFormat.json: return 'json';
      case ExportFormat.png: return 'png';
      case ExportFormat.html: return 'html';
    }
  }

  String _extractDirectoryPath(String fullPath) {
    final file = fullPath.split('/').last;
    return fullPath.substring(0, fullPath.length - file.length - 1);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 내보내기 형식 옵션
class ExportFormatOption {
  final ExportFormat format;
  final String title;
  final String description;
  final IconData icon;
  final String fileSize;
  final List<String> pros;
  final List<String> cons;
  final bool requiresChart;

  ExportFormatOption({
    required this.format,
    required this.title,
    required this.description,
    required this.icon,
    required this.fileSize,
    required this.pros,
    required this.cons,
    this.requiresChart = false,
  });
}