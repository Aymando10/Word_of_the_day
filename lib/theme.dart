// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/material.dart';

/// Forest-green palette shared by every screen.
abstract final class AppColors {
  static const background = Color(0xFF0A1913);
  static const backgroundDeep = Color(0xFF050F0B);
  static const surface = Color(0xFF10241C);
  static const surfaceRaised = Color(0xFF173126);
  static const outline = Color(0xFF254237);
  static const sage = Color(0xFF8DBF9E);
  static const gold = Color(0xFFD8BE85);
  static const cream = Color(0xFFF1EADB);
  static const muted = Color(0xFF9FB2A7);
  static const error = Color(0xFFE59A8C);
}

/// Serif face for headings and the word itself (built into iOS and macOS).
const String serifFamily = 'Georgia';
const List<String> serifFallback = ['Times New Roman', 'serif'];

const TextStyle serif = TextStyle(
  fontFamily: serifFamily,
  fontFamilyFallback: serifFallback,
);

/// Small uppercase label with generous tracking, used for eyebrows and tags.
TextStyle eyebrow(Color color) => TextStyle(
  color: color,
  fontSize: 11.5,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.8,
);

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.sage,
    onPrimary: AppColors.backgroundDeep,
    secondary: AppColors.gold,
    onSecondary: AppColors.backgroundDeep,
    surface: AppColors.surface,
    onSurface: AppColors.cream,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerHighest: AppColors.surfaceRaised,
    surfaceContainerHigh: AppColors.surfaceRaised,
    surfaceContainer: AppColors.surface,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
    error: AppColors.error,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.cream,
      displayColor: AppColors.cream,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.outline, space: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.backgroundDeep,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.sage.withValues(alpha: 0.18),
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.sage
              : AppColors.muted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppColors.cream
              : AppColors.muted,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.sage,
      checkmarkColor: AppColors.backgroundDeep,
      side: const BorderSide(color: AppColors.outline),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppColors.backgroundDeep
              : AppColors.cream,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.backgroundDeep
            : AppColors.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.sage
            : AppColors.surfaceRaised,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(AppColors.outline),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.sage
              : AppColors.surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.backgroundDeep
              : AppColors.cream,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.outline),
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.outline,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceRaised,
      contentTextStyle: TextStyle(color: AppColors.cream),
      behavior: SnackBarBehavior.floating,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: AppColors.surface,
      dialBackgroundColor: AppColors.surfaceRaised,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.sage,
    ),
  );
}

/// Full-bleed forest gradient behind each screen.
class ForestBackground extends StatelessWidget {
  const ForestBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF12291F), AppColors.background, AppColors.backgroundDeep],
          stops: [0, 0.45, 1],
        ),
      ),
      child: child,
    );
  }
}
