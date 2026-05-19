import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.cairoTextTheme().copyWith(
      displayLarge: GoogleFonts.cairo(fontSize: 57, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.cairo(fontSize: 45, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }

  static TextTheme get darkTextTheme {
    const darkColor = Color(0xFFFFEEE0);
    return GoogleFonts.cairoTextTheme().copyWith(
      displayLarge: GoogleFonts.cairo(fontSize: 57, fontWeight: FontWeight.bold, color: darkColor),
      displayMedium: GoogleFonts.cairo(fontSize: 45, fontWeight: FontWeight.bold, color: darkColor),
      displaySmall: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.bold, color: darkColor),
      headlineLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700, color: darkColor),
      headlineMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w600, color: darkColor),
      headlineSmall: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w600, color: darkColor),
      titleLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600, color: darkColor),
      titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: darkColor),
      titleSmall: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: darkColor),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, color: darkColor),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: darkColor),
      bodySmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFFB0A898)),
      labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: darkColor),
      labelMedium: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500, color: darkColor),
      labelSmall: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFB0A898)),
    );
  }
}
