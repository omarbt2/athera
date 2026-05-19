import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            PolicyAppBar(title: 'سياسة الخصوصية'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Date badge
                  DateBadge(date: 'آخر تحديث: أكتوبر 2024')
                      .animate()
                      .fadeIn(duration: 350.ms),

                  const SizedBox(height: 20),

                  // Intro
                  IntroCard(
                    text:
                        'توضح هذه السياسة كيف نقوم بجمع، استخدام، وحماية بياناتك الشخصية أثناء استخدامك لمنصة Athera 3D. نحن نقدّر خصوصيتك ونلتزم بحماية معلوماتك.',
                  ).animate(delay: 50.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),

                  const SizedBox(height: 16),

                  ..._sections.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: PolicySection(
                        icon: s['icon'] as IconData,
                        iconColor: s['color'] as Color,
                        title: s['title'] as String,
                        content: s['content'] as String,
                        bullets: s['bullets'] as List<String>?,
                      )
                          .animate(delay: Duration(milliseconds: 80 + i * 60))
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.06, end: 0),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Contact card
                  ContactCTA()
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 350.ms),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, dynamic>> _sections = [
    {
      'icon': Icons.data_usage_rounded,
      'color': Color(0xFF1A3A8A),
      'title': 'البيانات التي نجمعها',
      'content':
          'نقوم بجمع المعلومات اللازمة لتقديم خدماتنا وتحسين تجربتك على المنصة.',
      'bullets': [
        'معلومات الحساب الشخصي (الاسم، البريد الإلكتروني)',
        'بيانات تصفح النماذج الAtheraة واهتماماتك',
        'معلومات الجهاز ونظام التشغيل',
        'سجل الجولات الافتراضية والمعالم المحفوظة',
      ],
    },
    {
      'icon': Icons.analytics_rounded,
      'color': Color(0xFF0F6E56),
      'title': 'كيف نستخدم بياناتك',
      'content':
          'تُستخدم البيانات التي نجمعها بشكل أساسي لتوفير وتخصيص تجربتك في استكشاف التراث الجزائري.',
      'bullets': [
        'تقديم محتوى مخصص بناءً على اهتماماتك',
        'تحسين أداء التطبيق ومعالجة المشاكل',
        'إرسال إشعارات عن المعالم الجديدة (بموافقتك)',
        'تحليل استخدام الميزات لتطويرها',
      ],
    },
    {
      'icon': Icons.security_rounded,
      'color': Color(0xFFB5860D),
      'title': 'أمن البيانات',
      'content':
          'نتخذ إجراءات أمنية صارمة لحماية معلوماتك من الوصول غير المصرح به أو التعديل أو الإفصاح.',
      'bullets': [
        'تشفير البيانات الحساسة أثناء النقل والتخزين (SSL/TLS)',
        'حماية قواعد البيانات بأعلى معايير الأمان',
        'مراجعة دورية لأنظمة الحماية',
        'تقييد الوصول إلى البيانات للموظفين المصرح لهم فقط',
      ],
    },
    {
      'icon': Icons.share_rounded,
      'color': Color(0xFF6B21A8),
      'title': 'مشاركة المعلومات',
      'content':
          'نحن لا نبيع ولا نشارك بياناتك الشخصية مع أطراف ثالثة لأغراض تسويقية دون موافقتك الصريحة.',
      'bullets': null,
    },
    {
      'icon': Icons.manage_accounts_rounded,
      'color': Color(0xFF0F6E56),
      'title': 'حقوقك',
      'content': 'يحق لك في أي وقت:',
      'bullets': [
        'الاطلاع على بياناتك الشخصية المخزنة لدينا',
        'طلب تصحيح أي معلومات غير دقيقة',
        'طلب حذف حسابك وبياناتك بشكل نهائي',
        'سحب موافقتك على جمع البيانات',
      ],
    },
  ];
}

// ── Shared Widgets ───────────────────────────────────────────────────────────

class PolicyAppBar extends StatelessWidget {
  final String title;
  const PolicyAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
        title,
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
            color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
    );
  }
}

class DateBadge extends StatelessWidget {
  final String date;
  const DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          date,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class IntroCard extends StatelessWidget {
  final String text;
  const IntroCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
    );
  }
}

class PolicySection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final List<String>? bullets;

  const PolicySection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
              height: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.3)),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (bullets != null) ...[
                  const SizedBox(height: 10),
                  ...bullets!.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                b,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل لديك أسئلة؟',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'تواصل مع فريق الدعم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'راسلنا',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}