import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/monuments_provider.dart';
import '../../../../shared/domain/entities/monument.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final _exploreQueryProvider = StateProvider<String>((ref) => '');
final _exploreCategoryProvider =
    StateProvider<MonumentCategory?>((ref) => null);
final _exploreRegionProvider = StateProvider<Region?>((ref) => null);
final _exploreViewModeProvider = StateProvider<_ViewMode>((ref) => _ViewMode.list);
final _exploreUnescoOnlyProvider = StateProvider<bool>((ref) => false);

enum _ViewMode { list, grid }

// ── Screen ─────────────────────────────────────────────────────────────────

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showShadow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 4;
      if (show != _showShadow) setState(() => _showShadow = show);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monumentsAsync = ref.watch(monumentsProvider);
    final query = ref.watch(_exploreQueryProvider);
    final category = ref.watch(_exploreCategoryProvider);
    final region = ref.watch(_exploreRegionProvider);
    final unescoOnly = ref.watch(_exploreUnescoOnlyProvider);
    final viewMode = ref.watch(_exploreViewModeProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: monumentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
          data: (allMonuments) {
            final filtered = allMonuments.where((m) {
              if (query.isNotEmpty) {
                final q = query.toLowerCase();
                if (!m.name.ar.toLowerCase().contains(q) &&
                    !m.wilaya.toLowerCase().contains(q)) {
                  return false;
                }
              }
              if (category != null && m.category != category) return false;
              if (region != null && m.region != region) return false;
              if (unescoOnly && !m.isUNESCO) return false;
              return true;
            }).toList();

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
            _SliverExploreHeader(
              showShadow: _showShadow,
              searchController: _searchController,
              onSearch: (v) =>
                  ref.read(_exploreQueryProvider.notifier).state = v,
              viewMode: viewMode,
              onToggleView: () {
                HapticFeedback.lightImpact();
                ref.read(_exploreViewModeProvider.notifier).state =
                    viewMode == _ViewMode.list
                        ? _ViewMode.grid
                        : _ViewMode.list;
              },
              resultCount: filtered.length,
            ),

            // ── Filter chips ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FilterChipsRow(
                selectedCategory: category,
                selectedRegion: region,
                unescoOnly: unescoOnly,
                onCategoryChanged: (c) {
                  HapticFeedback.lightImpact();
                  ref.read(_exploreCategoryProvider.notifier).state = c;
                },
                onUnescoToggle: () {
                  HapticFeedback.lightImpact();
                  ref.read(_exploreUnescoOnlyProvider.notifier).state =
                      !unescoOnly;
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Empty state ───────────────────────────────────────────────
            if (filtered.isEmpty)
              const SliverFillRemaining(child: _EmptyState()),

            // ── Grid / List ───────────────────────────────────────────────
            if (filtered.isNotEmpty && viewMode == _ViewMode.grid)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ExploreGridCard(
                      monument: filtered[i],
                      index: i,
                    ),
                    childCount: filtered.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.80,
                  ),
                ),
              ),

            if (filtered.isNotEmpty && viewMode == _ViewMode.list)
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExploreListCard(
                        monument: filtered[i],
                        index: i,
                      ),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        );
          },
        ),
      ),
    );
  }
}

// ── Sliver Header ───────────────────────────────────────────────────────────

class _SliverExploreHeader extends StatelessWidget {
  final bool showShadow;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final _ViewMode viewMode;
  final VoidCallback onToggleView;
  final int resultCount;

