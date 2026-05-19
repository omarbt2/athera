import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';

// ── Model ────────────────────────────────────
class _VisitEntry {
  final String monumentId;
  final String monumentName;
  final String wilaya;
  final DateTime visitedAt;

  const _VisitEntry({
    required this.monumentId,
    required this.monumentName,
    required this.wilaya,
    required this.visitedAt,
  });
}

// ── Provider ─────────────────────────────────
final _visitHistoryProvider = FutureProvider<List<_VisitEntry>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];

  try {
    final rows = await Supabase.instance.client
        .from('visit_history')
        .select('visited_at, monuments(name, wilaya)')
        .eq('user_id', user.id)
        .order('visited_at', ascending: false)
        .limit(50);

    return rows.map<_VisitEntry>((row) {
      final monument = row['monuments'] as Map<String, dynamic>?;
      return _VisitEntry(
        monumentId: row['id'] as String? ?? '',
        monumentName: monument?['name'] as String? ?? 'معلم غير معروف',
        wilaya: monument?['wilaya'] as String? ?? '',
        visitedAt: DateTime.tryParse(row['visited_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  } catch (_) {
    return [];
  }
});

// ── Screen ───────────────────────────────────
class TourHistoryScreen extends ConsumerWidget {
  const TourHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(_visitHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('رحلة الاستكشاف',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: visitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text('خطأ في التحميل',
                style: TextStyle(fontFamily: 'Cairo'))),
        data: (visits) {
          if (visits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore_off_rounded,
                        size: 80,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    const Text(
                      'لم تزر أي معلم بعد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ رحلتك الاستكشافية واكتشف\nالتراث الجزائري الغني',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/explore'),
                      icon: const Icon(Icons.explore_rounded),
                      label: const Text('استكشف الآن',
                          style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: visits.length,
            itemBuilder: (context, i) {
              final v = visits[i];
              final dateStr =
                  DateFormat('d MMM yyyy، h:mm a', 'ar').format(v.visitedAt);

              return _VisitCard(visit: v, dateStr: dateStr, index: i);
            },
          );
        },
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final _VisitEntry visit;
  final String dateStr;
  final int index;

  const _VisitCard({
    required this.visit,
    required this.dateStr,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_rounded,
                color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.monumentName,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (visit.wilaya.isNotEmpty) ...[
                      Icon(Icons.location_on_rounded,
                          size: 12,
                          color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text(
                        visit.wilaya,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.access_time_rounded,
                        size: 12,
                        color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.06, end: 0);
  }
}
