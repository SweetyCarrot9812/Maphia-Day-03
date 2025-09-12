import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class AiChatSetupScreen extends StatefulWidget {
  const AiChatSetupScreen({super.key});

  @override
  State<AiChatSetupScreen> createState() => _AiChatSetupScreenState();
}

class _AiChatSetupScreenState extends State<AiChatSetupScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSetupComplete = false;
  
  // 설정 진행 상태
  int _currentStep = 0;
  String _selectedProfession = '';
  String _selectedLevel = '';
  String _selectedDepartment = '';
  
  // 단계별 질문 데이터
  final List<Map<String, dynamic>> _setupSteps = [
    {
      'question': '안녕하세요! Clintest에 오신 것을 환영합니다! 🎉\n\n개인화된 학습 환경을 위해 몇 가지 질문을 드릴게요.\n\n먼저 직종을 알려주세요:\n\n1️⃣ 간호사\n2️⃣ 의사\n\n숫자나 직종명으로 답변해주세요!',
      'options': ['간호사', '의사', '1', '2'],
      'field': 'profession'
    },
    {
      'question': '간호사 중에서 어떤 레벨에 해당하시나요?\n\n1️⃣ 학생 간호사\n2️⃣ 간호사\n3️⃣ 임상전문간호사\n\n숫자나 레벨명으로 답변해주세요!',
      'options': ['학생 간호사', '간호사', '임상전문간호사', '1', '2', '3'],
      'field': 'level',
      'condition': 'profession_nurse'
    },
    {
      'question': '어느 과에서 근무하고 계시나요?\n\n다음 중에서 선택하거나 직접 입력해주세요:\n\n1️⃣ 내과\n2️⃣ 외과\n3️⃣ 응급실\n4️⃣ 중환자실\n5️⃣ 수술실\n6️⃣ 소아과\n7️⃣ 산부인과\n8️⃣ 정신과\n9️⃣ 기타 (직접 입력)',
      'options': ['내과', '외과', '응급실', '중환자실', '수술실', '소아과', '산부인과', '정신과', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
      'field': 'department',
      'condition': 'level_not_student'
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startConversation() async {
    setState(() => _isLoading = true);
    
    try {
      // 첫 번째 질문부터 시작
      setState(() {
        _messages.add(ChatMessage(
          text: '안녕하세요! Clintest에 오신 것을 환영합니다! 🎉\n\n개인화된 학습 환경을 위해 몇 가지 질문을 드릴게요.\n\n먼저 직종을 알려주세요:\n\n1️⃣ 간호사\n2️⃣ 의사\n\n숫자나 직종명으로 답변해주세요!',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      print('초기 대화 시작 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage(String message, {bool isInitial = false}) async {
    if (message.trim().isEmpty && !isInitial) return;

    // 사용자 메시지 추가 (초기 메시지가 아닐 때만)
    if (!isInitial) {
      setState(() {
        _messages.add(ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _isLoading = true;
      });
      
      _messageController.clear();
      _scrollToBottom();
    }

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // 자연스러운 응답 지연
      
      String responseText = '';
      bool moveToNext = false;

      // 현재 단계 처리
      if (_currentStep < _setupSteps.length) {
        final currentStepData = _setupSteps[_currentStep];
        
        if (_currentStep == 0) { // 직종 선택
          if (_isValidOption(message, currentStepData['options'])) {
            _selectedProfession = _normalizeInput(message, ['간호사', '의사', '1', '2']);
            if (_selectedProfession == '1') _selectedProfession = '간호사';
            if (_selectedProfession == '2') _selectedProfession = '의사';
            
            if (_selectedProfession == '간호사') {
              responseText = '좋습니다! 간호사로 선택해주셨네요. 👩‍⚕️';
              moveToNext = true;
            } else if (_selectedProfession == '의사') {
              responseText = '좋습니다! 의사로 선택해주셨네요. 👨‍⚕️\n\n설정이 완료되었습니다! 의사용 맞춤 학습 환경으로 설정해드리겠습니다.';
              setState(() => _isSetupComplete = true);
            }
          } else {
            responseText = '죄송합니다. 1️⃣ 간호사 또는 2️⃣ 의사 중에서 선택해주세요. 숫자나 직종명으로 답변 가능합니다.';
          }
        }
        else if (_currentStep == 1 && _selectedProfession == '간호사') { // 간호사 레벨 선택
          if (_isValidOption(message, currentStepData['options'])) {
            _selectedLevel = _normalizeInput(message, ['학생 간호사', '간호사', '임상전문간호사', '1', '2', '3']);
            if (_selectedLevel == '1') _selectedLevel = '학생 간호사';
            if (_selectedLevel == '2') _selectedLevel = '간호사';
            if (_selectedLevel == '3') _selectedLevel = '임상전문간호사';
            
            if (_selectedLevel == '학생 간호사') {
              responseText = '학생 간호사로 설정되었습니다! 📚\n\n설정이 완료되었습니다! 학생 간호사에게 최적화된 학습 환경으로 준비해드리겠습니다.';
              setState(() => _isSetupComplete = true);
            } else {
              responseText = '$_selectedLevel로 설정되었습니다! 👩‍⚕️';
              moveToNext = true;
            }
          } else {
            responseText = '죄송합니다. 1️⃣ 학생 간호사, 2️⃣ 간호사, 3️⃣ 임상전문간호사 중에서 선택해주세요.';
          }
        }
        else if (_currentStep == 2 && _selectedLevel != '학생 간호사') { // 과 선택
          if (_isValidOption(message, currentStepData['options']) || message == '9' || message == '기타') {
            String department = message;
            if (message == '1') {
              department = '내과';
            } else if (message == '2') department = '외과';
            else if (message == '3') department = '응급실';
            else if (message == '4') department = '중환자실';
            else if (message == '5') department = '수술실';
            else if (message == '6') department = '소아과';
            else if (message == '7') department = '산부인과';
            else if (message == '8') department = '정신과';
            else if (message == '9') department = '기타';
            
            if (department == '기타' || message == '9') {
              responseText = '기타를 선택하셨네요. 어떤 과에서 근무하시는지 직접 입력해주세요.';
              return; // 다시 입력 받기
            } else {
              _selectedDepartment = department;
              responseText = '$_selectedDepartment 근무 $_selectedLevel로 설정되었습니다! 🏥\n\n설정이 완료되었습니다! $_selectedDepartment에서 근무하는 $_selectedLevel에게 최적화된 학습 환경으로 준비해드리겠습니다.';
              setState(() => _isSetupComplete = true);
            }
          } else if (_selectedDepartment.isEmpty && message != '9' && message != '기타') {
            // 직접 입력한 과명
            _selectedDepartment = message;
            responseText = '$_selectedDepartment 근무 $_selectedLevel로 설정되었습니다! 🏥\n\n설정이 완료되었습니다! $_selectedDepartment에서 근무하는 $_selectedLevel에게 최적화된 학습 환경으로 준비해드리겠습니다.';
            setState(() => _isSetupComplete = true);
          } else {
            responseText = '죄송합니다. 목록에서 선택하거나 9번을 선택해서 직접 입력해주세요.';
          }
        }
      }

      setState(() {
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();

      // 다음 단계로 이동
      if (moveToNext && _currentStep + 1 < _setupSteps.length) {
        setState(() => _currentStep++);
        
        await Future.delayed(const Duration(milliseconds: 800));
        
        // 다음 질문 표시
        final nextStepData = _setupSteps[_currentStep];
        if (_shouldShowStep(nextStepData)) {
          setState(() {
            _messages.add(ChatMessage(
              text: nextStepData['question'],
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
          _scrollToBottom();
        }
      }

    } catch (e) {
      print('메시지 처리 오류: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: '죄송합니다. 오류가 발생했습니다. 다시 시도해주세요.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidOption(String input, List<String> options) {
    final cleanInput = input.trim().toLowerCase();
    return options.any((option) => option.toLowerCase() == cleanInput);
  }

  String _normalizeInput(String input, List<String> validOptions) {
    final cleanInput = input.trim().toLowerCase();
    for (String option in validOptions) {
      if (option.toLowerCase() == cleanInput) {
        return option;
      }
    }
    return input.trim();
  }

  bool _shouldShowStep(Map<String, dynamic> stepData) {
    if (!stepData.containsKey('condition')) return true;
    
    final condition = stepData['condition'];
    if (condition == 'profession_nurse') {
      return _selectedProfession == '간호사';
    } else if (condition == 'level_not_student') {
      return _selectedLevel != '학생 간호사' && _selectedLevel.isNotEmpty;
    }
    return true;
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

  void _completeSetup() async {
    setState(() => _isLoading = true);

    try {
      // 사용자 설정 정보 저장
      await StorageService.setString('user_profession', _selectedProfession);
      await StorageService.setString('user_level', _selectedLevel);
      await StorageService.setString('user_department', _selectedDepartment);
      
      // 설정 완료 표시
      await StorageService.setBool('ai_setup_completed', true);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      print('설정 완료 오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('AI와 함께 개인 설정하기'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 안내 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              'AI가 당신의 학습 환경을 맞춤 설정해드립니다. 자연스럽게 대화해보세요!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 채팅 메시지 리스트
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // 입력 영역
          if (!_isSetupComplete)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (text) => _sendMessage(text),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isLoading 
                        ? null 
                        : () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),

          // 설정 완료 버튼
          if (_isSetupComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeSetup,
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '설정 완료하고 시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              radius: 16,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.secondaryColor,
              radius: 16,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            radius: 16,
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('AI가 입력 중...'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}