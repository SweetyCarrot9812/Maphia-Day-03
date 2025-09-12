import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/reading_models.dart';
import '../services/reading_service.dart';
import '../../../core/router/app_router.dart';

final readingServiceProvider = Provider<ReadingService>((ref) => ReadingService());

final booksProvider = FutureProvider<List<Book>>((ref) async {
  final service = ref.read(readingServiceProvider);
  await service.initialize();
  return service.getBooks();
});

final bookSearchProvider = StateProvider<String>((ref) => '');
final selectedGenreProvider = StateProvider<BookGenre?>((ref) => null);
final selectedARLevelProvider = StateProvider<ARLevel?>((ref) => null);

final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final booksAsync = ref.watch(booksProvider);
  final searchQuery = ref.watch(bookSearchProvider);
  final selectedGenre = ref.watch(selectedGenreProvider);
  final selectedARLevel = ref.watch(selectedARLevelProvider);

  return booksAsync.whenData((books) {
    var filteredBooks = books;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredBooks = filteredBooks.where((book) =>
        book.title.toLowerCase().contains(query) ||
        book.author.toLowerCase().contains(query) ||
        book.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    if (selectedGenre != null) {
      filteredBooks = filteredBooks.where((book) => book.genre == selectedGenre).toList();
    }

    if (selectedARLevel != null) {
      filteredBooks = filteredBooks.where((book) => book.arLevel == selectedARLevel).toList();
    }

    return filteredBooks;
  });
});

class BookListScreen extends ConsumerStatefulWidget {
  const BookListScreen({super.key});

  @override
  ConsumerState<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends ConsumerState<BookListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooksAsync = ref.watch(filteredBooksProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '도서 목록',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 바
          Container(
            padding: EdgeInsets.all(16.w),
            color: Theme.of(context).cardColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '도서명, 작가명, 태그로 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(bookSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onChanged: (value) {
                ref.read(bookSearchProvider.notifier).state = value;
              },
            ),
          ),
          
          // 도서 목록
          Expanded(
            child: filteredBooksAsync.when(
              data: (books) => books.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64.sp,
                            color: Theme.of(context).disabledColor,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return BookCard(book: book);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '도서를 불러오는 중 오류가 발생했습니다',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => ref.refresh(booksProvider),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('장르', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8.h),
              Consumer(
                builder: (context, ref, child) {
                  final selectedGenre = ref.watch(selectedGenreProvider);
                  return Wrap(
                    spacing: 8.w,
                    children: BookGenre.values.map((genre) {
                      return FilterChip(
                        label: Text(_getGenreLabel(genre)),
                        selected: selectedGenre == genre,
                        onSelected: (selected) {
                          ref.read(selectedGenreProvider.notifier).state = 
                              selected ? genre : null;
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 16.h),
              Text('AR 레벨', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8.h),
              Consumer(
                builder: (context, ref, child) {
                  final selectedLevel = ref.watch(selectedARLevelProvider);
                  return Wrap(
                    spacing: 8.w,
                    children: ARLevel.values.map((level) {
                      return FilterChip(
                        label: Text(_getARLevelLabel(level)),
                        selected: selectedLevel == level,
                        onSelected: (selected) {
                          ref.read(selectedARLevelProvider.notifier).state = 
                              selected ? level : null;
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(selectedGenreProvider.notifier).state = null;
              ref.read(selectedARLevelProvider.notifier).state = null;
              Navigator.of(context).pop();
            },
            child: const Text('초기화'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  String _getGenreLabel(BookGenre genre) {
    switch (genre) {
      case BookGenre.fiction: return '소설';
      case BookGenre.nonFiction: return '논픽션';
      case BookGenre.fantasy: return '판타지';
      case BookGenre.mystery: return '추리';
      case BookGenre.romance: return '로맨스';
      case BookGenre.scienceFiction: return 'SF';
      case BookGenre.biography: return '전기';
      case BookGenre.history: return '역사';
      case BookGenre.science: return '과학';
      case BookGenre.selfHelp: return '자기계발';
      case BookGenre.children: return '아동';
      case BookGenre.educational: return '교육';
    }
  }

  String _getARLevelLabel(ARLevel level) {
    switch (level) {
      case ARLevel.preschool: return '유아';
      case ARLevel.kindergarten: return '유치원';
      case ARLevel.grade1: return '1학년';
      case ARLevel.grade2: return '2학년';
      case ARLevel.grade3: return '3학년';
      case ARLevel.grade4: return '4학년';
      case ARLevel.grade5: return '5학년';
      case ARLevel.grade6: return '6학년';
      case ARLevel.middleSchool: return '중학교';
      case ARLevel.highSchool: return '고등학교';
    }
  }
}

class BookCard extends ConsumerWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () => _navigateToBookDetail(context, ref),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 도서 표지
              Container(
                width: 80.w,
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: book.coverImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          book.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderCover(context),
                        ),
                      )
                    : _buildPlaceholderCover(context),
              ),
              SizedBox(width: 16.w),
              
              // 도서 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildInfoChip(context, _getGenreLabel(book.genre), Icons.category),
                        SizedBox(width: 8.w),
                        _buildInfoChip(context, _getARLevelLabel(book.arLevel), Icons.star),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.auto_stories, size: 16.sp, color: Theme.of(context).hintColor),
                        SizedBox(width: 4.w),
                        Text(
                          '${book.pageCount}p',
                          style: TextStyle(fontSize: 12.sp, color: Theme.of(context).hintColor),
                        ),
                        SizedBox(width: 16.w),
                        Icon(Icons.grade, size: 16.sp, color: Theme.of(context).hintColor),
                        SizedBox(width: 4.w),
                        Text(
                          'AR ${book.arPoints}',
                          style: TextStyle(fontSize: 12.sp, color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                    if (book.description != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        book.description!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.book,
        size: 32.sp,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  String _getGenreLabel(BookGenre genre) {
    switch (genre) {
      case BookGenre.fiction: return '소설';
      case BookGenre.nonFiction: return '논픽션';
      case BookGenre.fantasy: return '판타지';
      case BookGenre.mystery: return '추리';
      case BookGenre.romance: return '로맨스';
      case BookGenre.scienceFiction: return 'SF';
      case BookGenre.biography: return '전기';
      case BookGenre.history: return '역사';
      case BookGenre.science: return '과학';
      case BookGenre.selfHelp: return '자기계발';
      case BookGenre.children: return '아동';
      case BookGenre.educational: return '교육';
    }
  }

  String _getARLevelLabel(ARLevel level) {
    switch (level) {
      case ARLevel.preschool: return '유아';
      case ARLevel.kindergarten: return '유치원';
      case ARLevel.grade1: return '1학년';
      case ARLevel.grade2: return '2학년';
      case ARLevel.grade3: return '3학년';
      case ARLevel.grade4: return '4학년';
      case ARLevel.grade5: return '5학년';
      case ARLevel.grade6: return '6학년';
      case ARLevel.middleSchool: return '중학교';
      case ARLevel.highSchool: return '고등학교';
    }
  }

  void _navigateToBookDetail(BuildContext context, WidgetRef ref) {
    // 도서 상세 페이지로 이동
    // TODO: 라우터 구현 후 추가
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} 상세 페이지로 이동')),
    );
  }
}