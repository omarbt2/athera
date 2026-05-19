import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/providers/common_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vrzfzwueemlkfewpbxjs.supabase.co',
    anonKey: 'sb_publishable_jPUDIp2So3NnI_0Fu9_CGw_9kKyUeay',
  );

  // Initialize SharedPreferences for theme/language settings
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AtheraApp(),
    ),
  );
}
