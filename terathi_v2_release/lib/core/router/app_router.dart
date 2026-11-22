import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/saved/presentation/screens/saved_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/achievements_screen.dart';
import '../../features/profile/presentation/screens/tour_history_screen.dart';
import '../../features/monument_detail/presentation/screens/monument_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/tour_360/presentation/screens/tour_360_screen.dart';
import '../../shared/widgets/athera_bottom_nav.dart';
import '../../shared/widgets/feature_placeholder_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier();

  ref.listen(authProvider, (_, __) => notifier.refresh());
  ref.listen(onboardingProvider, (_, __) => notifier.refresh());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final isOnboarding = loc == '/onboarding';
      final isAuthRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/forgot-password';

      final onboardingState = ref.read(onboardingProvider);
      final authState = ref.read(authProvider);

      if (onboardingState.isLoading) return isSplash ? null : '/splash';

      if (!onboardingState.isCompleted) {
        return isOnboarding ? null : '/onboarding';
      }

      final isAuthenticated = authState is AuthAuthenticated;

      if (!isAuthenticated && !isAuthRoute) return '/login';

      if (isAuthenticated && (isAuthRoute || isOnboarding || isSplash)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

      GoRoute(
        path: '/monument/:id',
        builder: (_, state) =>
            MonumentDetailScreen(monumentId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),

      // ── Achievements & History ────────────────
      GoRoute(path: '/achievements', builder: (_, __) => const AchievementsScreen()),
      GoRoute(path: '/tour-history', builder: (_, __) => const TourHistoryScreen()),

      // ── Coming Soon screens ───────────────────
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const FeaturePlaceholderScreen(
            title: 'سياسة الخصوصية', icon: Icons.privacy_tip_rounded),
      ),
      GoRoute(
        path: '/terms',
        builder: (_, __) => const FeaturePlaceholderScreen(
            title: 'الشروط والأحكام', icon: Icons.description_rounded),
      ),
      GoRoute(
        path: '/help',
        builder: (_, __) => const FeaturePlaceholderScreen(
            title: 'المساعدة', icon: Icons.help_rounded),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const FeaturePlaceholderScreen(
            title: 'الإشعارات', icon: Icons.notifications_rounded),
      ),
      GoRoute(
        path: '/map-view',
        builder: (_, __) => const FeaturePlaceholderScreen(
            title: 'الخريطة', icon: Icons.map_rounded),
      ),
      GoRoute(
        path: '/search-results',
        builder: (_, __) => const FeaturePlaceholderScreen(
            title: 'نتائج البحث', icon: Icons.search_rounded),
      ),

      // ── Bottom Nav Shell ─────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AtheraBottomNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
              routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(
              routes: [GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen())]),
          StatefulShellBranch(
              routes: [GoRoute(path: '/saved', builder: (_, __) => const SavedScreen())]),
          StatefulShellBranch(
              routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())]),
        ],
      ),

      // ── Feature screens ──────────────────────
      GoRoute(
        path: '/tour360/:id',
        builder: (_, state) =>
            Tour360Screen(monumentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ai-chat/:id',
        builder: (_, state) =>
            AiChatScreen(monumentId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/premium', builder: (_, __) => const FeaturePlaceholderScreen(
          title: 'اشتراكي', icon: Icons.star_rounded)),
    ],
  );
});

class AppRouter {
  static GoRouter router(WidgetRef ref) => ref.watch(routerProvider);
}