  const _SliverExploreHeader({
    required this.showShadow,
    required this.searchController,
    required this.onSearch,
    required this.viewMode,
    required this.onToggleView,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: scaffoldBg,
      surfaceTintColor: Colors.transparent,
      elevation: showShadow ? 2 : 0,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
      expandedHeight: 150,
      collapsedHeight: 60,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 56, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'اكتشف',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                    ),
                    // View toggle
                    _IconBtn(
                      icon: viewMode == _ViewMode.list
                          ? Icons.grid_view_rounded
                          : Icons.view_list_rounded,
                      onTap: onToggleView,
                    ),
                    const SizedBox(width: 8),
                    // Filter button
                    _IconBtn(
                      icon: Icons.tune_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$resultCount معلم',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          color: scaffoldBg,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _SearchBar(
            controller: searchController,
            onChanged: onSearch,
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'ابحث عن معالم، مدن، أو عصور...',
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

// ── Filter Chips Row ────────────────────────────────────────────────────────

class _FilterChipsRow extends StatelessWidget {
  final MonumentCategory? selectedCategory;
  final Region? selectedRegion;
  final bool unescoOnly;
  final ValueChanged<MonumentCategory?> onCategoryChanged;
  final VoidCallback onUnescoToggle;

  const _FilterChipsRow({
    required this.selectedCategory,
    required this.selectedRegion,
    required this.unescoOnly,
    required this.onCategoryChanged,
    required this.onUnescoToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All
          _FilterChip(
            label: 'الكل',
            icon: Icons.apps_rounded,
            selected: selectedCategory == null && !unescoOnly,
            color: AppColors.primary,
            onTap: () => onCategoryChanged(null),
          ),
          const SizedBox(width: 8),
          // UNESCO
          _FilterChip(
            label: 'يونسكو',
            icon: Icons.verified_rounded,
            selected: unescoOnly,
            color: const Color(0xFFB5860D),
            onTap: onUnescoToggle,
          ),
          const SizedBox(width: 8),
          // Archaeological
          _FilterChip(
            label: 'أثرية',
            icon: Icons.account_balance_rounded,
            selected: selectedCategory == MonumentCategory.archaeological,
            color: AppColors.catArchaeological,
            onTap: () => onCategoryChanged(
              selectedCategory == MonumentCategory.archaeological
                  ? null
                  : MonumentCategory.archaeological,
            ),
          ),
          const SizedBox(width: 8),
          // Islamic
          _FilterChip(
            label: 'إسلامية',
            icon: Icons.mosque_rounded,
            selected: selectedCategory == MonumentCategory.islamic,
            color: AppColors.catIslamic,
            onTap: () => onCategoryChanged(
              selectedCategory == MonumentCategory.islamic
                  ? null
                  : MonumentCategory.islamic,
            ),
          ),
          const SizedBox(width: 8),
          // Natural
          _FilterChip(
            label: 'طبيعية',
            icon: Icons.landscape_rounded,
            selected: selectedCategory == MonumentCategory.natural,
            color: AppColors.catNatural,
            onTap: () => onCategoryChanged(
              selectedCategory == MonumentCategory.natural
                  ? null
                  : MonumentCategory.natural,
            ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'متاحف',
            icon: Icons.museum_rounded,
            selected: selectedCategory == MonumentCategory.museum,
            color: AppColors.catMuseums,
            onTap: () => onCategoryChanged(
              selectedCategory == MonumentCategory.museum
                  ? null
                  : MonumentCategory.museum,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: selected ? color : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List Card ───────────────────────────────────────────────────────────────

class _ExploreListCard extends StatelessWidget {
  final Monument monument;
  final int index;
  const _ExploreListCard({required this.monument, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/monument/${monument.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: monument.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: monument.images.first,
                        fit: BoxFit.cover,
                        // Fix: reduce memory lag
                        memCacheHeight: 300,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(Icons.image_not_supported_rounded,
                              color: AppColors.textTertiary),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.account_balance_rounded,
                            color: AppColors.textTertiary),
                      ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // UNESCO badge
                    if (monument.isUNESCO) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.unescoGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                size: 11, color: AppColors.unescoGold),
                            SizedBox(width: 3),
                            Text(
                              'يونسكو',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.unescoGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Name
                    Text(
                      monument.name.ar,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Text(
                          monument.wilaya,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Rating + Category
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFFB400)),
                        const SizedBox(width: 2),
                        Text(
                          monument.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        _CategoryBadge(category: monument.category),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: index * 50))
          .fadeIn(duration: 350.ms)
          .slideX(begin: 0.08, end: 0, duration: 350.ms),
    );
  }
}

// ── Grid Card ───────────────────────────────────────────────────────────────

class _ExploreGridCard extends StatelessWidget {
  final Monument monument;
  final int index;
  const _ExploreGridCard({required this.monument, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/monument/${monument.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    monument.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: monument.images.first,
                            fit: BoxFit.cover,
                            // Fix: reduce memory lag
                            memCacheHeight: 400,
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceContainerHigh,
                            ),
                          )
                        : Container(color: AppColors.surfaceContainerHigh),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // UNESCO badge top
                    if (monument.isUNESCO)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  size: 10, color: Color(0xFFFFD700)),
                              SizedBox(width: 2),
                              Text(
                                'UNESCO',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monument.name.ar,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          monument.wilaya,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.star_rounded,
                          size: 11, color: Color(0xFFFFB400)),
                      const SizedBox(width: 2),
                      Text(
                        monument.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: index * 40))
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.94, 0.94), end: const Offset(1, 1)),
    );
  }
}

// ── Category Badge ──────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final MonumentCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (category) {
      MonumentCategory.archaeological => ('أثرية', AppColors.catArchaeological),
      MonumentCategory.islamic => ('إسلامية', AppColors.catIslamic),
      MonumentCategory.natural => ('طبيعية', AppColors.catNatural),
      MonumentCategory.museum => ('متاحف', AppColors.catMuseums),
      _ => ('أخرى', AppColors.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'جرّب تعديل الفلتر أو البحث بكلمة أخرى',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
