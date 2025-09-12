import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'splash_screen.dart';

class LingumoHomeScreen extends StatefulWidget {
  const LingumoHomeScreen({super.key});

  @override
  State<LingumoHomeScreen> createState() => _LingumoHomeScreenState();
}

class _LingumoHomeScreenState extends State<LingumoHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _characterController;
  late Animation<double> _characterAnimation;
  late AnimationController _bubbleController;
  late Animation<Offset> _bubbleAnimation;
  
  String _currentMessage = "안녕하세요! 오늘은 무엇을 학습하고 싶으신가요? 🎯";
  bool _showInputArea = false;
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    
    _characterController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _characterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.elasticOut),
    );
    
    _bubbleAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bubbleController, curve: Curves.bounceOut));

    _startAnimation();
    _loadWelcomeMessage();
  }

  @override
  void dispose() {
    _characterController.dispose();
    _bubbleController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    _characterController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _bubbleController.forward();
  }

  void _loadWelcomeMessage() {
    final role = StorageService.getString('user_role') ?? '의료진';
    final department = StorageService.getString('user_department') ?? '';
    
    if (role == '간호사') {
      _currentMessage = "안녕하세요 간호사님! 👩‍⚕️\\n오늘은 어떤 간호 지식을 학습해볼까요?";
    } else if (role == '의사') {
      _currentMessage = "안녕하세요 의사선생님! 👨‍⚕️\\n오늘은 어떤 의료 지식을 학습해보시겠어요?";
    } else if (role == '학습자') {
      _currentMessage = "안녕하세요! 👋\\n의료 학습에 도움이 필요하시면 언제든 말씀해주세요!";
    } else {
      _currentMessage = "안녕하세요 $role님! 🏥\\n대화를 통해 맞춤 학습을 제공해드릴게요!";
    }
    setState(() {});
  }

  void _sendMessage() {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatHistory.add(ChatMessage(message: message, isUser: true));
      _chatController.clear();
    });

    // AI 응답 시뮬레이션
    _simulateAIResponse(message);
  }

  void _simulateAIResponse(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    String response = "흥미로운 질문이네요! 🤔\\n관련된 학습 자료를 준비해드릴게요.";
    
    if (userMessage.toLowerCase().contains('심전도') || userMessage.toLowerCase().contains('ecg')) {
      response = "심전도 해석에 대해 학습하고 싶으시군요! 📈\\n기본 리듬부터 차근차근 설명해드릴게요.";
    } else if (userMessage.toLowerCase().contains('약물') || userMessage.toLowerCase().contains('medication')) {
      response = "약물 관리는 정말 중요한 부분이죠! 💊\\n안전한 투약을 위한 핵심 원칙들을 알려드릴게요.";
    } else if (userMessage.toLowerCase().contains('감염') || userMessage.toLowerCase().contains('infection')) {
      response = "감염 관리에 대해 궁금하시군요! 🦠\\n표준 예방법부터 시작해보시죠.";
    }

    setState(() {
      _chatHistory.add(ChatMessage(message: response, isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            _buildHeader(),
            
            // 메인 캐릭터 영역
            Expanded(
              flex: 3,
              child: _buildCharacterArea(),
            ),
            
            // 채팅 히스토리 (확장 가능)
            if (_showInputArea) _buildChatHistory(),
            
            // 하단 입력 영역
            _buildBottomArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final role = StorageService.getString('user_role') ?? '의료진';
    final department = StorageService.getString('user_department') ?? '';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              _getRoleIcon(role),
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (department.isNotEmpty)
                  Text(
                    department,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // 데모 재시작 버튼
          IconButton(
            onPressed: _restartDemo,
            icon: const Icon(
              Icons.refresh,
              color: AppTheme.primaryColor,
            ),
            tooltip: '데모 재시작',
          ),
          
          // 설정 버튼
          IconButton(
            onPressed: () {
              // 설정 화면으로 이동
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // AI 캐릭터
          AnimatedBuilder(
            animation: _characterController,
            builder: (context, child) {
              return Transform.scale(
                scale: _characterAnimation.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.2),
                        AppTheme.secondaryColor.withOpacity(0.2),
                        AppTheme.accentColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(75),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 70,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // 말풍선
          SlideTransition(
            position: _bubbleAnimation,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _currentMessage,
                    style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 기본 학습 기능들
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickActionChip('임상 문제', Icons.assignment, () {
                        _handleQuickAction('임상 문제를 풀어보고 싶어요');
                      }),
                      _buildQuickActionChip('간호 이론', Icons.school, () {
                        _handleQuickAction('간호 이론을 학습하고 싶어요');
                      }),
                      _buildQuickActionChip('실습 준비', Icons.medical_services, () {
                        _handleQuickAction('실습 준비를 도와주세요');
                      }),
                      _buildQuickActionChip('국시 대비', Icons.assignment_turned_in, () {
                        _handleQuickAction('간호사 국가시험 준비를 해주세요');
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppTheme.primaryColor),
      label: Text(label),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      onPressed: onTap,
      labelStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  Widget _buildChatHistory() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: ListView.builder(
        itemCount: _chatHistory.length,
        itemBuilder: (context, index) {
          final chat = _chatHistory[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: chat.isUser 
                    ? AppTheme.accentColor 
                    : AppTheme.primaryColor,
                  child: Icon(
                    chat.isUser ? Icons.person : Icons.smart_toy,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chat.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: chat.isUser 
                        ? AppTheme.textSecondary 
                        : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 채팅 토글 버튼
          if (!_showInputArea)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showInputArea = true;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Dr. AI와 대화하기',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 입력 영역
          if (_showInputArea)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: '궁금한 의료 지식을 물어보세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: AppTheme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: AppTheme.primaryColor,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case '간호사':
        return Icons.healing;
      case '의사':
        return Icons.local_hospital;
      case '학습자':
        return Icons.school;
      default:
        return Icons.person;
    }
  }

  void _handleQuickAction(String action) {
    setState(() {
      _showInputArea = true;
      _chatHistory.add(ChatMessage(message: action, isUser: true));
    });
    _simulateAIResponse(action);
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

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}