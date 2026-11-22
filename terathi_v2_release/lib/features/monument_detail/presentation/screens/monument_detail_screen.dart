import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/providers/common_providers.dart';
import '../../../../shared/providers/monuments_provider.dart';
import '../widgets/expandable_text.dart';
import '../widgets/similar_monument_card.dart';

class MonumentDetailScreen extends ConsumerWidget {
  final String monumentId;

  const MonumentDetailScreen({super.key, required this.monumentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monumentAsync = ref.watch(monumentDetailProvider(monumentId));
    final lang = ref.watch(languageProvider);
    final isSaved = ref.watch(isMonumentSavedProvider(monumentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: monumentAsync.when(
        data: (monument) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 420.0,
              pinned: true,
              floating: false,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              // Fix #17: _rounded icons
              leading: Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 12, right: 4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    // Fix #8: use primary color for saved state
                    icon: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      color: isSaved ? AppColors.primary : AppColors.textPrimary,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(savedMonumentsProvider.notifier).toggleSaved(monument);
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(bottom: 16, right: 64, left: 64),
                centerTitle: true,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCollapsed = constraints.maxHeight < kToolbarHeight + 40;
                    return isCollapsed
                        ? Text(
                            monument.name.get(lang),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Updated: multi-image carousel
                    ImageCarousel(images: monument.images),
                    // Fix #7: withValues instead of withOpacity
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4],
                          ),
                        ),
                      ),
                    ),
                    if (monument.isUNESCO)
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadius.pillRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'تراث عالمي يونسكو',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate().slideY(begin: 1.0, end: 0).fadeIn(),
                      ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monument.name.get(lang),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ).animate().fadeIn().slideX(begin: 0.1),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.textTertiary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${monument.wilaya}، الجزائر',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 24),

                    // Info chips — Fix #7, #9
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildInfoChip(context, '⭐', '${monument.rating.toStringAsFixed(1)} التقييم'),
                          const SizedBox(width: 10),
                          _buildInfoChip(context, '🕐', '2 ساعة'),
                          const SizedBox(width: 10),
                          _buildInfoChip(context, '🏛️', monument.historicalEra),
                          const SizedBox(width: 10),
                          _buildInfoChip(context, '👁️', '12K زيارة'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 28),

                    // Action Buttons — Fix #8: use AppColors.primary
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.push('/tour360/${monument.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ابدأ الجولة الافتراضية 360°',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.view_in_ar_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.push('/ai-chat/${monument.id}');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تحدث مع المرشد الذكي',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.smart_toy_rounded),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 28),

                    // About Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.settingsRadius,
                        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نبذة تاريخية',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ExpandableText(text: monument.description.get(lang)),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 20),

                    // Fix #3 + #6: Map section — remove API key, use proper map placeholder
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.settingsRadius,
                        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الموقع',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          // Fix #6: No broken NetworkImage with hardcoded key — use proper placeholder
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppRadius.chipRadius,
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.map_rounded, size: 56, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  monument.wilaya,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'الجزائر',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () => context.push('/map-view'),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('فتح في الخرائط'),
                              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

                    const SizedBox(height: 28),

                    // Similar Monuments
                    Text(
                      'معالم مشابهة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 200,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final allAsync = ref.watch(monumentsProvider);
                          return allAsync.when(
                            data: (all) {
                              final similar = all
                                  .where((m) => m.category == monument.category && m.id != monument.id)
                                  .toList();
                              if (similar.isEmpty) {
                                return const Center(child: Text('لا توجد معالم مشابهة'));
                              }
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: similar.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, index) => SimilarMonumentCard(
                                  monument: similar[index],
                                  onTap: () => context.push('/monument/${similar[index].id}'),
                                ),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.1),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('المعلم غير موجود'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.pop(), child: const Text('العودة')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.chipRadius,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  const ImageCarousel({super.key, required this.images});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        color: AppColors.surfaceContainerHigh,
        child: const Center(
          child: Icon(Icons.image_not_supported_rounded, size: 64, color: AppColors.textTertiary),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.images.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.images[index],
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceContainerHigh),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: const Center(
                  child: Icon(Icons.image_not_supported_rounded, size: 64, color: AppColors.textTertiary),
                ),
              ),
            );
          },
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
