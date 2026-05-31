import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColors — single source of truth for every color in the app
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const primary          = Color(0xFF1B5E20); // deep green
  static const primaryLight     = Color(0xFF4C8C4A);
  static const primaryDark      = Color(0xFF003300);

  static const secondary        = Color(0xFFFFA000); // amber
  static const secondaryLight   = Color(0xFFFFD149);
  static const secondaryDark    = Color(0xFFC67100);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const white            = Color(0xFFFFFFFF);
  static const black            = Color(0xFF000000);

  static const grey50           = Color(0xFFFAFAFA);
  static const grey100          = Color(0xFFF5F5F5);
  static const grey200          = Color(0xFFEEEEEE);
  static const grey300          = Color(0xFFE0E0E0);
  static const grey400          = Color(0xFFBDBDBD);
  static const grey500          = Color(0xFF9E9E9E);
  static const grey600          = Color(0xFF757575);
  static const grey700          = Color(0xFF616161);
  static const grey800          = Color(0xFF424242);
  static const grey900          = Color(0xFF212121);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const success          = Color(0xFF2E7D32);
  static const successLight     = Color(0xFFE8F5E9);
  static const warning          = Color(0xFFF57F17);
  static const warningLight     = Color(0xFFFFF8E1);
  static const error            = Color(0xFFC62828);
  static const errorLight       = Color(0xFFFFEBEE);
  static const info             = Color(0xFF0277BD);
  static const infoLight        = Color(0xFFE1F5FE);

  // ── Order status ───────────────────────────────────────────────────────────
  static const pending          = Color(0xFFF57F17);  // amber
  static const confirmed        = Color(0xFF1B5E20);  // green
  static const cancelled        = Color(0xFFC62828);  // red
  static const delivered        = Color(0xFF0277BD);  // blue

  // ── Light surface ──────────────────────────────────────────────────────────
  static const lightBackground  = Color(0xFFF9FBF9);
  static const lightSurface     = Color(0xFFFFFFFF);
  static const lightSurfaceVar  = Color(0xFFF1F8F1);

  // ── Dark surface ───────────────────────────────────────────────────────────
  static const darkBackground   = Color(0xFF0D1B0D);
  static const darkSurface      = Color(0xFF1A2E1A);
  static const darkSurfaceVar   = Color(0xFF243824);

  // ── Overlay / shadow ───────────────────────────────────────────────────────
  static const shadow           = Color(0x1A000000); // 10% black
  static const shadowDark       = Color(0x33000000); // 20% black
  static const overlay          = Color(0x80000000); // 50% black

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const gradient1 = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF4C8C4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradient2 = LinearGradient(
    colors: [Color(0xFFFFA000), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradient3 = LinearGradient(
    colors: [Color(0xFF7B1FA2), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Card shadow ─────────────────────────────────────────────────────────────
  static const cardShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  // ── Glass surface ───────────────────────────────────────────────────────────
  static const glassSurface = Color(0x14FFFFFF); // white at ~0.08 opacity
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextStyles — all text styles using Cairo (Arabic-compatible)
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppTextStyles {
  // ── Display ────────────────────────────────────────────────────────────────

  static TextStyle displayLarge({Color? color}) => GoogleFonts.cairo(
        fontSize: 57.sp, fontWeight: FontWeight.w400,
        letterSpacing: -0.25, color: color);

  static TextStyle displayMedium({Color? color}) => GoogleFonts.cairo(
        fontSize: 45.sp, fontWeight: FontWeight.w400, color: color);

  static TextStyle displaySmall({Color? color}) => GoogleFonts.cairo(
        fontSize: 36.sp, fontWeight: FontWeight.w400, color: color);

  // ── Headline ───────────────────────────────────────────────────────────────

  static TextStyle headlineLarge({Color? color}) => GoogleFonts.cairo(
        fontSize: 32.sp, fontWeight: FontWeight.w700, color: color);

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.cairo(
        fontSize: 28.sp, fontWeight: FontWeight.w700, color: color);

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.cairo(
        fontSize: 24.sp, fontWeight: FontWeight.w600, color: color);

  // ── Title ──────────────────────────────────────────────────────────────────

  static TextStyle titleLarge({Color? color}) => GoogleFonts.cairo(
        fontSize: 22.sp, fontWeight: FontWeight.w600, color: color);

  static TextStyle titleMedium({Color? color}) => GoogleFonts.cairo(
        fontSize: 16.sp, fontWeight: FontWeight.w600,
        letterSpacing: 0.15, color: color);

  static TextStyle titleSmall({Color? color}) => GoogleFonts.cairo(
        fontSize: 14.sp, fontWeight: FontWeight.w600,
        letterSpacing: 0.1, color: color);

  // ── Body ───────────────────────────────────────────────────────────────────

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.cairo(
        fontSize: 16.sp, fontWeight: FontWeight.w400,
        letterSpacing: 0.5, color: color);

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.cairo(
        fontSize: 14.sp, fontWeight: FontWeight.w400,
        letterSpacing: 0.25, color: color);

  static TextStyle bodySmall({Color? color}) => GoogleFonts.cairo(
        fontSize: 12.sp, fontWeight: FontWeight.w400,
        letterSpacing: 0.4, color: color);

  // ── Label ──────────────────────────────────────────────────────────────────

  static TextStyle labelLarge({Color? color}) => GoogleFonts.cairo(
        fontSize: 14.sp, fontWeight: FontWeight.w600,
        letterSpacing: 0.1, color: color);

  static TextStyle labelMedium({Color? color}) => GoogleFonts.cairo(
        fontSize: 12.sp, fontWeight: FontWeight.w500,
        letterSpacing: 0.5, color: color);

  static TextStyle labelSmall({Color? color}) => GoogleFonts.cairo(
        fontSize: 11.sp, fontWeight: FontWeight.w500,
        letterSpacing: 0.5, color: color);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — light and dark ThemeData
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppTheme {
  // ── Shared component shape ─────────────────────────────────────────────────

  static RoundedRectangleBorder _cardShape() => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      );

  static OutlinedBorder _buttonShape() => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      );

  // ── Light theme ────────────────────────────────────────────────────────────

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary:          AppColors.primary,
      onPrimary:        AppColors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.white,
      secondary:        AppColors.secondary,
      onSecondary:      AppColors.black,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.black,
      error:            AppColors.error,
      onError:          AppColors.white,
      surface:          AppColors.lightSurface,
      onSurface:        AppColors.grey900,
      surfaceContainerHighest: AppColors.lightSurfaceVar,
      outline:          AppColors.grey300,
      shadow:           AppColors.shadow,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,

      // ── Typography ─────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(AppColors.grey900),
      primaryTextTheme: _buildTextTheme(AppColors.white),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.grey900,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge(color: AppColors.grey900),
      ),

      // ── Navigation bar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.labelSmall(color: AppColors.grey700),
        ),
      ),

      // ── Cards ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: _cardShape(),
        margin: EdgeInsets.zero,
      ),

      // ── Inputs ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium(color: AppColors.grey500),
        labelStyle: AppTextStyles.bodyMedium(color: AppColors.grey700),
      ),

      // ── Elevated button ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: _buttonShape(),
          textStyle: AppTextStyles.labelLarge(),
        ),
      ),

      // ── Outlined button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: _buttonShape(),
          textStyle: AppTextStyles.labelLarge(),
        ),
      ),

      // ── Text button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge(),
        ),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.labelMedium(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 1,
      ),

      // ── Bottom sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titleTextStyle: AppTextStyles.titleLarge(color: AppColors.grey900),
        contentTextStyle: AppTextStyles.bodyMedium(color: AppColors.grey700),
      ),

      // ── Snackbar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey900,
        contentTextStyle: AppTextStyles.bodyMedium(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),

      // ── FloatingActionButton ───────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary:          AppColors.primaryLight,
      onPrimary:        AppColors.white,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.white,
      secondary:        AppColors.secondary,
      onSecondary:      AppColors.black,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.white,
      error:            Color(0xFFEF9A9A),
      onError:          AppColors.black,
      surface:          AppColors.darkSurface,
      onSurface:        AppColors.grey100,
      surfaceContainerHighest: AppColors.darkSurfaceVar,
      outline:          AppColors.grey700,
      shadow:           AppColors.shadowDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // ── Typography ─────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(AppColors.grey100),
      primaryTextTheme: _buildTextTheme(AppColors.white),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.grey100,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge(color: AppColors.grey100),
      ),

      // ── Navigation bar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.labelSmall(color: AppColors.grey400),
        ),
      ),

      // ── Cards ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: _cardShape(),
        margin: EdgeInsets.zero,
      ),

      // ── Inputs ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVar,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.grey700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFEF9A9A)),
        ),
        hintStyle: AppTextStyles.bodyMedium(color: AppColors.grey500),
        labelStyle: AppTextStyles.bodyMedium(color: AppColors.grey400),
      ),

      // ── Elevated button ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: _buttonShape(),
          textStyle: AppTextStyles.labelLarge(),
        ),
      ),

      // ── Outlined button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: _buttonShape(),
          textStyle: AppTextStyles.labelLarge(),
        ),
      ),

      // ── Text button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTextStyles.labelLarge(),
        ),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVar,
        selectedColor: AppColors.primaryLight.withValues(alpha: 0.25),
        labelStyle: AppTextStyles.labelMedium(color: AppColors.grey200),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.grey800,
        thickness: 1,
        space: 1,
      ),

      // ── Bottom sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titleTextStyle: AppTextStyles.titleLarge(color: AppColors.grey100),
        contentTextStyle: AppTextStyles.bodyMedium(color: AppColors.grey400),
      ),

      // ── Snackbar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey800,
        contentTextStyle: AppTextStyles.bodyMedium(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),

      // ── FloatingActionButton ───────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  // ── Shared text theme builder ───────────────────────────────────────────────

  static TextTheme _buildTextTheme(Color baseColor) => TextTheme(
        displayLarge:  AppTextStyles.displayLarge(color: baseColor),
        displayMedium: AppTextStyles.displayMedium(color: baseColor),
        displaySmall:  AppTextStyles.displaySmall(color: baseColor),
        headlineLarge: AppTextStyles.headlineLarge(color: baseColor),
        headlineMedium: AppTextStyles.headlineMedium(color: baseColor),
        headlineSmall: AppTextStyles.headlineSmall(color: baseColor),
        titleLarge:    AppTextStyles.titleLarge(color: baseColor),
        titleMedium:   AppTextStyles.titleMedium(color: baseColor),
        titleSmall:    AppTextStyles.titleSmall(color: baseColor),
        bodyLarge:     AppTextStyles.bodyLarge(color: baseColor),
        bodyMedium:    AppTextStyles.bodyMedium(color: baseColor),
        bodySmall:     AppTextStyles.bodySmall(color: baseColor),
        labelLarge:    AppTextStyles.labelLarge(color: baseColor),
        labelMedium:   AppTextStyles.labelMedium(color: baseColor),
        labelSmall:    AppTextStyles.labelSmall(color: baseColor),
      );
}
