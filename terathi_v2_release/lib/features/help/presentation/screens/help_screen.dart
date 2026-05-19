import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaq = _faqItems.where((f) {
      if (_searchQuery.isEmpty) return true;
      return f['q']!.contains(_searchQuery) ||
          f['a']!.contains(_searchQuery);
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'المساعدة والدعم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                    height: 1,
                    color: AppColors.outlineVariant
                        .withValues(alpha: 0.4)),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Hero ─────────────────────────────────────────
                  _HeroSection()
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 20),

                  // ── Quick Actions ─────────────────────────────────
                  _QuickActionsRow()
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 350.ms),

                  const SizedBox(height: 24),

                  // ── Search ────────────────────────────────────────
                  _HelpSearchBar(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ).animate(delay: 150.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 20),

                  // ── FAQ ───────────────────────────────────────────
                  Text(
                    'الأسئلة الشائعة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ).animate(delay: 180.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 12),

                  if (filteredFaq.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          'لا توجد نتائج للبحث',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),

                  ...filteredFaq.asMap().entries.map((entry) {
                    final i = entry.key;
                    final faq = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FaqItem(
                        question: faq['q']!,
                        answer: faq['a']!,
                        isExpanded: _expandedIndex == i,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _expandedIndex =
                              _expandedIndex == i ? null : i);
                        },
                      )
                          .animate(
                              delay: Duration(milliseconds: 200 + i * 40))
                          .fadeIn(duration: 300.ms),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ── Contact Card ──────────────────────────────────
                  _ContactSupportCard()
                      .animate(delay: 450.ms)
                      .fadeIn(duration: 350.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String>> _faqItems = [
    {
      'q': 'كيف أبدأ الجولة الافتراضية 360°؟',
      'a':
          'افتح أي معلم من الصفحة الرئيسية أو صفحة الاستكشاف، ثم اضغط على زر "ابدأ الجولة الافتراضية 360°" في أسفل صفحة تفاصيل المعلم. يمكنك بعدها السحب يميناً أو يساراً للتنقل بين نقاط الاهتمام.',
    },
    {
      'q': 'كيف أحفظ معلماً في المفضلة؟',
      'a':
          'اضغط على أيقونة الإشارة المرجعية (bookmark) في أعلى صفحة تفاصيل المعلم. ستجد جميع معالمك المحفوظة في تبويب "المحفوظات" في شريط التنقل السفلي.',
    },
    {
      'q': 'كيف أستخدم المرشد الذكي؟',
      'a':
          'ادخل على أي معلم واضغط على "تحدث مع المرشد الذكي". يمكنك سؤاله عن تاريخ المعلم، معماره، الحضارات التي عرفته، وأي معلومة تاريخية تريدها. يعمل المرشد بالذكاء الاصطناعي ويحتاج اتصالاً بالإنترنت.',
    },
    {
      'q': 'هل يعمل التطبيق بدون إنترنت؟',
      'a':
          'يمكنك تصفح المعالم المحفوظة مسبقاً بدون إنترنت. أما الجولات الافتراضية والمرشد الذكي فيحتاجان اتصالاً بالإنترنت. مميزو الاشتراك المميز يمكنهم تحميل المعالم للمشاهدة بدون إنترنت.',
    },
    {
      'q': 'كيف أغيّر لغة التطبيق؟',
      'a':
          'اذهب إلى الملف الشخصي ← الإعدادات ← اللغة. يدعم التطبيق حالياً العربية، الفرنسية، والإنجليزية.',
    },
    {
      'q': 'ما هي مميزات الاشتراك المميز؟',
      'a':
          'الاشتراك المميز يتيح لك: الجولات الافتراضية الكاملة لجميع المعالم، المرشد الذكي غير المحدود، تحميل المعالم للمشاهدة بدون إنترنت، وتجربة خالية من الإعلانات.',
    },
    {
      'q': 'كيف أُلغي اشتراكي المميز؟',
      'a':
          'يمكنك إلغاء الاشتراك في أي وقت من إعدادات الجهاز (App Store/Play Store ← الاشتراكات). لن يتم تجديد الاشتراك في الدورة القادمة.',
    },
    {
      'q': 'ماذا أفعل إذا واجهت مشكلة تقنية؟',
      'a':
          'أولاً أعد تشغيل التطبيق. إذا استمرت المشكلة تواصل معنا عبر contact@Athera3d.dz مع وصف المشكلة ونوع جهازك ونظام التشغيل.',
    },
  ];
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.logoTeal, AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كيف يمكننا مساعدتك؟',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ابحث في الأسئلة الشائعة أو تواصل مع فريق الدعم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.support_agent_rounded,
                color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

// ── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.email_rounded,
            color: AppColors.primary,
            label: 'مراسلة الدعم',
            onTap: () =>
                launchUrl(Uri.parse('mailto:contact@Athera3d.dz')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.bug_report_rounded,
            color: AppColors.logoTeal,
            label: 'الإبلاغ عن خطأ',
            onTap: () => launchUrl(Uri.parse(
                'mailto:bugs@Athera3d.dz?subject=تقرير خطأ')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.star_rounded,
            color: const Color(0xFFB5860D),
            label: 'تقييم التطبيق',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search ───────────────────────────────────────────────────────────────────

class _HelpSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _HelpSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded,
              size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'ابحث في الأسئلة...',
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAQ Item ─────────────────────────────────────────────────────────────────

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Question row
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Answer (animated)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Container(
                    height: 1,
                    color: AppColors.outlineVariant
                        .withValues(alpha: 0.3)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact Support Card ─────────────────────────────────────────────────────

class _ContactSupportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.headset_mic_rounded,
              size: 32, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            'لم تجد إجابتك؟',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'فريق الدعم متاح من الأحد إلى الخميس\n9 صباحاً - 5 مساءً',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textTertiary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => launchUrl(
                  Uri.parse('mailto:contact@Athera3d.dz')),
              icon: const Icon(Icons.email_rounded, size: 18),
              label: const Text(
                'مراسلة فريق الدعم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}