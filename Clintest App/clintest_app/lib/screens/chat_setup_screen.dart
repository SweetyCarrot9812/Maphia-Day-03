import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'student_nurse_home_screen.dart';
import 'splash_screen.dart';

class ChatSetupScreen extends StatefulWidget {
  const ChatSetupScreen({super.key});

  @override
  State<ChatSetupScreen> createState() => _ChatSetupScreenState();
}

class _ChatSetupScreenState extends State<ChatSetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0; // 0: 환영, 1: 역할 선택, 3: 완료
  String? _selectedRole;

  final List<String> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
        
    _slideAnimation = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _startWelcomeSequence();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startWelcomeSequence() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _addMessage("안녕하세요! 👋 Clintest에 오신 것을 환영합니다!");
    await Future.delayed(const Duration(milliseconds: 1500));
    _addMessage("저는 여러분의 의료 학습을 도와드릴 AI 어시스턴트입니다. 🤖");
    await Future.delayed(const Duration(milliseconds: 1500));
    _addMessage("먼저 여러분의 의료 분야 역할을 알려주시겠어요?");
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _currentStep = 1;
    });
  }

  void _addMessage(String message) {
    setState(() {
      _chatMessages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _selectRole(String role) async {
    setState(() {
      _selectedRole = role;
    });
    
    _addMessage("$role를 선택하셨네요! 👍");
    await Future.delayed(const Duration(milliseconds: 1000));
    
    _addMessage("좋습니다! 나머지 세부 전문 분야는 대화를 통해 알아가겠습니다. 🤖");
    await Future.delayed(const Duration(milliseconds: 1500));
    
    _addMessage("설정이 완료되었습니다! 이제 맞춤형 학습을 시작할 수 있어요! ✨");
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // 설정 저장 (부서는 AI와 대화하며 설정)
    await StorageService.setString('user_role', role);
    await StorageService.setString('user_department', '$role - AI 맞춤 설정');
    
    setState(() {
      _currentStep = 3;
    });
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _navigateToHome();
  }


  void _navigateToHome() {
    Widget targetScreen;
    if (_selectedRole == '학생간호사') {
      targetScreen = const StudentNurseHomeScreen();
    } else {
      targetScreen = const HomeScreen();
    }
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            // 좌측 캐릭터 영역
            Expanded(
              flex: 2,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // AI 캐릭터
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.secondaryColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // AI 이름
                      Text(
                        'Dr. AI',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Clintest AI Assistant',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 우측 채팅 영역
            Expanded(
              flex: 3,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
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
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '설정 도우미',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const Spacer(),
                            // 데모 재시작 버튼
                            IconButton(
                              onPressed: _restartDemo,
                              icon: const Icon(
                                Icons.refresh,
                                color: AppTheme.primaryColor,
                              ),
                              tooltip: '데모 재시작',
                            ),
                          ],
                        ),
                      ),
                      
                      // 채팅 메시지 영역
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.primaryColor,
                                    child: const Icon(
                                      Icons.smart_toy,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _chatMessages[index],
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // 선택 버튼 영역
                      if (_currentStep == 1) _buildRoleSelection(),
                      if (_currentStep == 3) _buildCompletionMessage(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '역할을 선택해주세요:',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '학생간호사',
              '간호사',
              '의사',
            ].map((role) {
              return ActionChip(
                label: Text(role),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                onPressed: () => _selectRole(role),
                labelStyle: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


  Widget _buildCompletionMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            size: 48,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          Text(
            '설정 완료!',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '잠시 후 메인 화면으로 이동합니다...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _restartDemo() async {
    // 데모 재시작을 위해 설정 초기화
    await StorageService.clear();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }
}