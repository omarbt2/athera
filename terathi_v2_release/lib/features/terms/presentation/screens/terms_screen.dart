import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


import '../../../../core/theme/app_colors.dart';
import '../../../../features/privacy/presentation/screens/privacy_policy_screen.dart'
    show PolicyAppBar, DateBadge, IntroCard;

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const PolicyAppBar(title: 'الشروط والأحكام'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const DateBadge(date: 'آخر تحديث: أكتوبر 2024')
                      .animate()
                      .fadeIn(),

                  const SizedBox(height: 20),

                  const IntroCard(
                    text:
                        'مرحباً بك في منصة Athera 3D. باستخدامك لهذه المنصة، فإنك توافق على الالتزام بالشروط والأحكام التالية. يُرجى قراءتها بعناية.',
                  ).animate(delay: 50.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 16),

                  ..._terms.asMap().entries.map((entry) {
                    final i = entry.key;
                    final t = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TermSection(
                        number: '${i + 1}',
                        icon: t['icon'] as IconData,
                        iconColor: t['color'] as Color,
                        title: t['title'] as String,
                        content: t['content'] as String,
                        bullets: t['bullets'] as List<String>?,
                      )
                          .animate(
                              delay: Duration(milliseconds: 80 + i * 60))
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.06, end: 0),
                    );
                  }),

                  const SizedBox(height: 20),

                  _AcceptCard()
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 350.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, dynamic>> _terms = [
    {
      'icon': Icons.gavel_rounded,
      'color': Color(0xFF1A3A8A),
      'title': 'شروط الخدمة',
      'content':
          'تُقدم خدمات Athera 3D "كما هي"، ونسعى جاهدين لضمان دقة المحتوى الAthera والمعلومات التاريخية، إلا أننا لا نضمن خلوها التام من الأخطاء.',
      'bullets': [
        'يُحظر استخدام المنصة لأغراض تجارية غير مصرح بها',
        'لا يجوز إعادة بيع المحتوى أو توزيعه دون إذن كتابي',
        'يُمنع محاولة اختراق أو تعطيل البنية التحتية للمنصة',
        'نحتفظ بحق تعديل أو إيقاف أي جزء من الخدمة',
      ],
    },
    {
      'icon': Icons.copyright_rounded,
      'color': Color(0xFF0F6E56),
      'title': 'حقوق الملكية الفكرية',
      'content':
          'جميع النماذج الثلاثية الأبعاد، الصور، النصوص، والتصاميم المعروضة على المنصة هي ملكية حصرية لAthera 3D أو للجهات الأكاديمية الشريكة.',
      'bullets': [
        'لا يجوز نسخ أو تعديل أي محتوى دون تصريح رسمي',
        'يُسمح بالاستخدام الأكاديمي غير الربحي مع الإشارة للمصدر',
        'يُحظر استخدام الشعار أو الهوية البصرية للمنصة',
      ],
    },
    {
      'icon': Icons.balance_rounded,
      'color': Color(0xFFB5860D),
      'title': 'المسؤولية القانونية',
      'content':
          'لا تتحمل منصة Athera 3D أي مسؤولية عن أية أضرار مباشرة أو غير مباشرة قد تنشأ عن استخدام المنصة أو عدم القدرة على استخدامها.',
      'bullets': null,
    },
    {
      'icon': Icons.account_circle_rounded,
      'color': Color(0xFF6B21A8),
      'title': 'مسؤوليات المستخدم',
      'content':
          'أنت مسؤول عن الحفاظ على سرية بيانات حسابك وعن جميع الأنشطة التي تتم من خلاله.',
      'bullets': [
        'استخدام معلومات تسجيل صحيحة وحقيقية',
        'إخطارنا فوراً عند الاشتباه في استخدام غير مصرح به',
        'الامتناع عن مشاركة محتوى مسيء أو غير لائق',
      ],
    },
    {
      'icon': Icons.update_rounded,
      'color': Color(0xFF0F6E56),
      'title': 'التعديلات على الشروط',
      'content':
          'نحتفظ بحق تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية عبر البريد الإلكتروني أو إشعار داخل التطبيق. استمرارك في استخدام المنصة بعد التغييرات يُعدّ موافقةً منك.',
      'bullets': null,
    },
  ];
}

class _TermSection extends StatelessWidget {
  final String number;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final List<String>? bullets;

  const _TermSection({
    required this.number,
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
                  child: Center(
                    child: Text(
                      number,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              height: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(
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
                                style: const TextStyle(
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

class _AcceptCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.logoTeal.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'باستمرارك في استخدام Athera 3D، فإنك توافق على هذه الشروط والأحكام.',
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
    );
  }
}