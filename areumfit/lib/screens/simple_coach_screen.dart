import 'package:flutter/material.dart';

class SimpleCoachScreen extends StatefulWidget {
  const SimpleCoachScreen({super.key});

  @override
  State<SimpleCoachScreen> createState() => _SimpleCoachScreenState();
}

class _SimpleCoachScreenState extends State<SimpleCoachScreen> {
  final List<String> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 코치'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // AI 코치 기능 소개
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                const Icon(Icons.psychology, size: 40, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 피트니스 코치',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('운동 계획, 폼 교정, 영양 조언을 받아보세요!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 채팅 영역
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final isUser = index % 2 == 0;
                      return _buildMessage(_messages[index], isUser);
                    },
                  ),
          ),
          
          // 로딩 표시
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          
          // 입력 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: _buildInputArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.psychology,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'AI 코치와 대화를 시작해보세요',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '운동 계획, 폼 교정, 영양 조언 등\n궁금한 것을 물어보세요!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestedQuestion('오늘 운동 계획 추천해줘'),
              _buildSuggestedQuestion('스쿼트 폼 체크 방법'),
              _buildSuggestedQuestion('다이어트 식단 조언'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestion(String question) {
    return ElevatedButton(
      onPressed: () => _sendMessage(question),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      child: Text(question),
    );
  }

  Widget _buildMessage(String message, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.psychology, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isUser 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'AI 코치에게 질문해보세요...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: null,
            onSubmitted: _canSend() ? (value) => _sendMessage(value) : null,
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          onPressed: _canSend() ? () => _sendMessage(_messageController.text) : null,
          backgroundColor: _canSend() 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300],
          child: Icon(
            Icons.send,
            color: _canSend() ? Colors.white : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  bool _canSend() {
    return _messageController.text.trim().isNotEmpty && !_isLoading;
  }

  void _sendMessage(String message) {
    if (!_canSend() && message.trim().isEmpty) return;

    setState(() {
      _messages.add(message);
      _messageController.clear();
      _isLoading = true;
    });

    // AI 응답 시뮬레이션
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(_generateAIResponse(message));
          _isLoading = false;
        });
      }
    });
  }

  String _generateAIResponse(String userMessage) {
    final responses = {
      '오늘 운동 계획': '오늘은 상체 운동을 추천합니다!\n\n1. 벤치프레스 3세트 8-10회\n2. 인클라인 덤벨프레스 3세트 10-12회\n3. 딥스 3세트 실패지점까지\n4. 오버헤드프레스 3세트 8-10회\n\n각 세트 간 90초 휴식을 추천합니다!',
      '스쿼트': '스쿼트 올바른 폼:\n\n1. 발을 어깨너비로 벌리세요\n2. 무릎이 발가락을 넘지 않도록 주의\n3. 엉덩이를 뒤로 빼면서 앉으세요\n4. 허벅지가 바닥과 평행할 때까지\n5. 발뒤꿈치로 밀어올리세요\n\n처음에는 가벼운 무게로 폼을 익히는 것이 중요해요!',
      '다이어트': '건강한 다이어트 식단 팁:\n\n🥗 탄수화물 40% / 단백질 30% / 지방 30%\n🍗 닭가슴살, 생선, 계란으로 단백질 섭취\n🥬 충분한 채소와 과일\n💧 하루 2-3L 물 섭취\n⏰ 규칙적인 식사 시간\n\n무리한 식단 제한보다는 균형 잡힌 식사가 중요해요!',
    };

    for (final key in responses.keys) {
      if (userMessage.toLowerCase().contains(key)) {
        return responses[key]!;
      }
    }

    return '좋은 질문이네요! 💪\n\n운동과 건강에 관한 더 구체적인 질문을 해주시면 더 정확한 조언을 드릴 수 있어요. 예를 들어:\n\n• "벤치프레스 무게 늘리는 방법"\n• "하체 운동 루틴 추천"\n• "운동 후 회복 방법"\n\n어떤 것이 궁금하신가요?';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}