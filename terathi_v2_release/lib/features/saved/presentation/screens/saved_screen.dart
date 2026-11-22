import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/providers/common_providers.dart';
import '../../../../shared/domain/entities/monument.dart';
import '../../../../shared/providers/monuments_provider.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    final savedMonuments = ref.watch(savedMonumentsProvider);
    // Fix #37: reversed list represents most recently saved first
    final sortedMonuments = savedMonuments.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'المحفوظات (${savedMonuments.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            // Fix #17: consistent _rounded icons
            icon: Icon(
              isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => isGridView = !isGridView);
            },
          ),
        ],
      ),
      body: sortedMonuments.isEmpty
          ? _buildEmptyState(context)
          : isGridView
              ? _buildGridView(sortedMonuments)
              : _buildListView(sortedMonuments),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded, size: 80, color: AppColors.primary),
            ).animate().scale(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              'لا توجد معالم محفوظة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            Text(
              'ابدأ باستكشاف المعالم وحفظها للعودة إليها لاحقاً.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/explore'),
              child: const Text('استكشف الآن', style: TextStyle(fontWeight: FontWeight.bold)),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  // Fix #11: dedicated grid card
  Widget _buildGridView(List<Monument> monuments) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: monuments.length,
      itemBuilder: (context, index) {
        final monument = monuments[index];
        return _MonumentGridCard(monument: monument)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 60 * index))
            .scale(begin: const Offset(0.95, 0.95));
      },
    );
  }

  Widget _buildListView(List<Monument> monuments) {
    final lang = ref.watch(languageProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: monuments.length,
      itemBuilder: (context, index) {
        final monument = monuments[index];
        return Dismissible(
          key: Key(monument.id),
          direction: DismissDirection.endToStart,
          // Fix #26: RTL-correct alignment — delete on trailing edge (right→left)
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: AppRadius.cardRadius,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete_rounded, color: Colors.white, size: 32),
          ),
          onDismissed: (_) {
            HapticFeedback.heavyImpact();
            ref.read(savedMonumentsProvider.notifier).toggleSaved(monument);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم الحذف من المحفوظات', style: TextStyle(fontFamily: 'Cairo')),
                action: SnackBarAction(
                  label: 'تراجع',
                  onPressed: () => ref.read(savedMonumentsProvider.notifier).toggleSaved(monument),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: GestureDetector(
            onTap: () => context.push('/monument/${monument.id}'),
            child: _HorizontalMonumentCard(monument: monument, lang: lang)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 60 * index))
                .slideX(begin: 0.1),
          ),
        );
      },
    );
  }
}

// Fix #11: Dedicated grid card (not abusing MonumentListCard in Grid)
class _MonumentGridCard extends ConsumerWidget {
  final Monument monument;
  const _MonumentGridCard({required this.monument});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/monument/${monument.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardRadius,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: CachedNetworkImage(
                imageUrl: monument.images.isNotEmpty ? monument.images.first : '',
                fit: BoxFit.cover,
                // Fix: reduce memory lag
                memCacheHeight: 400,
                // Fix #29
                placeholder: (_, __) => Container(color: AppColors.surfaceContainerHigh),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monument.name.get(lang),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 2),
                        Text(
                          monument.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalMonumentCard extends StatelessWidget {
  final Monument monument;
  final String lang;
  const _HorizontalMonumentCard({required this.monument, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.settingsRadius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 120,
            child: CachedNetworkImage(
              imageUrl: monument.images.isNotEmpty ? monument.images.first : '',
              fit: BoxFit.cover,
              // Fix: reduce memory lag
              memCacheHeight: 300,
              placeholder: (_, __) => Container(color: AppColors.surfaceContainerHigh),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: const Center(
                  child: Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monument.name.get(lang),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${monument.wilaya}، الجزائر',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        monument.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
