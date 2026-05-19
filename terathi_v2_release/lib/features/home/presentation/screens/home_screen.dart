import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../../shared/providers/monuments_provider.dart';
import '../../../../shared/domain/entities/monument.dart';
import '../widgets/hero_monument_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/monument_list_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final featuredAsync = ref.watch(featuredMonumentProvider);
    final allMonumentsAsync = ref.watch(monumentsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Derive displayed monuments based on search + category filter
    final displayedMonumentsAsync = searchQuery.isNotEmpty || selectedCategory != null
        ? ref.watch(monumentsProvider).whenData((monuments) => monuments.where((m) {
            bool matches = true;
            if (selectedCategory != null) {
              matches = matches && m.category.name == selectedCategory;
            }
            if (searchQuery.isNotEmpty) {
              final q = searchQuery.toLowerCase();
              matches = matches &&
                  (m.name.ar.toLowerCase().contains(q) ||
                      m.name.en.toLowerCase().contains(q) ||
                      m.name.fr.toLowerCase().contains(q));
            }
            return matches;
          }).toList())
        : allMonumentsAsync;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Glassmorphism SliverAppBar ─────────
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.85),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  'Athera 3D',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_rounded),
                  color: AppColors.textPrimary,
                  onPressed: () => context.push('/notifications'),
                ),
              ],
            ),
          ),

          // ── All content in SliverList — Fix #40: no nested ListView ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Greeting ───────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}، ${user?.name ?? 'زائر'} 👋',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    allMonumentsAsync.when(
                      data: (monuments) {
                        final unescoCount = monuments.where((m) => m.isUNESCO).length;
                        return Text(
                          '${monuments.length} معلماً • $unescoCount مواقع يونسكو',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),

                const SizedBox(height: 24),

                // ── Fix #23: Working SearchBar ─────────────────
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) context.push('/search-results');
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن معالم، مدن، عصور...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 28),

                // ── Hero Card ──────────────────
                featuredAsync.when(
                  data: (monument) => HeroMonumentCard(monument: monument),
                  loading: () => _ShimmerPlaceholder(height: 480, radius: 28),
                  error: (e, st) => const Center(child: Text('خطأ في التحميل')),
                ).animate().fadeIn(delay: 150.ms, duration: 500.ms).scale(
                  begin: const Offset(0.96, 0.96),
                ),

                const SizedBox(height: 32),

                // ── Fix #19: Categories with selection state ───
                const CategoryChips()
                    .animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 32),

                // ── Fix #24: Section Title with working عرض الكل ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory != null || searchQuery.isNotEmpty
                          ? 'نتائج البحث'
                          : 'الأكثر زيارة',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/explore'),
                      child: const Text(
                        'عرض الكل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 12),
              ]),
            ),
          ),

          // ── Monument List as proper Sliver — Fix #40 ──
          displayedMonumentsAsync.when(
            data: (monuments) {
              if (monuments.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textTertiary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList.separated(
                  itemCount: monuments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return MonumentListCard(monument: monuments[index])
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 350 + (index * 80)),
                          duration: 400.ms,
                        )
                        .slideY(begin: 0.08, end: 0);
                  },
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ShimmerPlaceholder(height: 280, radius: 28),
                  )),
                ),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء النور';
  }
}

// Fix #13: Shimmer-style placeholder widget
class _ShimmerPlaceholder extends StatefulWidget {
  final double height;
  final double radius;
  const _ShimmerPlaceholder({required this.height, required this.radius});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceContainerHigh,
                AppColors.surfaceContainerHighest,
                AppColors.surfaceContainerHigh,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
