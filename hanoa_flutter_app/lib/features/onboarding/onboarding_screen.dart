import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/auth_provider.dart';
import 'models/onboarding_models.dart';
import 'services/gpt_demo_service.dart';
import 'widgets/onboarding_progress_widget.dart';
import 'widgets/chat_message_widget.dart';
import 'widgets/chat_input_widget.dart';

/// 온보딩 화면 - GPT 집사와의 대화형 온보딩
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  OnboardingStep _currentStep = OnboardingStep.greeting;
  OnboardingData _onboardingData = OnboardingData();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isCompleted = false;

  late AnimationController _completionAnimationController;
  late Animation<double> _lightSpreadAnimation;

  @override
  void initState() {
    super.initState();
    _completionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _lightSpreadAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionAnimationController,
      curve: Curves.easeOut,
    ));

    _initializeChat();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _completionAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final botMessage = await GPTDemoService.getBotMessage(
      _currentStep,
      currentData: _onboardingData,
    );
    
    setState(() {
      _messages = [botMessage];
    });
    
    _scrollToBottom();
  }

  Future<void> _sendMessage(String text) async {
    if (_isLoading || _isCompleted) return;

    // 사용자 입력 검증
    final validationError = GPTDemoService.validateUserInput(text, _currentStep);
    if (validationError != null) {
      return; // 에러는 ChatInputWidget에서 표시됨
    }

    setState(() {
      _isLoading = true;
    });

    // 사용자 메시지 추가
    final userMessage = await GPTDemoService.processUserResponse(
      text,
      _currentStep,
      _onboardingData,
    );
    
    setState(() {
      _messages.add(userMessage);
    });
    
    _scrollToBottom();
    
    // 온보딩 데이터 업데이트
    _onboardingData = GPTDemoService.updateDataFromResponse(
      _onboardingData,
      text,
      _currentStep,
    );

    // 다음 단계로 진행
    final nextStep = _currentStep.next;
    if (nextStep != null) {
      _currentStep = nextStep;
      
      // 봇 응답 생성
      final botMessage = await GPTDemoService.getBotMessage(
        _currentStep,
        userName: _onboardingData.displayName,
        currentData: _onboardingData,
      );
      
      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
      });
      
      _scrollToBottom();
    } else {
      // 온보딩 완료
      await _completeOnboarding();
    }
    
    _inputController.clear();
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isCompleted = true;
      _isLoading = false;
    });

    // 완료 애니메이션 시작
    _completionAnimationController.forward();

    // 온보딩 데이터 저장
    final authProvider = context.read<AuthProvider>();
    await authProvider.completeOnboarding(_onboardingData);

    // 애니메이션 완료 후 홈으로 이동
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
    }
  }

  void _onQuickReplyTap(String reply) {
    _inputController.text = reply;
    _sendMessage(reply);
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

  String? _validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '입력해주세요';
    }
    return GPTDemoService.validateUserInput(value.trim(), _currentStep);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          Column(
            children: [
              // 진행률 헤더
              OnboardingProgressWidget(
                currentStep: _currentStep,
                progress: _onboardingData.completionProgress,
              ),

              // 채팅 메시지들
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingM,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return ChatMessageWidget(
                      message: message,
                      onQuickReplyTap: () => _onQuickReplyTap(
                        message.quickReplies?.first ?? '',
                      ),
                    );
                  },
                ),
              ),

              // 입력 필드
              if (!_isCompleted)
                ChatInputWidget(
                  controller: _inputController,
                  onSend: () => _sendMessage(_inputController.text.trim()),
                  isEnabled: !_isLoading,
                  hintText: _getInputHint(),
                  validator: _validateInput,
                ),
            ],
          ),

          // 완료 애니메이션 오버레이
          if (_isCompleted)
            AnimatedBuilder(
              animation: _lightSpreadAnimation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: _lightSpreadAnimation.value * 2.0,
                      colors: [
                        AppColors.hanoaGold.withOpacity(0.8),
                        AppColors.hanoaNavy.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                  child: _lightSpreadAnimation.value > 0.5
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundWhite,
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.hanoaGold.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.hanoaNavy,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                '설정 완료!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Hanoa에 오신 것을 환영합니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                );
              },
            ),
        ],
      ),
    );
  }

  String _getInputHint() {
    switch (_currentStep) {
      case OnboardingStep.greeting:
      case OnboardingStep.name:
        return '이름을 입력해주세요';
      case OnboardingStep.notifications:
        return '알림 시간을 입력해주세요 (예: 07:30)';
      default:
        return '메시지를 입력하세요';
    }
  }
}