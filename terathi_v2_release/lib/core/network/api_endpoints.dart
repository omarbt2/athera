class ApiEndpoints {
  static const String baseUrl = 'https://api.Athera3d.dz/api';

  // Monuments
  static const String monuments = '/monuments';
  static const String featuredMonument = '/monuments/featured';
  static const String searchMonuments = '/monuments/search';
  
  // Users & Auth
  static const String register = '/auth/register';
  static const String userProfile = '/users/me';
  static const String userStats = '/users/me/stats';

  // Saved
  static const String savedMonuments = '/saved';

  // Tours
  static const String startTour = '/tours/start';
  static const String tourHistory = '/tours/history';

  // AI
  static const String aiChat = '/ai/chat';
  static const String aiNarration = '/ai/narration';

  // Premium
  static const String premiumStatus = '/premium/status';
  static const String premiumActivate = '/premium/activate';
}
