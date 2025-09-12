import 'package:flutter/material.dart';

/// 갤럭시 폴드를 포함한 반응형 디자인 유틸리티
class ResponsiveUtils {
  static const double foldableScreenWidth = 900.0; // 폴드 펼쳤을 때
  static const double compactScreenWidth = 400.0; // 폴드 접었을 때
  static const double tabletWidth = 1200.0; // 태블릿 크기

  /// 현재 화면이 폴드 펼친 상태인지 확인
  static bool isFoldableExpanded(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= foldableScreenWidth && width < tabletWidth;
  }

  /// 현재 화면이 폴드 접힌 상태인지 확인
  static bool isFoldableCompact(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < compactScreenWidth;
  }

  /// 태블릿 크기인지 확인
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletWidth;
  }

  /// 듀얼 패널 레이아웃 가능한지 확인
  static bool supportsDualPanel(BuildContext context) {
    return isFoldableExpanded(context) || isTablet(context);
  }

  /// 화면 크기에 따른 적응형 패딩
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0);
    } else if (isFoldableExpanded(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0);
    } else if (isFoldableCompact(context)) {
      return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0);
    }
    return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
  }

  /// 화면 크기에 따른 그리드 열 수
  static int getGridColumns(BuildContext context) {
    if (isTablet(context)) {
      return 4;
    } else if (isFoldableExpanded(context)) {
      return 3;
    } else if (isFoldableCompact(context)) {
      return 1;
    }
    return 2;
  }

  /// 화면 크기에 따른 카드 최대 너비
  static double getCardMaxWidth(BuildContext context) {
    if (isTablet(context)) {
      return 400.0;
    } else if (isFoldableExpanded(context)) {
      return 350.0;
    }
    return double.infinity;
  }

  /// 화면 크기에 따른 폰트 스케일
  static double getFontScale(BuildContext context) {
    if (isTablet(context)) {
      return 1.2;
    } else if (isFoldableExpanded(context)) {
      return 1.1;
    }
    return 1.0;
  }

  /// 안전 영역을 고려한 패딩
  static EdgeInsets getSafePadding(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    final adaptivePadding = getAdaptivePadding(context);
    
    return EdgeInsets.only(
      left: adaptivePadding.left + safePadding.left,
      top: adaptivePadding.top + safePadding.top,
      right: adaptivePadding.right + safePadding.right,
      bottom: adaptivePadding.bottom + safePadding.bottom,
    );
  }
}

/// 반응형 위젯 빌더
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    this.foldableCompact,
    this.foldableExpanded,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget? foldableCompact;
  final Widget? foldableExpanded;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isTablet(context)) {
      return tablet;
    } else if (ResponsiveUtils.isFoldableExpanded(context)) {
      return foldableExpanded ?? tablet;
    } else if (ResponsiveUtils.isFoldableCompact(context)) {
      return foldableCompact ?? mobile;
    }
    return mobile;
  }
}

/// 듀얼 패널 레이아웃 위젯
class DualPanelLayout extends StatelessWidget {
  const DualPanelLayout({
    super.key,
    required this.primaryPanel,
    required this.secondaryPanel,
    this.ratio = 0.6,
    this.direction = Axis.horizontal,
    this.dividerColor,
    this.dividerWidth = 1.0,
  });

  final Widget primaryPanel;
  final Widget secondaryPanel;
  final double ratio; // 첫 번째 패널의 비율 (0.0 ~ 1.0)
  final Axis direction;
  final Color? dividerColor;
  final double dividerWidth;

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveUtils.supportsDualPanel(context)) {
      // 단일 패널 모드에서는 primary 패널만 표시
      return primaryPanel;
    }

    final divider = Container(
      width: direction == Axis.horizontal ? dividerWidth : null,
      height: direction == Axis.vertical ? dividerWidth : null,
      color: dividerColor ?? Theme.of(context).dividerColor,
    );

    if (direction == Axis.horizontal) {
      return Row(
        children: [
          Expanded(
            flex: (ratio * 100).round(),
            child: primaryPanel,
          ),
          divider,
          Expanded(
            flex: ((1 - ratio) * 100).round(),
            child: secondaryPanel,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(
            flex: (ratio * 100).round(),
            child: primaryPanel,
          ),
          divider,
          Expanded(
            flex: ((1 - ratio) * 100).round(),
            child: secondaryPanel,
          ),
        ],
      );
    }
  }
}