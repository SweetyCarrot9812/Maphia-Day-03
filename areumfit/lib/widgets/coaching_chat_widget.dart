import 'package:flutter/material.dart';
import '../models/ai_analysis_models.dart';

/// AI 코칭 채팅 위젯
class CoachingChatWidget extends StatefulWidget {
  final CoachingSession session;
  final Function(String) onSendMessage;
  final Function(double) onEndSession;

  const CoachingChatWidget({
    super.key,
    required this.session,
    required this.onSendMessage,
    required this.onEndSession,
  });

  @override
  State<CoachingChatWidget> createState() => _CoachingChatWidgetState();
}

class _CoachingChatWidgetState extends State<CoachingChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 세션 헤더
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 코치',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getSessionTypeLabel(widget.session.type),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'end',
                    child: Row(
                      children: [
                        Icon(Icons.stop_circle, color: Colors.red),
                        SizedBox(width: 8),
                        Text('세션 종료'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'end') {
                    _showEndSessionDialog();
                  }
                },
              ),
            ],
          ),
        ),

        // 메시지 목록
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: widget.session.messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isTyping && index == widget.session.messages.length) {
                return _buildTypingIndicator();
              }
              
              final message = widget.session.messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),

        // 입력 영역
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
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
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _messageController.text.trim().isEmpty
                    ? null
                    : () => _sendMessage(_messageController.text),
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // 빠른 응답 버튼들
        if (_shouldShowQuickReplies())
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              children: _getQuickReplies()
                  .map((reply) => _buildQuickReplyChip(reply))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(CoachingMessage message) {
    final isUser = message.role == MessageRole.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 16,
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
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('코치가 응답 중...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => _sendMessage(text),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _isTyping = true;
    });

    widget.onSendMessage(text.trim());
    _messageController.clear();

    // 스크롤을 맨 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // 타이핑 인디케이터를 2초 후 제거 (실제로는 응답이 오면 제거)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  bool _shouldShowQuickReplies() {
    // 세션 시작 후 메시지가 적을 때만 표시
    return widget.session.messages.length <= 2;
  }

  List<String> _getQuickReplies() {
    switch (widget.session.type) {
      case CoachingType.planning_session:
        return ['오늘 목표는?', '추천 운동', '시간이 부족해요'];
      case CoachingType.post_workout_review:
        return ['정말 힘들었어요', '쉬웠어요', '폼이 궁금해요'];
      case CoachingType.motivation_boost:
        return ['동기부여 필요해요', '목표 재설정', '포기하고 싶어요'];
      default:
        return ['네', '아니요', '더 알고 싶어요'];
    }
  }

  String _getSessionTypeLabel(CoachingType type) {
    switch (type) {
      case CoachingType.real_time_feedback:
        return '실시간 피드백';
      case CoachingType.post_workout_review:
        return '운동 후 리뷰';
      case CoachingType.planning_session:
        return '계획 세션';
      case CoachingType.troubleshooting:
        return '문제 해결';
      case CoachingType.motivation_boost:
        return '동기부여';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return '방금';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('세션 종료'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('이 세션이 도움이 되었나요?'),
            const SizedBox(height: 16),
            const Text('만족도 (1-10)'),
            const SizedBox(height: 8),
            Slider(
              value: 8.0,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: '8',
              onChanged: (value) {
                // 슬라이더 값 업데이트
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onEndSession(8.0); // 실제로는 슬라이더 값 사용
            },
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }
}
