import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';

// ── Local model ──────────────────────────────
class _Achievement {
  final String code;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _Achievement({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// ── Static achievements list ─────────────────
const _allAchievements = [
  _Achievement(
    code: 'first_visit',
    title: 'الخطوة الأولى',
    description: 'زرت أول معلم تاريخي',
    icon: Icons.explore_rounded,
    color: Color(0xFF035F5B),
  ),
  _Achievement(
    code: 'five_visits',
    title: 'مستكشف',
    description: 'زرت 5 معالم تاريخية',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF755B00),
  ),
  _Achievement(
    code: 'ten_visits',
    title: 'خبير التراث',
    description: 'زرت 10 معالم تاريخية',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFC9A84C),
  ),
  _Achievement(
    code: 'first_save',
    title: 'المجمِّع',
    description: 'حفظت أول معلم',
    icon: Icons.bookmark_rounded,
    color: Color(0xFF2C7873),
  ),
  _Achievement(
    code: 'unesco_visit',
    title: 'تراث عالمي',
    description: 'زرت موقعاً مدرجاً في اليونسكو',
    icon: Icons.verified_rounded,
    color: Color(0xFF005F73),
  ),
  _Achievement(
    code: 'ai_chat',
    title: 'محادث الذكاء',
    description: 'تحدثت مع المرشد الذكي',
    icon: Icons.smart_toy_rounded,
    color: Color(0xFF5F533E),
  ),
  _Achievement(
    code: 'tour_360',
    title: 'مستكشف ثلاثي',
    description: 'أتممت جولة 360°',
    icon: Icons.vrpano_rounded,
    color: Color(0xFF4A3B00),
  ),
  _Achievement(
    code: 'share',
    title: 'ناشر التراث',
    description: 'شاركت معلماً مع الأصدقاء',
    icon: Icons.share_rounded,
    color: Color(0xFFBA1A1A),
  ),
];

// ── Provider ─────────────────────────────────
final _unlockedAchievementsProvider =
    FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return {};

  try {
    final rows = await Supabase.instance.client
        .from('achievements')
        .select('code')
        .eq('user_id', user.id);

    return rows.map<String>((r) => r['code'] as String).toSet();
  } catch (_) {
    return {};
  }
});

// ── Screen ───────────────────────────────────
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(_unlockedAchievementsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنجازاتي',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: unlockedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text('خطأ في التحميل',
                style: TextStyle(fontFamily: 'Cairo'))),
        data: (unlocked) {
          final unlockedCount = _allAchievements
              .where((a) => unlocked.contains(a.code))
              .length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: Colors.white, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$unlockedCount / ${_allAchievements.length} إنجازات',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: unlockedCount /
                                      _allAchievements.length,
                                  minHeight: 8,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final a = _allAchievements[i];
                      final isUnlocked = unlocked.contains(a.code);
                      return _AchievementCard(
                        achievement: a,
                        isUnlocked: isUnlocked,
                        index: i,
                      );
                    },
                    childCount: _allAchievements.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;
  final bool isUnlocked;
  final int index;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? achievement.color.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? achievement.color.withValues(alpha: 0.4)
              : colorScheme.outlineVariant,
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? achievement.color.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHigh,
            ),
            child: Icon(
              isUnlocked ? achievement.icon : Icons.lock_rounded,
              size: 28,
              color: isUnlocked
                  ? achievement.color
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isUnlocked
                  ? achievement.color
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUnlocked ? achievement.description : 'مقفل',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 350.ms)
        .scale(begin: const Offset(0.92, 0.92));
  }
}
