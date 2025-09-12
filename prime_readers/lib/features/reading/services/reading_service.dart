import 'package:hive/hive.dart';
import '../models/reading_models.dart';

class ReadingService {
  static const String _booksBoxName = 'books';
  static const String _readingSessionsBoxName = 'reading_sessions';
  static const String _readingProgressBoxName = 'reading_progress';
  static const String _arRecordsBoxName = 'ar_records';
  static const String _readingStatsBoxName = 'reading_stats';
  
  late Box<Book> _booksBox;
  late Box<ReadingSession> _readingSessionsBox;
  late Box<ReadingProgress> _readingProgressBox;
  late Box<ARRecord> _arRecordsBox;
  late Box<ReadingStats> _readingStatsBox;

  Future<void> initialize() async {
    _booksBox = await Hive.openBox<Book>(_booksBoxName);
    _readingSessionsBox = await Hive.openBox<ReadingSession>(_readingSessionsBoxName);
    _readingProgressBox = await Hive.openBox<ReadingProgress>(_readingProgressBoxName);
    _arRecordsBox = await Hive.openBox<ARRecord>(_arRecordsBoxName);
    _readingStatsBox = await Hive.openBox<ReadingStats>(_readingStatsBoxName);
    
    await addSampleBooks();
  }

  // 샘플 도서 데이터 추가
  Future<void> addSampleBooks() async {
    if (_booksBox.isEmpty) {
      final sampleBooks = [
        Book(
          id: 'book_001',
          title: '어린 왕자',
          author: '생텍쥐페리',
          isbn: '9788937460432',
          description: '사막에 불시착한 비행사가 만난 어린 왕자와의 특별한 만남을 그린 소설',
          genre: BookGenre.fiction,
          arLevel: ARLevel.grade4,
          arPoints: 4.0,
          pageCount: 128,
          wordCount: 16000,
          publishedDate: DateTime(1943, 4, 6),
          tags: ['고전', '철학', '우정', '성장'],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Book(
          id: 'book_002',
          title: '해리 포터와 마법사의 돌',
          author: 'J.K. 롤링',
          isbn: '9788983920775',
          description: '마법사 해리 포터의 첫 번째 모험을 그린 판타지 소설',
          genre: BookGenre.fantasy,
          arLevel: ARLevel.grade5,
          arPoints: 12.0,
          pageCount: 320,
          wordCount: 80000,
          publishedDate: DateTime(1997, 6, 26),
          tags: ['판타지', '마법', '모험', '우정'],
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Book(
          id: 'book_003',
          title: '과학이 쉬워지는 원소 이야기',
          author: '김희정',
          isbn: '9788962620345',
          description: '원소의 성질과 특징을 재미있게 설명한 과학 교양서',
          genre: BookGenre.science,
          arLevel: ARLevel.grade3,
          arPoints: 3.5,
          pageCount: 180,
          wordCount: 25000,
          publishedDate: DateTime(2020, 3, 15),
          tags: ['과학', '교육', '원소', '화학'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Book(
          id: 'book_004',
          title: '그린 게이블즈의 앤',
          author: '루시 몽고메리',
          isbn: '9788937834677',
          description: '고아 소녀 앤의 성장 이야기를 담은 감동적인 소설',
          genre: BookGenre.fiction,
          arLevel: ARLevel.grade6,
          arPoints: 8.5,
          pageCount: 280,
          wordCount: 65000,
          publishedDate: DateTime(1908, 6, 1),
          tags: ['성장', '가족', '우정', '고전'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Book(
          id: 'book_005',
          title: '세계사 속 위대한 발명품들',
          author: '박미영',
          isbn: '9788965461234',
          description: '인류 문명을 바꾼 중요한 발명품들의 역사',
          genre: BookGenre.history,
          arLevel: ARLevel.middleSchool,
          arPoints: 6.0,
          pageCount: 220,
          wordCount: 40000,
          publishedDate: DateTime(2019, 9, 20),
          tags: ['역사', '발명', '문명', '교육'],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      for (final book in sampleBooks) {
        await _booksBox.put(book.id, book);
      }
    }
  }

  // 도서 목록 조회
  List<Book> getBooks({BookGenre? genre, ARLevel? arLevel, String? searchQuery}) {
    var books = _booksBox.values.where((book) => book.isAvailable).toList();
    
    if (genre != null) {
      books = books.where((book) => book.genre == genre).toList();
    }
    
    if (arLevel != null) {
      books = books.where((book) => book.arLevel == arLevel).toList();
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      books = books.where((book) => 
        book.title.toLowerCase().contains(query) ||
        book.author.toLowerCase().contains(query) ||
        book.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }
    
    // 생성일 기준 내림차순 정렬
    books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return books;
  }

  // 특정 도서 조회
  Book? getBook(String bookId) {
    return _booksBox.get(bookId);
  }

  // 독서 세션 시작
  Future<ReadingSession> startReadingSession(String userId, String bookId, int startPage) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = ReadingSession(
      id: sessionId,
      userId: userId,
      bookId: bookId,
      startedAt: DateTime.now(),
      duration: Duration.zero,
      startPage: startPage,
      endPage: startPage,
      wordsRead: 0,
      status: ReadingStatus.reading,
      vocabularyWords: [],
    );
    
    await _readingSessionsBox.put(sessionId, session);
    return session;
  }

  // 독서 세션 업데이트
  Future<void> updateReadingSession(ReadingSession session) async {
    await _readingSessionsBox.put(session.id, session);
  }

  // 독서 세션 종료
  Future<ReadingSession> endReadingSession(String sessionId, int endPage, String? notes) async {
    final session = _readingSessionsBox.get(sessionId);
    if (session == null) {
      throw Exception('Reading session not found');
    }
    
    final endedAt = DateTime.now();
    final duration = endedAt.difference(session.startedAt);
    final pagesRead = endPage - session.startPage;
    final wordsRead = pagesRead * 200; // 평균 페이지당 200단어 가정
    
    final updatedSession = ReadingSession(
      id: session.id,
      userId: session.userId,
      bookId: session.bookId,
      startedAt: session.startedAt,
      endedAt: endedAt,
      duration: duration,
      startPage: session.startPage,
      endPage: endPage,
      wordsRead: wordsRead,
      status: ReadingStatus.completed,
      notes: notes,
      vocabularyWords: session.vocabularyWords,
    );
    
    await _readingSessionsBox.put(sessionId, updatedSession);
    await _updateReadingProgress(session.userId, session.bookId, endPage, wordsRead, duration);
    
    return updatedSession;
  }

  // 독서 진행 상황 업데이트
  Future<void> _updateReadingProgress(String userId, String bookId, int currentPage, int wordsRead, Duration sessionDuration) async {
    final book = getBook(bookId);
    if (book == null) return;
    
    final progressId = '${userId}_$bookId';
    var progress = _readingProgressBox.get(progressId);
    
    if (progress == null) {
      progress = ReadingProgress(
        id: progressId,
        userId: userId,
        bookId: bookId,
        currentPage: currentPage,
        progressPercentage: (currentPage / book.pageCount * 100).clamp(0, 100),
        lastReadAt: DateTime.now(),
        totalReadingTime: sessionDuration,
        totalWordsRead: wordsRead,
        status: currentPage >= book.pageCount ? ReadingStatus.completed : ReadingStatus.reading,
        bookmarks: [],
        metadata: {},
      );
    } else {
      progress = ReadingProgress(
        id: progress.id,
        userId: progress.userId,
        bookId: progress.bookId,
        currentPage: currentPage,
        progressPercentage: (currentPage / book.pageCount * 100).clamp(0, 100),
        lastReadAt: DateTime.now(),
        totalReadingTime: progress.totalReadingTime + sessionDuration,
        totalWordsRead: progress.totalWordsRead + wordsRead,
        status: currentPage >= book.pageCount ? ReadingStatus.completed : ReadingStatus.reading,
        bookmarks: progress.bookmarks,
        metadata: progress.metadata,
      );
    }
    
    await _readingProgressBox.put(progressId, progress);
  }

  // 독서 진행 상황 조회
  ReadingProgress? getReadingProgress(String userId, String bookId) {
    final progressId = '${userId}_$bookId';
    return _readingProgressBox.get(progressId);
  }

  // 사용자의 독서 진행 목록 조회
  List<ReadingProgress> getUserReadingProgress(String userId) {
    return _readingProgressBox.values
        .where((progress) => progress.userId == userId)
        .toList()
      ..sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
  }

  // AR 기록 추가
  Future<void> addARRecord(String userId, String bookId, double quizScore) async {
    final book = getBook(bookId);
    if (book == null) return;
    
    final recordId = 'ar_${DateTime.now().millisecondsSinceEpoch}';
    final progress = getReadingProgress(userId, bookId);
    
    final record = ARRecord(
      id: recordId,
      userId: userId,
      bookId: bookId,
      arPoints: book.arPoints * (quizScore / 100.0),
      arLevel: book.arLevel,
      quizScore: quizScore,
      completedAt: DateTime.now(),
      readingTime: progress?.totalReadingTime ?? Duration.zero,
      wordsRead: progress?.totalWordsRead ?? 0,
      isVerified: quizScore >= 80.0, // 80점 이상시 검증
      achievements: _calculateAchievements(userId, book, quizScore),
    );
    
    await _arRecordsBox.put(recordId, record);
    await _updateReadingStats(userId);
  }

  // 성취도 계산
  Map<String, dynamic> _calculateAchievements(String userId, Book book, double quizScore) {
    final achievements = <String, dynamic>{};
    
    if (quizScore == 100.0) {
      achievements['perfect_score'] = true;
    }
    if (quizScore >= 90.0) {
      achievements['excellent_reader'] = true;
    }
    if (book.arLevel.index >= ARLevel.grade5.index) {
      achievements['advanced_reader'] = true;
    }
    
    return achievements;
  }

  // 독서 통계 업데이트
  Future<void> _updateReadingStats(String userId) async {
    final userRecords = _arRecordsBox.values.where((record) => record.userId == userId).toList();
    final userProgress = getUserReadingProgress(userId);
    
    final completedBooks = userProgress.where((p) => p.status == ReadingStatus.completed).length;
    final totalARPoints = userRecords.fold<double>(0.0, (sum, record) => sum + record.arPoints);
    final totalReadingTime = userProgress.fold<Duration>(Duration.zero, (sum, p) => sum + p.totalReadingTime);
    final totalWordsRead = userProgress.fold<int>(0, (sum, p) => sum + p.totalWordsRead);
    final averageQuizScore = userRecords.isNotEmpty ? 
        userRecords.fold<double>(0.0, (sum, record) => sum + record.quizScore) / userRecords.length : 0.0;
    
    // 장르 선호도 계산
    final genreMap = <BookGenre, int>{};
    for (final progress in userProgress) {
      final book = getBook(progress.bookId);
      if (book != null) {
        genreMap[book.genre] = (genreMap[book.genre] ?? 0) + 1;
      }
    }
    
    // AR 레벨 계산 (총 AR 포인트 기준)
    ARLevel currentLevel = ARLevel.preschool;
    if (totalARPoints >= 100) currentLevel = ARLevel.highSchool;
    else if (totalARPoints >= 80) currentLevel = ARLevel.middleSchool;
    else if (totalARPoints >= 60) currentLevel = ARLevel.grade6;
    else if (totalARPoints >= 45) currentLevel = ARLevel.grade5;
    else if (totalARPoints >= 30) currentLevel = ARLevel.grade4;
    else if (totalARPoints >= 20) currentLevel = ARLevel.grade3;
    else if (totalARPoints >= 12) currentLevel = ARLevel.grade2;
    else if (totalARPoints >= 6) currentLevel = ARLevel.grade1;
    else if (totalARPoints >= 2) currentLevel = ARLevel.kindergarten;
    
    final stats = ReadingStats(
      userId: userId,
      booksRead: completedBooks,
      totalARPoints: totalARPoints,
      currentARLevel: currentLevel,
      totalReadingTime: totalReadingTime,
      totalWordsRead: totalWordsRead,
      averageQuizScore: averageQuizScore,
      genrePreferences: genreMap,
      achievements: _calculateUserAchievements(userRecords, userProgress),
      lastUpdated: DateTime.now(),
      readingStreak: _calculateReadingStreak(userProgress),
      monthlyProgress: _calculateMonthlyProgress(userProgress),
    );
    
    await _readingStatsBox.put(userId, stats);
  }

  // 사용자 성취도 계산
  List<String> _calculateUserAchievements(List<ARRecord> records, List<ReadingProgress> progress) {
    final achievements = <String>[];
    
    if (records.length >= 10) achievements.add('dedicated_reader');
    if (records.length >= 50) achievements.add('book_master');
    if (records.any((r) => r.quizScore == 100.0)) achievements.add('perfectionist');
    if (progress.length >= 5) achievements.add('explorer');
    
    return achievements;
  }

  // 독서 연속일 계산
  int _calculateReadingStreak(List<ReadingProgress> progress) {
    if (progress.isEmpty) return 0;
    
    progress.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
    
    int streak = 0;
    DateTime current = DateTime.now();
    
    for (final p in progress) {
      final daysDiff = current.difference(p.lastReadAt).inDays;
      if (daysDiff <= 1) {
        streak++;
        current = p.lastReadAt;
      } else {
        break;
      }
    }
    
    return streak;
  }

  // 월별 진행 상황 계산
  Map<String, dynamic> _calculateMonthlyProgress(List<ReadingProgress> progress) {
    final monthly = <String, dynamic>{};
    final now = DateTime.now();
    
    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      
      final monthProgress = progress.where((p) => 
        p.lastReadAt.year == month.year && p.lastReadAt.month == month.month
      ).toList();
      
      monthly[monthKey] = {
        'books_read': monthProgress.length,
        'total_time': monthProgress.fold<int>(0, (sum, p) => sum + p.totalReadingTime.inMinutes),
        'total_words': monthProgress.fold<int>(0, (sum, p) => sum + p.totalWordsRead),
      };
    }
    
    return monthly;
  }

  // 독서 통계 조회
  ReadingStats? getReadingStats(String userId) {
    return _readingStatsBox.get(userId);
  }

  // AR 기록 조회
  List<ARRecord> getARRecords(String userId) {
    return _arRecordsBox.values
        .where((record) => record.userId == userId)
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  // 독서 세션 목록 조회
  List<ReadingSession> getReadingSessions(String userId, {String? bookId}) {
    var sessions = _readingSessionsBox.values
        .where((session) => session.userId == userId)
        .toList();
    
    if (bookId != null) {
      sessions = sessions.where((session) => session.bookId == bookId).toList();
    }
    
    return sessions..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // 도서 추천 (AR 레벨과 장르 선호도 기반)
  List<Book> getRecommendedBooks(String userId, {int limit = 10}) {
    final stats = getReadingStats(userId);
    if (stats == null) return getBooks().take(limit).toList();
    
    final userLevel = stats.currentARLevel;
    final favoriteGenres = stats.genrePreferences.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final books = getBooks();
    final scored = <MapEntry<Book, double>>[];
    
    for (final book in books) {
      double score = 0.0;
      
      // AR 레벨 점수 (현재 레벨 ±1 범위)
      final levelDiff = (book.arLevel.index - userLevel.index).abs();
      if (levelDiff <= 1) score += 50.0;
      else if (levelDiff <= 2) score += 25.0;
      
      // 장르 선호도 점수
      final genreRank = favoriteGenres.indexWhere((entry) => entry.key == book.genre);
      if (genreRank >= 0) {
        score += (5 - genreRank) * 10.0;
      }
      
      // 최신도 점수
      final daysSinceCreated = DateTime.now().difference(book.createdAt).inDays;
      if (daysSinceCreated <= 30) score += 10.0;
      
      scored.add(MapEntry(book, score));
    }
    
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((entry) => entry.key).toList();
  }

  void dispose() {
    _booksBox.close();
    _readingSessionsBox.close();
    _readingProgressBox.close();
    _arRecordsBox.close();
    _readingStatsBox.close();
  }
}