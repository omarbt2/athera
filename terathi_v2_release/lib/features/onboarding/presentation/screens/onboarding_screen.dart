import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/onboarding_provider.dart';

class _OnboardingSlide {
  final String? svgPath;
  final String? imagePath;
  final String? arabicLetter;
  final Color letterColor;
  final Color bgFrom;
  final Color bgTo;
  final String title;
  final String subtitle;
  final String tag;

  const _OnboardingSlide({
    this.imagePath,
    this.arabicLetter,
    required this.letterColor,
    required this.bgFrom,
    required this.bgTo,
    required this.title,
    required this.subtitle,
    required this.tag,
  }) : svgPath = null;
}

const _slides = [
  _OnboardingSlide(
    imagePath: 'assets/images/logo.png',
    letterColor: Color(0xFFB4FDF7),
    bgFrom: Color(0xFF024A47),
    bgTo: Color(0xFF2C7873),
    title: 'مرحباً في Athera 3D',
    subtitle: 'رحلة افتراضية غامرة\nفي قلب التراث الجزائري العريق',
    tag: '127 معلماً تاريخياً',
  ),
  _OnboardingSlide(
    arabicLetter: '360',
    letterColor: Color(0xFFFFEDD2),
    bgFrom: Color(0xFF504531),
    bgTo: Color(0xFF786B54),
    title: 'استكشف بتقنية 360°',
    subtitle: 'جولات افتراضية غامرة\nداخل أعرق المواقع الأثرية',
    tag: 'تجربة واقعية مذهلة',
  ),
  _OnboardingSlide(
    arabicLetter: 'AI',
    letterColor: Color(0xFFFED977),
    bgFrom: Color(0xFF584400),
    bgTo: Color(0xFF755B00),
    title: 'مرشدك الذكي الشخصي',
    subtitle: 'تحدث بالدارجة والعربية\nواحصل على معلومات دقيقة وحصرية',
    tag: 'ذكاء اصطناعي متقدم',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

// Fix #34: Removed TickerProviderStateMixin (was unused)
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _previousPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).markCompleted();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;
    final slide = _slides[_currentPage];
    final prevSlide = _slides[_previousPage];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Stack(
            children: [
              // Fix #22: TweenAnimationBuilder with LinearGradient.lerp for proper gradient animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                key: ValueKey(_currentPage),
                builder: (context, t, child) {
                  final fromGradient = LinearGradient(
                    colors: [prevSlide.bgFrom, prevSlide.bgTo],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  );
                  final toGradient = LinearGradient(
                    colors: [slide.bgFrom, slide.bgTo],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  );
                  final lerped = LinearGradient.lerp(fromGradient, toGradient, t)!;
                  return DecoratedBox(
                    decoration: BoxDecoration(gradient: lerped),
                    child: const SizedBox.expand(),
                  );
                },
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(_slides.length, (i) {
                              final active = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(left: 6),
                                width: active ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active ? Colors.white : Colors.white.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              );
                            }),
                          ),
                          AnimatedOpacity(
                            opacity: isLast ? 0 : 1,
                            duration: const Duration(milliseconds: 300),
                            child: TextButton(
                              onPressed: _skip,
                              child: Text(
                                'تخطي',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PageView
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (i) => setState(() {
                          _previousPage = _currentPage;
                          _currentPage = i;
                        }),
                        itemBuilder: (context, index) => _SlidePage(
                          slide: _slides[index],
                          isActive: _currentPage == index,
                        ),
                      ),
                    ),

                    // Bottom CTA
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              key: ValueKey(slide.tag),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                slide.tag,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: slide.bgFrom,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  isLast ? 'ابدأ الاستكشاف 🏛️' : 'التالي',
                                  key: ValueKey(isLast),
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _OnboardingSlide slide;
  final bool isActive;

  const _SlidePage({required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isActive ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: slide.imagePath != null
                    ? Image.asset(
                        slide.imagePath!,
                        width: 100,
                        height: 100,
                      )
                    : slide.svgPath != null
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: SvgPicture.asset(
                              slide.svgPath!,
                              colorFilter: ColorFilter.mode(
                                slide.letterColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          )
                        : Text(
                        slide.arabicLetter ?? '',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: (slide.arabicLetter?.length ?? 0) == 1 ? 90 : 44,
                          fontWeight: FontWeight.w700,
                          color: slide.letterColor,
                          height: 1,
                        ),
                      ),
              ),
            ),
          ).animate(target: isActive ? 1 : 0).fade(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 52),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
            ),
          ).animate(target: isActive ? 1 : 0).fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.8,
            ),
          ).animate(target: isActive ? 1 : 0).fade(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
