import 'package:flutter/material.dart';
import '../widgets/pitch_visualization_widget.dart';
import '../models/audio_reference.dart';
import '../models/pitch_data.dart';
import 'dart:math' as math;

class PitchAnalysisScreen extends StatefulWidget {
  final AudioReference? audioReference;
  final PitchData? pitchData;
  
  const PitchAnalysisScreen({
    super.key,
    this.audioReference,
    this.pitchData,
  });

  @override
  State<PitchAnalysisScreen> createState() => _PitchAnalysisScreenState();
}

class _PitchAnalysisScreenState extends State<PitchAnalysisScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  double _currentTime = 0.0;
  bool _isPlaying = false;
  
  // 데모 데이터
  List<double> _demoPitchData = [];
  List<double> _demoTargetPitches = [];
  List<String> _demoNoteNames = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateDemoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateDemoData() {
    // C Major Scale 데모 데이터 생성
    final cMajorFrequencies = [
      261.63, // C4
      293.66, // D4
      329.63, // E4
      349.23, // F4
      392.00, // G4
      440.00, // A4
      493.88, // B4
      523.25, // C5
    ];
    
    final noteNames = ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5'];
    
    _demoNoteNames = noteNames;
    _demoTargetPitches.clear();
    _demoPitchData.clear();
    
    // 각 음표당 50개의 데이터 포인트 생성 (총 400개)
    for (int noteIndex = 0; noteIndex < cMajorFrequencies.length; noteIndex++) {
      final targetFreq = cMajorFrequencies[noteIndex];
      
      for (int i = 0; i < 50; i++) {
        _demoTargetPitches.add(targetFreq);
        
        // 실제 피치에 약간의 변동 추가 (현실적인 시뮬레이션)
        final variation = (math.Random().nextDouble() - 0.5) * 10; // ±5Hz 변동
        final actualPitch = targetFreq + variation;
        _demoPitchData.add(actualPitch);
      }
    }
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      _startPlayback();
    }
  }

  void _startPlayback() async {
    const duration = Duration(milliseconds: 50);
    const totalTime = 8.0; // 8초
    const timeStep = totalTime / 400; // 400개 데이터 포인트
    
    while (_isPlaying && _currentTime < totalTime) {
      await Future.delayed(duration);
      if (mounted && _isPlaying) {
        setState(() {
          _currentTime += timeStep;
        });
      }
    }
    
    if (_currentTime >= totalTime) {
      setState(() {
        _isPlaying = false;
        _currentTime = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피치 분석'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: '실시간 분석'),
            Tab(icon: Icon(Icons.analytics), text: '상세 분석'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRealtimeAnalysisTab(),
          _buildDetailedAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildRealtimeAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 컨트롤 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _togglePlayback,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? '일시정지' : '재생'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentTime = 0.0;
                        _isPlaying = false;
                      });
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('정지'),
                  ),
                  const Spacer(),
                  Text(
                    'C Major Scale 데모',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 피치 시각화 위젯
          PitchVisualizationWidget(
            pitchData: _demoPitchData,
            targetPitches: _demoTargetPitches,
            noteNames: _demoNoteNames,
            currentTime: _currentTime,
            duration: 8.0,
            showTarget: true,
            pitchColor: Colors.blue,
            targetColor: Colors.green,
          ),
          
          const SizedBox(height: 16),
          
          // 정확도 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '실시간 정확도',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAccuracyMeter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 분석 설정 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '분석 설정',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSettingChip('주파수 범위', '250-550 Hz', Icons.tune),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSettingChip('샘플링 레이트', '44.1 kHz', Icons.settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSettingChip('윈도우 크기', '2048 샘플', Icons.crop_square),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSettingChip('오버랩', '50%', Icons.layers),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 상세 피치 분석 위젯
          PitchVisualizationWidget(
            pitchData: _demoPitchData,
            targetPitches: _demoTargetPitches,
            noteNames: _demoNoteNames,
            currentTime: _currentTime,
            duration: 8.0,
            showTarget: true,
            pitchColor: Colors.purple,
            targetColor: Colors.amber,
          ),
          
          const SizedBox(height: 16),
          
          // 성능 분석
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성능 분석',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPerformanceGrid(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 개선 제안
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        '개선 제안',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSuggestionList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyMeter() {
    final accuracy = 85.0 + (math.sin(_currentTime * 2) * 10); // 시뮬레이션
    final accuracyPercentage = accuracy.clamp(0.0, 100.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('전체 정확도'),
            Text(
              '${accuracyPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: accuracyPercentage > 80 
                    ? Colors.green 
                    : accuracyPercentage > 60 
                        ? Colors.orange 
                        : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: accuracyPercentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            accuracyPercentage > 80 
                ? Colors.green 
                : accuracyPercentage > 60 
                    ? Colors.orange 
                    : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2,
      children: [
        _buildPerformanceItem('평균 정확도', '85.3%', Colors.blue),
        _buildPerformanceItem('안정도', '78.1%', Colors.green),
        _buildPerformanceItem('음정 범위', '2.1 옥타브', Colors.orange),
        _buildPerformanceItem('지속 시간', '8.0초', Colors.purple),
      ],
    );
  }

  Widget _buildPerformanceItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionList() {
    final suggestions = [
      '중간 음역(G4-A4)에서 피치 안정성을 개선하세요',
      '음정 변화 구간에서 더 부드럽게 연결해보세요',
      '고음역에서 호흡 조절을 더 신경 써보세요',
    ];

    return Column(
      children: suggestions.map((suggestion) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.arrow_right,
              size: 16,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}