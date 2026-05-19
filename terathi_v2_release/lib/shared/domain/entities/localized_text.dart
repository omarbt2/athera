class LocalizedText {
  final String ar;
  final String arDz;
  final String fr;
  final String en;

  const LocalizedText({
    required this.ar,
    required this.arDz,
    required this.fr,
    required this.en,
  });

  /// Returns the appropriate text based on the current language code.
  /// Defaults to Arabic ('ar') if not found.
  String get(String languageCode) {
    switch (languageCode) {
      case 'ar_dz':
        return arDz;
      case 'fr':
        return fr;
      case 'en':
        return en;
      case 'ar':
      default:
        return ar;
    }
  }

  // Pure domain entities don't typically have JSON parsing logic directly,
  // but to keep it simple or to prepare for the Data Layer:
  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ar: json['ar'] as String? ?? '',
      arDz: json['ar_dz'] as String? ?? json['ar'] as String? ?? '',
      fr: json['fr'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'ar': ar,
        'ar_dz': arDz,
        'fr': fr,
        'en': en,
      };
}
