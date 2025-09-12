import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/calendar_models.dart';
import '../providers/app_providers.dart';
import '../providers/auth_provider.dart';
import '../services/calendar_service.dart';
import '../utils/localization_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate;
  Map<DateTime, List<CalendarEvent>> _events = {};
  WorkoutCalendarStats? _stats;
  List<UpcomingWorkout> _upcomingWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // initState에서는 context를 사용하지 않도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCalendarData();
    });
  }

  Future<void> _loadCalendarData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final calendarService = context.read<CalendarService>();
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.uid ?? 'demo_user';

      // 병렬로 데이터 로드
      final futures = await Future.wait([
        calendarService.getCalendarEventsForMonth(userId, _selectedMonth),
        calendarService.getCalendarStats(userId, _selectedMonth),
        calendarService.getUpcomingWorkouts(userId),
      ]);

      if (!mounted) return;
      
      setState(() {
        _events = futures[0] as Map<DateTime, List<CalendarEvent>>;
        _stats = futures[1] as WorkoutCalendarStats;
        _upcomingWorkouts = futures[2] as List<UpcomingWorkout>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      print('캘린더 데이터 로드 실패: $e');
    }
  }

  void _changeMonth(int direction) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + direction);
      _selectedDate = null;
    });
    _loadCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.navCalendar),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime.now();
                _selectedDate = DateTime.now();
              });
              _loadCalendarData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCalendarData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildStatsCard(),
                    _buildCalendarHeader(),
                    _buildCalendar(),
                    if (_selectedDate != null) _buildSelectedDateDetails(),
                    _buildUpcomingWorkouts(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedMonth.month}월 운동 통계',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('완료', _stats!.completedCount, Colors.green),
                _buildStatItem('예정', _stats!.scheduledCount, Colors.blue),
                _buildStatItem('놓침', _stats!.missedCount, Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _stats!.completionRate / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _stats!.completionRate >= 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '달성률: ${_stats!.completionRate.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('yyyy년 M월').format(_selectedMonth),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildWeekdayHeaders(),
            ..._buildCalendarWeeks(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return Row(
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    final weeks = <Widget>[];
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    // 첫 번째 주의 시작일 (월요일 기준)
    final startDate = firstDayOfMonth.subtract(Duration(days: (firstDayOfMonth.weekday - 1) % 7));
    
    var currentDate = startDate;
    
    while (currentDate.isBefore(lastDayOfMonth) || currentDate.month == _selectedMonth.month) {
      final weekDays = <Widget>[];
      
      for (int i = 0; i < 7; i++) {
        weekDays.add(_buildCalendarDay(currentDate));
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      weeks.add(Row(children: weekDays));
      
      // 다음 달로 넘어가면 중단
      if (currentDate.month != _selectedMonth.month && currentDate.day > 7) {
        break;
      }
    }
    
    return weeks;
  }

  Widget _buildCalendarDay(DateTime date) {
    final isCurrentMonth = date.month == _selectedMonth.month;
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
    final dayEvents = _events[DateTime(date.year, date.month, date.day)] ?? [];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
        },
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : isToday
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: Theme.of(context).colorScheme.primary)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentMonth
                      ? (isToday ? Theme.of(context).colorScheme.primary : null)
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 2),
              if (dayEvents.isNotEmpty) _buildEventIndicators(dayEvents),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventIndicators(List<CalendarEvent> events) {
    final colors = <Color>[];
    
    for (final event in events.take(3)) { // 최대 3개까지만 표시
      switch (event.type) {
        case CalendarEventType.completed:
          colors.add(Colors.green);
          break;
        case CalendarEventType.scheduled:
          colors.add(Colors.blue);
          break;
        case CalendarEventType.missed:
          colors.add(Colors.red);
          break;
        case CalendarEventType.rest:
          colors.add(Colors.grey);
          break;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors.map((color) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      )).toList(),
    );
  }

  Widget _buildSelectedDateDetails() {
    if (_selectedDate == null) return const SizedBox.shrink();

    final dayEvents = _events[DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day)] ?? [];
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('M월 d일 (E)', 'ko').format(_selectedDate!),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (dayEvents.isEmpty)
              const Text('이 날은 운동 일정이 없습니다.')
            else
              ...dayEvents.map((event) => _buildEventItem(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(CalendarEvent event) {
    IconData icon;
    Color color;
    String statusText;

    switch (event.type) {
      case CalendarEventType.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = '완료';
        break;
      case CalendarEventType.scheduled:
        icon = Icons.schedule;
        color = Colors.blue;
        statusText = '예정';
        break;
      case CalendarEventType.missed:
        icon = Icons.error;
        color = Colors.red;
        statusText = '놓침';
        break;
      case CalendarEventType.rest:
        icon = Icons.hotel;
        color = Colors.grey;
        statusText = '휴식';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${event.title} ($statusText)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (event.type == CalendarEventType.completed && event.metadata != null)
              _buildWorkoutDetails(event),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutDetails(CalendarEvent event) {
    final metadata = event.metadata ?? {};
    final session = metadata['session'];
    
    if (session == null || session is! Map<String, dynamic>) return const SizedBox.shrink();

    final logs = session['logs'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            '운동 상세',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          // 세션 기본 정보
          if (session['durationMinutes'] != null)
            _buildDetailRow(Icons.timer, '운동 시간', '${session['durationMinutes']}분'),
          if (logs.isNotEmpty)
            _buildDetailRow(Icons.fitness_center, '총 세트', '${logs.length}세트'),
          
          // 운동 로그 상세 정보
          if (logs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '운동 기록',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            ...logs.take(3).map((log) => _buildLogItem(log)).toList(),
            if (logs.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '외 ${logs.length - 3}개 운동',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogItem(dynamic logData) {
    if (logData is! Map<String, dynamic>) return const SizedBox.shrink();
    
    final exerciseKey = logData['exerciseKey'] as String? ?? '운동';
    final weight = logData['weight'] as double? ?? 0.0;
    final reps = logData['reps'] as int? ?? 0;
    final rpe = logData['rpe'] as int? ?? 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _getExerciseName(exerciseKey),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${weight.toInt()}kg',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${reps}회',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (rpe > 0) ...[
            const SizedBox(width: 8),
            Text(
              'RPE$rpe',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getExerciseName(String exerciseKey) {
    // 간단한 운동명 변환
    final exerciseNames = <String, String>{
      'squat': '스쿼트',
      'bench_press': '벤치프레스',
      'deadlift': '데드리프트',
      'overhead_press': '오버헤드프레스',
      'row': '로우',
      'pull_up': '풀업',
      'dip': '딥',
      'lunge': '런지',
    };
    
    return exerciseNames[exerciseKey] ?? exerciseKey;
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingWorkouts() {
    if (_upcomingWorkouts.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '다가오는 운동',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._upcomingWorkouts.take(5).map((workout) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '${workout.daysUntil}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                          workout.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('M월 d일 (E)', 'ko').format(workout.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    workout.daysUntil == 0
                        ? '오늘'
                        : workout.daysUntil == 1
                            ? '내일'
                            : '${workout.daysUntil}일 후',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}