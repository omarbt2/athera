import 'package:flutter/material.dart';

/// Unified border-radius system — eliminates the 6 inconsistent values.
class AppRadius {
  /// Cards: HeroCard, ListCard, GridCard
  static const double card = 28;
  /// Buttons, Inputs
  static const double button = 16;
  /// Settings & info cards
  static const double settingsCard = 20;
  /// Category chips, info chips
  static const double chip = 12;
  /// Rating badge
  static const double badge = 8;
  /// Bottom sheets
  static const double bottomSheet = 24;
  /// Pills: Nav, UNESCO badge
  static const double pill = 999;

  // BorderRadius helpers
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get buttonRadius => BorderRadius.circular(button);
  static BorderRadius get settingsRadius => BorderRadius.circular(settingsCard);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
  static BorderRadius get badgeRadius => BorderRadius.circular(badge);
  static BorderRadius get bottomSheetRadius => const BorderRadius.vertical(top: Radius.circular(bottomSheet));
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}
