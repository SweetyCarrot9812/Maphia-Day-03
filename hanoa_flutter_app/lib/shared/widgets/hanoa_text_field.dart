import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Hanoa 앱의 기본 텍스트 필드
class HanoaTextField extends StatefulWidget {
  const HanoaTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  @override
  State<HanoaTextField> createState() => _HanoaTextFieldState();
}

class _HanoaTextFieldState extends State<HanoaTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.label.copyWith(
              color: _isFocused ? AppColors.hanoaNavy : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
        ],

        // 텍스트 필드
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled
                ? (_isFocused ? AppColors.backgroundWhite : AppColors.surfaceLight)
                : AppColors.divider.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.hanoaNavy,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              borderSide: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingM,
            ),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            helperStyle: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
            counterStyle: AppTextStyles.caption.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ),
      ],
    );
  }
}

/// 특수 텍스트 필드들

/// 이메일 텍스트 필드
class HanoaEmailField extends StatelessWidget {
  const HanoaEmailField({
    super.key,
    this.controller,
    this.label = '이메일',
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return HanoaTextField(
      controller: controller,
      label: label,
      hint: 'example@hanoa.com',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validator ?? _defaultEmailValidator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }

  String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.validationEmailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppConstants.validationEmailInvalid;
    }
    return null;
  }
}

/// 비밀번호 텍스트 필드
class HanoaPasswordField extends StatefulWidget {
  const HanoaPasswordField({
    super.key,
    this.controller,
    this.label = '비밀번호',
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.isConfirmPassword = false,
    this.originalPassword,
  });

  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isConfirmPassword;
  final String? originalPassword;

  @override
  State<HanoaPasswordField> createState() => _HanoaPasswordFieldState();
}

class _HanoaPasswordFieldState extends State<HanoaPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return HanoaTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.isConfirmPassword ? '비밀번호를 다시 입력하세요' : '비밀번호를 입력하세요',
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.isConfirmPassword 
          ? TextInputAction.done 
          : TextInputAction.next,
      validator: widget.validator ?? _defaultPasswordValidator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      prefixIcon: const Icon(
        Icons.lock_outline,
        color: AppColors.textSecondary,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }

  String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.validationPasswordRequired;
    }
    
    if (widget.isConfirmPassword) {
      if (value != widget.originalPassword) {
        return AppConstants.validationPasswordConfirmMismatch;
      }
    } else {
      if (value.length < AppConstants.minPasswordLength) {
        return AppConstants.validationPasswordTooShort;
      }
    }
    
    return null;
  }
}

/// 이름 텍스트 필드
class HanoaNameField extends StatelessWidget {
  const HanoaNameField({
    super.key,
    this.controller,
    this.label = '이름',
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return HanoaTextField(
      controller: controller,
      label: label,
      hint: '이름을 입력하세요',
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      maxLength: AppConstants.maxNameLength,
      validator: validator ?? _defaultNameValidator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(
        Icons.person_outline,
        color: AppColors.textSecondary,
      ),
    );
  }

  String? _defaultNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.validationNameRequired;
    }
    if (value.length > AppConstants.maxNameLength) {
      return AppConstants.validationNameTooLong;
    }
    return null;
  }
}