import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'core/providers/common_providers.dart';

class AtheraApp extends ConsumerWidget {
  const AtheraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final isDark = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    // RTL for Arabic languages, LTR for others
    final isRTL = lang == 'ar' || lang == 'ar_dz';
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: MaterialApp.router(
        title: 'Athera 3D',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'AE'),
          Locale('en', 'US'),
          Locale('fr', 'FR'),
        ],
        locale: Locale(
          lang == 'ar_dz' ? 'ar' : lang,
          lang == 'ar_dz' ? 'DZ' : '',
        ),
        routerConfig: router,
      ),
    );
  }
}
