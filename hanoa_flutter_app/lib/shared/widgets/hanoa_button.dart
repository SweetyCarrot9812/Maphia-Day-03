import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Hanoa 앱의 기본 버튼
class HanoaButton extends StatelessWidget {
  const HanoaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = HanoaButtonVariant.primary,
    this.size = HanoaButtonSize.large,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final HanoaButtonVariant variant;
  final HanoaButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(variant, size);
    final textStyle = _getTextStyle(variant, size);

    Widget buttonChild = isLoading
        ? _LoadingIndicator(variant: variant, size: size)
        : _ButtonContent(
            text: text,
            icon: icon,
            textStyle: textStyle,
          );

    final button = switch (variant) {
      HanoaButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      HanoaButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      HanoaButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
    };

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }

  ButtonStyle _getButtonStyle(HanoaButtonVariant variant, HanoaButtonSize size) {
    final height = _getButtonHeight(size);
    final padding = _getButtonPadding(size);

    return switch (variant) {
      HanoaButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textWhite,
          minimumSize: Size(0, height),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      HanoaButtonVariant.secondary => OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonPrimary,
          minimumSize: Size(0, height),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          side: const BorderSide(
            color: AppColors.buttonPrimary,
            width: 1.5,
          ),
        ),
      HanoaButtonVariant.text => TextButton.styleFrom(
          foregroundColor: AppColors.buttonPrimary,
          minimumSize: Size(0, height),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
        ),
    };
  }

  TextStyle _getTextStyle(HanoaButtonVariant variant, HanoaButtonSize size) {
    final baseStyle = switch (size) {
      HanoaButtonSize.small => AppTextStyles.buttonSmall,
      HanoaButtonSize.medium => AppTextStyles.buttonMedium,
      HanoaButtonSize.large => AppTextStyles.buttonLarge,
    };

    return switch (variant) {
      HanoaButtonVariant.primary => baseStyle.copyWith(
          color: AppColors.textWhite,
        ),
      HanoaButtonVariant.secondary => baseStyle.copyWith(
          color: AppColors.buttonPrimary,
        ),
      HanoaButtonVariant.text => baseStyle.copyWith(
          color: AppColors.buttonPrimary,
        ),
    };
  }

  double _getButtonHeight(HanoaButtonSize size) {
    return switch (size) {
      HanoaButtonSize.small => 40,
      HanoaButtonSize.medium => 48,
      HanoaButtonSize.large => 52,
    };
  }

  EdgeInsetsGeometry _getButtonPadding(HanoaButtonSize size) {
    return switch (size) {
      HanoaButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      HanoaButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      HanoaButtonSize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
  }
}

/// 버튼 내용
class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.text,
    required this.textStyle,
    this.icon,
  });

  final String text;
  final TextStyle textStyle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(text, style: textStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppConstants.spacingS),
        Text(text, style: textStyle),
      ],
    );
  }
}

/// 로딩 인디케이터
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({
    required this.variant,
    required this.size,
  });

  final HanoaButtonVariant variant;
  final HanoaButtonSize size;

  @override
  Widget build(BuildContext context) {
    final color = variant == HanoaButtonVariant.primary
        ? AppColors.textWhite
        : AppColors.buttonPrimary;

    final indicatorSize = switch (size) {
      HanoaButtonSize.small => 16.0,
      HanoaButtonSize.medium => 18.0,
      HanoaButtonSize.large => 20.0,
    };

    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// 버튼 변형
enum HanoaButtonVariant {
  primary,
  secondary,
  text,
}

/// 버튼 크기
enum HanoaButtonSize {
  small,
  medium,
  large,
}