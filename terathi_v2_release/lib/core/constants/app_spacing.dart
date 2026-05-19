import 'package:flutter/material.dart';

class AppSpacing {
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;

  // Vertical Spacing
  static const SizedBox vertical8 = SizedBox(height: s8);
  static const SizedBox vertical16 = SizedBox(height: s16);
  static const SizedBox vertical24 = SizedBox(height: s24);
  static const SizedBox vertical32 = SizedBox(height: s32);
  static const SizedBox vertical40 = SizedBox(height: s40);
  static const SizedBox vertical48 = SizedBox(height: s48);

  // Horizontal Spacing
  static const SizedBox horizontal4 = SizedBox(width: s4);
  static const SizedBox horizontal8 = SizedBox(width: s8);
  static const SizedBox horizontal12 = SizedBox(width: s12);
  static const SizedBox horizontal16 = SizedBox(width: s16);
  static const SizedBox horizontal24 = SizedBox(width: s24);
}
