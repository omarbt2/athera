import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../shared/domain/entities/monument.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/common_providers.dart';

class HeroMonumentCard extends ConsumerWidget {
  final Monument monument;

  const HeroMonumentCard({super.key, required this.monument});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Container(
      height: 480,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardRadius,
        color: AppColors.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Fix #14: Proper image error handling
          Positioned.fill(
            child: monument.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: monument.images.first,
                    fit: BoxFit.cover,
                    // Fix: added memCacheHeight to reduce memory lag
                    memCacheHeight: 800,
                    // Fix #13: shimmer placeholder
                    placeholder: (context, url) => _buildPlaceholder(),
                    // Fix #14: proper error widget
                    errorWidget: (context, url, error) => _buildErrorWidget(),
                  )
                : _buildErrorWidget(),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (monument.isUNESCO)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.pillRadius,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, color: Color(0xFF85F8C4), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'موقع يونسكو',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  if (monument.isUNESCO) const SizedBox(height: 12),

                  Text(
                    monument.name.get(lang),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fix #25: ابدأ الجولة button actually navigates
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.push('/tour360/${monument.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ابدأ الجولة الافتراضية',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(color: AppColors.surfaceContainerHigh);
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 8),
            Text('لا توجد صورة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
