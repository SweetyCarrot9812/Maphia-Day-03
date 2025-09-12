import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../models/onboarding_models.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onQuickReplyTap;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onQuickReplyTap,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.message.isFromBot ? const Offset(-0.3, 0) : const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
          child: Column(
            crossAxisAlignment: widget.message.isFromBot
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              _buildMessageBubble(),
              if (widget.message.quickReplies != null &&
                  widget.message.quickReplies!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacingS),
                _buildQuickReplies(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    final isBot = widget.message.isFromBot;
    
    return Row(
      mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isBot) ...[
          _buildBotAvatar(),
          const SizedBox(width: AppConstants.spacingS),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isBot ? AppColors.surfaceLight : AppColors.hanoaNavy,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isBot ? 4 : 16),
                bottomRight: Radius.circular(isBot ? 16 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Text(
              widget.message.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isBot ? AppColors.textPrimary : AppColors.textWhite,
                height: 1.4,
              ),
            ),
          ),
        ),
        if (!isBot) ...[
          const SizedBox(width: AppConstants.spacingS),
          _buildUserAvatar(),
        ],
      ],
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.smart_toy,
        color: AppColors.textWhite,
        size: 20,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.hanoaGold,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.textWhite,
        size: 20,
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Wrap(
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingS,
      children: widget.message.quickReplies!.map((reply) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onQuickReplyTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.hanoaNavy,
                  width: 1,
                ),
              ),
              child: Text(
                reply,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.hanoaNavy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}