import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isEnabled;
  final String? hintText;
  final String? Function(String?)? validator;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    this.isEnabled = true,
    this.hintText,
    this.validator,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _hasText = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
        _errorText = null; // 입력 시 에러 메시지 제거
      });
    }
  }

  void _handleSend() {
    if (!widget.isEnabled) return;

    final text = widget.controller.text.trim();
    if (text.isEmpty) return;

    // 유효성 검사
    if (widget.validator != null) {
      final error = widget.validator!(text);
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
    }

    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 44,
                      maxHeight: 120,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _errorText != null 
                            ? AppColors.error 
                            : AppColors.divider,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      enabled: widget.isEnabled,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? '메시지를 입력하세요...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingM,
                          vertical: AppConstants.spacingS + 2,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingS),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: _hasText && widget.isEnabled
                        ? AppColors.hanoaNavy
                        : AppColors.textLight,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      onTap: _hasText && widget.isEnabled ? _handleSend : null,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.send,
                          color: _hasText && widget.isEnabled
                              ? AppColors.textWhite
                              : AppColors.backgroundWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}