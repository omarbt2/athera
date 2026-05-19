import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/monuments_provider.dart';

class Tour360Screen extends ConsumerWidget {
  final String monumentId;

  const Tour360Screen({super.key, required this.monumentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monumentAsync = ref.watch(monumentDetailProvider(monumentId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: monumentAsync.when(
          data: (m) => Text('جولة 360° - ${m.name.ar}'),
          loading: () => const Text('جاري التحميل...'),
          error: (_, __) => const Text('جولة افتراضية'),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: monumentAsync.when(
          data: (m) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.threesixty, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                'بدء الجولة الافتراضية لـ ${m.name.ar}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('خطأ: $e', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
