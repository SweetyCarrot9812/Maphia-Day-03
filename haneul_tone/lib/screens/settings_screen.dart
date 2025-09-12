import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_service.dart';
import '../widgets/benchmark_widget.dart';

/// 설정 화면
/// 
/// AI 벤치마크 모드와 통합된 설정 관리
/// 
/// Features:
/// - AI 자동 최적화 모드
/// - 프로필 기반 설정 관리
/// - 수동 설정 조정
/// - 설정 내보내기/가져오기
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  
  final SettingsService _settingsService = SettingsService();
  
  late TabController _tabController;
  HaneulToneSettings? _currentSettings;
  Map<String, dynamic>? _lastBenchmarkResult;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSettings();
    
    // 설정 변경 리스너 등록
    _settingsService.addListener(_onSettingsChanged);
  }
  
  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _tabController.dispose();
    super.dispose();
  }
  
  void _onSettingsChanged(HaneulToneSettings settings) {
    if (mounted) {
      setState(() {
        _currentSettings = settings;
      });
    }
  }
  
  Future<void> _loadSettings() async {
    try {
      await _settingsService.initialize();
      final settings = _settingsService.currentSettings;
      final benchmarkResult = await _settingsService.getLastBenchmarkResult();
      
      setState(() {
        _currentSettings = settings;
        _lastBenchmarkResult = benchmarkResult;
        _isLoading = false;
      });
    } catch (e) {
      print('설정 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('설정'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI 최적화'),
            Tab(icon: Icon(Icons.tune), text: '성능 설정'),
            Tab(icon: Icon(Icons.settings), text: '일반 설정'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAIOptimizationTab(),
          _buildPerformanceTab(),
          _buildGeneralTab(),
        ],
      ),
    );
  }
  
  /// AI 최적화 탭
  Widget _buildAIOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 상태 카드
          _buildAIStatusCard(),
          
          const SizedBox(height: 24),
          
          // 벤치마크 위젯
          BenchmarkWidget(
            onSettingsApplied: () {
              _loadSettings(); // 설정 적용 후 새로고침
            },
            autoApplySettings: false,
          ),
          
          const SizedBox(height: 24),
          
          // 마지막 벤치마크 결과
          if (_lastBenchmarkResult != null) _buildLastBenchmarkCard(),
        ],
      ),
    );
  }
  
  /// AI 상태 카드
  Widget _buildAIStatusCard() {
    final theme = Theme.of(context);
    final isUsingAI = _currentSettings?.activeProfile == 'ai_optimized';
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isUsingAI ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                  color: isUsingAI ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUsingAI ? 'AI 최적화 활성화됨' : 'AI 최적화 비활성화됨',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUsingAI ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUsingAI 
                            ? '디바이스에 최적화된 설정이 적용되어 있습니다'
                            : 'AI 벤치마크를 실행하여 최적 설정을 찾으세요',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (isUsingAI) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '현재 활성 설정',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '피치 엔진: ${_currentSettings?.pitchEngine.name.toUpperCase() ?? 'Unknown'}\n'
                      '실시간 처리: ${_currentSettings?.enableRealtimeProcessing == true ? '활성화' : '비활성화'}\n'
                      '프레임 크기: ${_currentSettings?.frameSize ?? 'Unknown'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 마지막 벤치마크 결과 카드
  Widget _buildLastBenchmarkCard() {
    final theme = Theme.of(context);
    final result = _lastBenchmarkResult!;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '마지막 벤치마크 결과',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                // 성능 등급
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getGradeColor(result['performanceGrade']),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      result['performanceGrade'] ?? '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 엔진: ${result['recommendedEngine'] ?? 'Unknown'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '품질 점수: ${((result['qualityScore'] ?? 0) * 100).toStringAsFixed(1)}점',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 재실행 버튼
                IconButton(
                  onPressed: () {
                    // 벤치마크 탭으로 이동하고 자동 실행
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: '다시 실행',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 성능 설정 탭
  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 선택
          _buildProfileSelection(),
          
          const SizedBox(height: 24),
          
          // 상세 설정
          if (_currentSettings != null) _buildDetailedSettings(),
        ],
      ),
    );
  }
  
  /// 프로필 선택 섹션
  Widget _buildProfileSelection() {
    final theme = Theme.of(context);
    final currentProfile = _currentSettings?.activeProfile ?? 'default';
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '성능 프로필',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Column(
              children: [
                _buildProfileOption(
                  'ai_optimized',
                  'AI 최적화',
                  '벤치마크 기반 최적 설정',
                  Icons.auto_awesome,
                  Colors.purple,
                  currentProfile,
                ),
                _buildProfileOption(
                  'performance',
                  '성능 우선',
                  '빠른 응답 속도 최적화',
                  Icons.speed,
                  Colors.blue,
                  currentProfile,
                ),
                _buildProfileOption(
                  'battery',
                  '배터리 절약',
                  '전력 소모 최소화',
                  Icons.battery_saver,
                  Colors.green,
                  currentProfile,
                ),
                _buildProfileOption(
                  'quality',
                  '품질 우선',
                  '최고 정확도 추구',
                  Icons.high_quality,
                  Colors.orange,
                  currentProfile,
                ),
                _buildProfileOption(
                  'custom',
                  '사용자 정의',
                  '수동 설정 조정',
                  Icons.tune,
                  Colors.grey,
                  currentProfile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 프로필 옵션 빌드
  Widget _buildProfileOption(
    String profileId,
    String title,
    String description,
    IconData icon,
    Color color,
    String currentProfile,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentProfile == profileId;
    final isAIProfile = profileId == 'ai_optimized';
    final hasAISettings = _lastBenchmarkResult != null;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isAIProfile && !hasAISettings) ? null : () => _changeProfile(profileId),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? color.withOpacity(0.1) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : color,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : null,
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
                    color: color,
                    size: 20,
                  ),
                  
                if (isAIProfile && !hasAISettings)
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 상세 설정 섹션
  Widget _buildDetailedSettings() {
    final theme = Theme.of(context);
    final settings = _currentSettings!;
    final isCustom = settings.activeProfile == 'custom';
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '상세 설정',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (!isCustom)
                  TextButton.icon(
                    onPressed: () => _changeProfile('custom'),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('편집'),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 피치 엔진 설정
            _buildSettingSection(
              '피치 엔진',
              [
                _buildDropdownSetting(
                  '엔진 타입',
                  settings.pitchEngine.name.toUpperCase(),
                  PitchEngineType.values
                      .map((e) => e.name.toUpperCase())
                      .toList(),
                  isCustom ? (value) => _updatePitchEngine(value) : null,
                ),
                if (settings.pitchEngine == PitchEngineType.hybrid) ...[
                  _buildSliderSetting(
                    'YIN 가중치',
                    settings.hybridYinWeight,
                    0.0,
                    1.0,
                    isCustom ? (value) => _updateHybridYinWeight(value) : null,
                  ),
                ],
              ],
            ),
            
            const Divider(),
            
            // 오디오 처리 설정
            _buildSettingSection(
              '오디오 처리',
              [
                _buildSwitchSetting(
                  '실시간 처리',
                  settings.enableRealtimeProcessing,
                  isCustom ? (value) => _updateRealtimeProcessing(value) : null,
                ),
                _buildSliderSetting(
                  '프레임 크기',
                  settings.frameSize.toDouble(),
                  256,
                  2048,
                  isCustom ? (value) => _updateFrameSize(value.round()) : null,
                  divisions: 7,
                ),
                _buildDropdownSetting(
                  '윈도우 함수',
                  settings.windowFunction.name.toUpperCase(),
                  WindowFunctionType.values
                      .map((e) => e.name.toUpperCase())
                      .toList(),
                  isCustom ? (value) => _updateWindowFunction(value) : null,
                ),
              ],
            ),
            
            const Divider(),
            
            // 필터 설정
            _buildSettingSection(
              '오디오 필터',
              [
                _buildSwitchSetting(
                  '고역 통과 필터',
                  settings.enableHighPassFilter,
                  isCustom ? (value) => _updateHighPassFilter(value) : null,
                ),
                if (settings.enableHighPassFilter)
                  _buildSliderSetting(
                    '차단 주파수',
                    settings.highPassCutoff,
                    40.0,
                    200.0,
                    isCustom ? (value) => _updateHighPassCutoff(value) : null,
                  ),
                _buildSwitchSetting(
                  '노치 필터',
                  settings.enableNotchFilter,
                  isCustom ? (value) => _updateNotchFilter(value) : null,
                ),
              ],
            ),
            
            const Divider(),
            
            // 분석 설정
            _buildSettingSection(
              '분석 옵션',
              [
                _buildSliderSetting(
                  '신뢰도 임계값',
                  settings.confidenceThreshold,
                  0.5,
                  0.95,
                  isCustom ? (value) => _updateConfidenceThreshold(value) : null,
                ),
                _buildSwitchSetting(
                  '포먼트 분석',
                  settings.enableFormantAnalysis,
                  isCustom ? (value) => _updateFormantAnalysis(value) : null,
                ),
                _buildSwitchSetting(
                  '비브라토 감지',
                  settings.enableVibratoDetection,
                  isCustom ? (value) => _updateVibratoDetection(value) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 일반 설정 탭
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // UI 기능 설정
          _buildUIFeaturesCard(),
          
          const SizedBox(height: 16),
          
          // 설정 백업/복원
          _buildBackupRestoreCard(),
          
          const SizedBox(height: 16),
          
          // 앱 정보
          _buildAppInfoCard(),
        ],
      ),
    );
  }
  
  /// UI 기능 설정 카드
  Widget _buildUIFeaturesCard() {
    final theme = Theme.of(context);
    final settings = _currentSettings!;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UI 기능',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildSwitchSetting(
              '세션 재생 기능',
              settings.enableSessionReplay,
              (value) => _updateSessionReplay(value),
              subtitle: '연습 세션을 다시 재생할 수 있습니다',
            ),
            
            _buildSwitchSetting(
              '코칭 카드',
              settings.enableCoachingCards,
              (value) => _updateCoachingCards(value),
              subtitle: 'AI 기반 개인화된 피드백을 받을 수 있습니다',
            ),
            
            _buildSwitchSetting(
              '내보내기 기능',
              settings.enableExportFeatures,
              (value) => _updateExportFeatures(value),
              subtitle: '연습 데이터를 CSV, JSON 등으로 내보낼 수 있습니다',
            ),
          ],
        ),
      ),
    );
  }
  
  /// 백업/복원 카드
  Widget _buildBackupRestoreCard() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '설정 관리',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportSettings,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('설정 내보내기'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importSettings,
                    icon: const Icon(Icons.file_download),
                    label: const Text('설정 가져오기'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetSettings,
                icon: const Icon(Icons.restore),
                label: const Text('설정 초기화'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 앱 정보 카드
  Widget _buildAppInfoCard() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱 정보',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info),
              title: const Text('HaneulTone'),
              subtitle: const Text('버전 1.0.0\nAI 성악 트레이너'),
            ),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.auto_awesome),
              title: const Text('AI 엔진'),
              subtitle: const Text('피치 분석, 코칭, 자동 최적화'),
            ),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bug_report),
              title: const Text('피드백'),
              subtitle: const Text('문제나 개선사항을 알려주세요'),
              onTap: _showFeedbackDialog,
            ),
          ],
        ),
      ),
    );
  }
  
  // 설정 빌더 헬퍼 메서드들...
  Widget _buildSettingSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
  
  Widget _buildDropdownSetting(
    String title,
    String currentValue,
    List<String> options,
    void Function(String)? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          DropdownButton<String>(
            value: currentValue,
            onChanged: onChanged,
            items: options.map((option) => 
              DropdownMenuItem(value: option, child: Text(option))
            ).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSliderSetting(
    String title,
    double value,
    double min,
    double max,
    void Function(double)? onChanged, {
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title),
              const Spacer(),
              Text(value.toStringAsFixed(value < 10 ? 2 : 0)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitchSetting(
    String title,
    bool value,
    void Function(bool)? onChanged, {
    String? subtitle,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
  
  // 설정 업데이트 메서드들...
  Future<void> _changeProfile(String profileId) async {
    try {
      await _settingsService.changeProfile(profileId);
    } catch (e) {
      _showErrorMessage('프로필 변경 실패: $e');
    }
  }
  
  void _updatePitchEngine(String engineName) {
    final engine = PitchEngineType.values.firstWhere(
      (e) => e.name.toUpperCase() == engineName,
      orElse: () => PitchEngineType.hybrid,
    );
    
    final newSettings = _currentSettings!.copyWith(pitchEngine: engine);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateHybridYinWeight(double weight) {
    final newSettings = _currentSettings!.copyWith(
      hybridYinWeight: weight,
      hybridFftWeight: 1.0 - weight,
    );
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateRealtimeProcessing(bool enabled) {
    final newSettings = _currentSettings!.copyWith(enableRealtimeProcessing: enabled);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateFrameSize(int size) {
    final newSettings = _currentSettings!.copyWith(
      frameSize: size,
      hopSize: size ~/ 2, // 자동으로 홉 크기도 조정
    );
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateWindowFunction(String functionName) {
    final function = WindowFunctionType.values.firstWhere(
      (e) => e.name.toUpperCase() == functionName,
      orElse: () => WindowFunctionType.hann,
    );
    
    final newSettings = _currentSettings!.copyWith(windowFunction: function);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateHighPassFilter(bool enabled) {
    final newSettings = _currentSettings!.copyWith(enableHighPassFilter: enabled);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateHighPassCutoff(double cutoff) {
    final newSettings = _currentSettings!.copyWith(highPassCutoff: cutoff);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateNotchFilter(bool enabled) {
    final newSettings = _currentSettings!.copyWith(enableNotchFilter: enabled);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateConfidenceThreshold(double threshold) {
    final newSettings = _currentSettings!.copyWith(confidenceThreshold: threshold);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateFormantAnalysis(bool enabled) {
    final newSettings = _currentSettings!.copyWith(enableFormantAnalysis: enabled);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateVibratoDetection(bool enabled) {
    final newSettings = _currentSettings!.copyWith(enableVibratoDetection: enabled);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateSessionReplay(bool enabled) {
    final newSettings = _currentSettings!.copyWith(enableSessionReplay: enabled);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateCoachingCards(bool enabled) {
    final newSettings = _currentSettings!.copyWith(enableCoachingCards: enabled);
    _settingsService.saveUserSettings(newSettings);
  }
  
  void _updateExportFeatures(bool enabled) {
    final newSettings = _currentSettings!.copyWith(enableExportFeatures: enabled);
    _settingsService.saveUserSettings(newSettings);
  }
  
  // 백업/복원 메서드들...
  Future<void> _exportSettings() async {
    try {
      final settings = await _settingsService.exportSettings();
      // TODO: 파일 선택기를 통해 설정 내보내기
      // 예: share_plus 패키지를 사용하여 파일 공유
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 내보내기가 구현될 예정입니다')),
      );
    } catch (e) {
      _showErrorMessage('설정 내보내기 실패: $e');
    }
  }
  
  Future<void> _importSettings() async {
    // TODO: 파일 선택기를 통해 설정 가져오기
    // 예: file_picker 패키지를 사용하여 파일 선택
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('설정 가져오기가 구현될 예정입니다')),
    );
  }
  
  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 설정을 기본값으로 초기화하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.'),
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
        await _settingsService.resetToDefaults();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 초기화되었습니다')),
        );
      } catch (e) {
        _showErrorMessage('설정 초기화 실패: $e');
      }
    }
  }
  
  // 피드백 다이얼로그
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('피드백'),
        content: const Text('HaneulTone을 더 좋게 만들기 위한 의견을 보내주세요.\n\n피드백 기능은 곧 구현될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  // 유틸리티 메서드들...
  Color _getGradeColor(String? grade) {
    switch (grade) {
      case 'S': return Colors.purple;
      case 'A': return Colors.green;
      case 'B': return Colors.blue;
      case 'C': return Colors.orange;
      case 'D': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}