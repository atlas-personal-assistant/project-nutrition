import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design Tokens - Apple Health × Premium Lifestyle
/// 
/// Diese Tokens bilden die Basis für das Default-Theme.
/// Später können weitere Themes (Minimal, Premium, Health) hinzugefügt werden,
/// ohne die UI-Struktur zu verändern.

class AppColors {
  // Primary Palette - Premium Health (Dunkelblau/Teal)
  static const primary = Color(0xFF1A5F7A);
  static const primaryDark = Color(0xFF0D3D4D);
  static const primaryLight = Color(0xFF4A8FA5);
  static const onPrimary = Color(0xFFFFFFFF);
  
  // Secondary Palette
  static const secondary = Color(0xFF2E8B8B);
  static const secondaryLight = Color(0xFF5ABFBF);
  static const onSecondary = Color(0xFFFFFFFF);
  
  // Background
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0F4F7);
  static const onBackground = Color(0xFF1A1A1A);
  static const onSurface = Color(0xFF1A1A1A);
  static const onSurfaceVariant = Color(0xFF6B7B8C);
  
  // Functional Colors
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF57C00);
  static const error = Color(0xFFC62828);
  static const info = Color(0xFF1565C0);
  
  // Neutral
  static const outline = Color(0xFFD1D9E0);
  static const outlineVariant = Color(0xFFE2E8EC);
  static const disabled = Color(0xFFB0BEC5);
  static const shadow = Color(0x1F000000);
  
  // Health-specific
  static const calories = Color(0xFFE53935);
  static const protein = Color(0xFF1E88E5);
  static const carbs = Color(0xFFFDD835);
  static const fat = Color(0xFFFB8C00);
}

class AppSpacing {
  static const space2 = 2.0;
  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space48 = 48.0;
}

class AppBorderRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const extraLarge = 24.0;
  static const full = 100.0;
}

class AppShadows {
  static const card = BoxShadow(
    color: Color(0x0D000000),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );
  
  static const elevated = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 16,
    spreadRadius: 0,
  );
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.onBackground,
  );
  
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.onBackground,
  );
  
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.onBackground,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.onBackground,
  );
  
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onBackground,
  );
  
  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.onBackground,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.onSurface,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.onSurface,
  );
  
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );
  
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.error.withOpacity(0.1),
        onErrorContainer: AppColors.error,
        surfaceTint: Colors.transparent,
        shadow: AppColors.shadow,
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.headlineMedium,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space16,
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space8,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: AppSpacing.space16,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}
