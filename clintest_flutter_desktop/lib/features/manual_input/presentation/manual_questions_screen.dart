import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ManualQuestionsScreen extends ConsumerStatefulWidget {
  const ManualQuestionsScreen({super.key});

  @override
  ConsumerState<ManualQuestionsScreen> createState() => _ManualQuestionsScreenState();
}

class _ManualQuestionsScreenState extends ConsumerState<ManualQuestionsScreen> {
  String? selectedSubject;

  final List<String> subjects = [
    '성인간호학',
    '모성간호학',
    '아동간호학',
    '지역사회간호학',
    '정신간호학',
    '간호관리학',
    '기본간호학',
    '보건의약관계법규',
  ];

  final Map<String, Color> subjectColors = {
    '성인간호학': Colors.blue,
    '모성간호학': Colors.pink,
    '아동간호학': Colors.orange,
    '지역사회간호학': Colors.green,
    '정신간호학': Colors.purple,
    '간호관리학': Colors.red,
    '기본간호학': Colors.teal,
    '보건의약관계법규': Colors.brown,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수동 문제 입력'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  size: 32.r,
                  color: Colors.orange,
                ),
                SizedBox(width: 12.w),
                Text(
                  '문제 입력을 위한 과목을 선택해주세요',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            
            // 과목 선택 그리드 (컴팩트)
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.8,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final color = subjectColors[subject]!;
                  final isSelected = selectedSubject == subject;
                  
                  return _buildSubjectCard(
                    context,
                    subject,
                    color,
                    isSelected,
                    () {
                      setState(() {
                        selectedSubject = subject;
                      });
                    },
                  );
                },
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // 다음 단계 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedSubject != null ? () {
                  context.go('/question-input/$selectedSubject');
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  '다음 단계',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String subject,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '문제 입력',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 18.r,
              ),
          ],
        ),
      ),
    );
  }
}