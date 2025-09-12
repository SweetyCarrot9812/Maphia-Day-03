import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/accessibility_service.dart';

/// 접근성 설정 위젯
/// 
/// 색맹 지원, 진동 피드백, 텍스트 크기 등 접근성 기능 설정
/// 
/// Features:
/// - 색맹 타입 선택
/// - 진동 피드백 설정
/// - 고대비 모드
/// - 큰 글꼴 모드
/// - 접근성 진단
/// - 실시간 미리보기
class AccessibilityWidget extends ConsumerStatefulWidget {
  final VoidCallback? onSettingsChanged;
  
  const AccessibilityWidget({
    Key? key,
    this.onSettingsChanged,
  }) : super(key: key);

  @override
  ConsumerState<AccessibilityWidget> createState() => _AccessibilityWidgetState();
}

class _AccessibilityWidgetState extends ConsumerState<AccessibilityWidget>
    with TickerProviderStateMixin {
  
  final AccessibilityService _accessibilityService = AccessibilityService();
  
  late AnimationController _previewController;
  late Animation<double> _previewAnimation;
  
  AccessibilitySettings? _settings;
  AccessibilityReport? _lastDiagnosisReport;
  bool _isLoading = true;
  bool _isDiagnosisRunning = false;
  
  @override
  void initState() {
    super.initState();
    
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _previewAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeInOut,
    ));
    
    _loadSettings();
    _accessibilityService.addListener(_onSettingsChanged);
  }
  
  @override
  void dispose() {
    _accessibilityService.removeListener(_onSettingsChanged);
    _previewController.dispose();
    super.dispose();
  }
  
  void _onSettingsChanged(AccessibilitySettings settings) {
    if (mounted) {
      setState(() {
        _settings = settings;
      });
      widget.onSettingsChanged?.call();
      _previewController.forward().then((_) {
        _previewController.reverse();
      });
    }
  }
  
  Future<void> _loadSettings() async {
    try {
      await _accessibilityService.initialize();
      
      setState(() {
        _settings = _accessibilityService.settings;
        _isLoading = false;
      });
    } catch (e) {
      print('접근성 설정 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // 진단 결과 (있는 경우)
            if (_lastDiagnosisReport != null) ...[
              _buildDiagnosisResultCard(),
              const SizedBox(height: 16),
            ],
            
            // 색맹 지원 설정
            _buildColorBlindnessSection(),
            const SizedBox(height: 20),
            
            // 진동 피드백 설정
            _buildVibrationSection(),
            const SizedBox(height: 20),
            
            // 시각적 지원 설정
            _buildVisualSupportSection(),
            const SizedBox(height: 20),
            
            // 미리보기 섹션
            _buildPreviewSection(),
            const SizedBox(height: 20),
            
            // 액션 버튼들
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  
  /// 헤더 섹션
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.accessibility_new,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '접근성 설정',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '색맹 지원, 진동 피드백 등 접근성 기능을 설정합니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 진단 결과 카드
  Widget _buildDiagnosisResultCard() {
    final theme = Theme.of(context);
    final report = _lastDiagnosisReport!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: report.gradeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: report.gradeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: report.gradeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '접근성 진단 결과',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: report.gradeColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: report.gradeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.accessibilityGrade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '전체 점수: ${(report.overallScore * 100).toStringAsFixed(1)}점',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          if (report.recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '주요 권장사항:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report.recommendations.first,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 색맹 지원 섹션
  Widget _buildColorBlindnessSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '색맹 지원',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 색맹 타입 선택
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '색맹 타입',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              ...ColorBlindnessType.values.map((type) => 
                _buildColorBlindnessOption(type)
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 색맹 타입 옵션
  Widget _buildColorBlindnessOption(ColorBlindnessType type) {
    final theme = Theme.of(context);
    final isSelected = _settings?.colorBlindnessType == type;
    
    String title;
    String description;
    
    switch (type) {
      case ColorBlindnessType.none:
        title = '색맹 없음';
        description = '표준 색상 표시';
        break;
      case ColorBlindnessType.protanopia:
        title = '적색맹 (Protanopia)';
        description = '빨간색 구분이 어려운 경우';
        break;
      case ColorBlindnessType.deuteranopia:
        title = '녹색맹 (Deuteranopia)';
        description = '초록색 구분이 어려운 경우';
        break;
      case ColorBlindnessType.tritanopia:
        title = '청색맹 (Tritanopia)';
        description = '파란색 구분이 어려운 경우';
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changeColorBlindnessType(type),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                // 색상 미리보기
                _buildColorPreview(type),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 색상 미리보기
  Widget _buildColorPreview(ColorBlindnessType type) {
    // 임시 AccessibilityService를 만들어서 색상 변환 테스트
    final tempService = AccessibilityService();
    tempService._settings = tempService._settings.copyWith(colorBlindnessType: type);
    
    final originalColors = [Colors.red, Colors.green, Colors.blue];
    final adaptedColors = originalColors.map((color) => tempService.adaptColor(color)).toList();
    
    return Row(
      children: adaptedColors.map((color) => Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
      )).toList(),
    );
  }
  
  /// 진동 피드백 섹션
  Widget _buildVibrationSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.vibration,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '진동 피드백',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 진동 피드백 활성화
        SwitchListTile(
          title: const Text('진동 피드백 사용'),
          subtitle: const Text('성공, 오류 등의 상황에서 진동으로 알림'),
          value: _settings?.enableVibrationFeedback ?? false,
          onChanged: _changeVibrationFeedback,
          contentPadding: EdgeInsets.zero,
        ),
        
        if (_settings?.enableVibrationFeedback == true) ...[
          const SizedBox(height: 8),
          
          // 진동 강도 설정
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '진동 강도',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _testVibration,
                      child: const Text('테스트'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: VibrationIntensity.values.map((intensity) {
                    final isSelected = _settings?.vibrationIntensity == intensity;
                    
                    String label;
                    switch (intensity) {
                      case VibrationIntensity.light:
                        label = '약함';
                        break;
                      case VibrationIntensity.medium:
                        label = '중간';
                        break;
                      case VibrationIntensity.strong:
                        label = '강함';
                        break;
                    }
                    
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: intensity != VibrationIntensity.values.last ? 8 : 0,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _changeVibrationIntensity(intensity),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected 
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  /// 시각적 지원 섹션
  Widget _buildVisualSupportSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.visibility,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '시각적 지원',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 고대비 모드
        SwitchListTile(
          title: const Text('고대비 모드'),
          subtitle: const Text('색상 대비를 높여 구분을 쉽게 합니다'),
          value: _settings?.enableHighContrast ?? false,
          onChanged: _changeHighContrast,
          contentPadding: EdgeInsets.zero,
        ),
        
        // 큰 글꼴 모드
        SwitchListTile(
          title: const Text('큰 글꼴'),
          subtitle: const Text('텍스트 크기를 30% 크게 표시합니다'),
          value: _settings?.enableLargeFont ?? false,
          onChanged: _changeLargeFont,
          contentPadding: EdgeInsets.zero,
        ),
        
        // 음성 안내 (준비 중)
        SwitchListTile(
          title: const Text('음성 안내 (준비 중)'),
          subtitle: const Text('화면 내용을 음성으로 안내합니다'),
          value: _settings?.enableVoiceGuidance ?? false,
          onChanged: null, // 준비 중이므로 비활성화
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
  
  /// 미리보기 섹션
  Widget _buildPreviewSection() {
    final theme = Theme.of(context);
    final palette = _accessibilityService.getColorPalette();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.preview,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '미리보기',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        AnimatedBuilder(
          animation: _previewAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(
                    0.3 + (_previewAnimation.value * 0.7),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 텍스트
                  Text(
                    '샘플 텍스트',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: _accessibilityService.adjustFontSize(
                        theme.textTheme.titleMedium?.fontSize ?? 16,
                      ),
                      color: palette.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 본문 텍스트
                  Text(
                    '이 텍스트는 현재 접근성 설정에 따라 표시됩니다. '
                    '글꼴 크기와 색상이 설정에 맞게 조정됩니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: _accessibilityService.adjustFontSize(
                        theme.textTheme.bodyMedium?.fontSize ?? 14,
                      ),
                      color: palette.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 색상 상태 표시
                  Row(
                    children: [
                      _buildStatusChip('성공', palette.success, palette.onPrimary),
                      const SizedBox(width: 8),
                      _buildStatusChip('경고', palette.warning, palette.onPrimary),
                      const SizedBox(width: 8),
                      _buildStatusChip('오류', palette.error, palette.onPrimary),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// 상태 칩 빌드
  Widget _buildStatusChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: _accessibilityService.adjustFontSize(12),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isDiagnosisRunning ? null : _runDiagnosis,
            icon: _isDiagnosisRunning 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.assessment),
            label: Text(_isDiagnosisRunning ? '진단 중...' : '접근성 진단'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetSettings,
            icon: const Icon(Icons.restore),
            label: const Text('기본값으로 재설정'),
          ),
        ),
      ],
    );
  }
  
  /// 색맹 타입 변경
  Future<void> _changeColorBlindnessType(ColorBlindnessType type) async {
    try {
      await _accessibilityService.setColorBlindnessType(type);
    } catch (e) {
      _showErrorMessage('색맹 타입 변경 실패: $e');
    }
  }
  
  /// 진동 피드백 변경
  Future<void> _changeVibrationFeedback(bool enabled) async {
    try {
      await _accessibilityService.setVibrationFeedback(enabled);
      
      if (enabled) {
        // 활성화 시 테스트 진동
        await _accessibilityService.vibrateLight();
      }
    } catch (e) {
      _showErrorMessage('진동 피드백 설정 실패: $e');
    }
  }
  
  /// 진동 강도 변경
  Future<void> _changeVibrationIntensity(VibrationIntensity intensity) async {
    try {
      await _accessibilityService.setVibrationIntensity(intensity);
      
      // 변경 후 테스트 진동
      await _accessibilityService.vibrateLight();
    } catch (e) {
      _showErrorMessage('진동 강도 설정 실패: $e');
    }
  }
  
  /// 고대비 모드 변경
  Future<void> _changeHighContrast(bool enabled) async {
    try {
      await _accessibilityService.setHighContrastMode(enabled);
    } catch (e) {
      _showErrorMessage('고대비 모드 설정 실패: $e');
    }
  }
  
  /// 큰 글꼴 변경
  Future<void> _changeLargeFont(bool enabled) async {
    try {
      await _accessibilityService.setLargeFontMode(enabled);
    } catch (e) {
      _showErrorMessage('큰 글꼴 설정 실패: $e');
    }
  }
  
  /// 진동 테스트
  Future<void> _testVibration() async {
    try {
      await _accessibilityService.vibrateNotification();
    } catch (e) {
      _showErrorMessage('진동 테스트 실패: $e');
    }
  }
  
  /// 접근성 진단 실행
  Future<void> _runDiagnosis() async {
    setState(() {
      _isDiagnosisRunning = true;
    });
    
    try {
      final report = await _accessibilityService.runAccessibilityDiagnosis();
      
      setState(() {
        _lastDiagnosisReport = report;
        _isDiagnosisRunning = false;
      });
      
      // 진단 완료 피드백
      await _accessibilityService.vibrateSuccess();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('접근성 진단 완료 - 등급: ${report.accessibilityGrade}'),
            backgroundColor: report.gradeColor,
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _isDiagnosisRunning = false;
      });
      _showErrorMessage('접근성 진단 실패: $e');
    }
  }
  
  /// 설정 초기화
  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('접근성 설정을 기본값으로 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        // 기본값으로 재설정
        await _accessibilityService.setColorBlindnessType(ColorBlindnessType.none);
        await _accessibilityService.setVibrationFeedback(false);
        await _accessibilityService.setHighContrastMode(false);
        await _accessibilityService.setLargeFontMode(false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('접근성 설정이 초기화되었습니다')),
          );
        }
        
      } catch (e) {
        _showErrorMessage('설정 초기화 실패: $e');
      }
    }
  }
  
  /// 오류 메시지 표시
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}