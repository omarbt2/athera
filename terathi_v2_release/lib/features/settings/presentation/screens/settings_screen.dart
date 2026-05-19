import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/providers/common_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final isWifiOnly = ref.watch(wifiOnlyProvider);
    final isNotificationsEnabled = ref.watch(notificationsEnabledProvider);
    final isNewMonumentsEnabled = ref.watch(newMonumentsProvider);
    final isSpecialOffersEnabled = ref.watch(specialOffersProvider);
    final currentLanguage = ref.watch(languageProvider);
    final videoQuality = ref.watch(videoQualityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionTitle(context, 'عام'),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.language_rounded, color: AppColors.primary),
              title: const Text('لغة التطبيق', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getLanguageName(currentLanguage),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_left, color: AppColors.textTertiary),
                ],
              ),
              onTap: () => _showLanguageSheet(context, ref, currentLanguage),
            ),
            const Divider(height: 1, indent: 56),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
              title: const Text('الوضع الليلي', style: TextStyle(fontWeight: FontWeight.bold)),
              value: isDarkMode,
              activeColor: AppColors.primary,
              onChanged: (val) => ref.read(themeProvider.notifier).toggle(val),
            ),
          ]),

          _buildSectionTitle(context, 'الجودة'),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.hd_rounded, color: AppColors.primary),
              title: const Text('جودة الفيديو', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(videoQuality, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_left, color: AppColors.textTertiary),
                ],
              ),
              onTap: () => _showVideoQualitySheet(context, ref, videoQuality),
            ),
            const Divider(height: 1, indent: 56),
            SwitchListTile(
              secondary: const Icon(Icons.wifi_rounded, color: AppColors.primary),
              title: const Text('التحميل عبر WiFi فقط', style: TextStyle(fontWeight: FontWeight.bold)),
              value: isWifiOnly,
              activeColor: AppColors.primary,
              onChanged: (val) => ref.read(wifiOnlyProvider.notifier).set(val),
            ),
          ]),

          _buildSectionTitle(context, 'الإشعارات'),
          _buildSettingsCard([
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
              title: const Text('تفعيل الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
              value: isNotificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) => ref.read(notificationsEnabledProvider.notifier).set(val),
            ),
            if (isNotificationsEnabled) ...[
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.account_balance_rounded, color: AppColors.textTertiary),
                title: const Text('معالم جديدة', style: TextStyle(fontWeight: FontWeight.w600)),
                value: isNewMonumentsEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) => ref.read(newMonumentsProvider.notifier).set(val),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.local_offer, color: AppColors.textTertiary),
                title: const Text('عروض خاصة', style: TextStyle(fontWeight: FontWeight.w600)),
                value: isSpecialOffersEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) => ref.read(specialOffersProvider.notifier).set(val),
              ),
            ]
          ]),

          _buildSectionTitle(context, 'التخزين'),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.sd_storage_rounded, color: AppColors.primary),
              title: const Text('حجم الذاكرة المؤقتة', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('125 MB'),
              trailing: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تفريغ الذاكرة المؤقتة')));
                },
                child: const Text('تفريغ', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ),
            const Divider(height: 1, indent: 56),
            const ListTile(
              leading: Icon(Icons.download_done_rounded, color: AppColors.primary),
              title: Text('الجولات المحملة', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('0 جولة، 0 MB'),
            ),
          ]),

          _buildSectionTitle(context, 'الحساب'),
          _buildSettingsCard([
            ListTile(
              leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
              title: const Text('تغيير كلمة المرور', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_left, color: AppColors.textTertiary),
              onTap: () => context.push('/profile'),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
              title: const Text('حذف الحساب', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ]),

          _buildSectionTitle(context, 'حول'),
          _buildSettingsCard([
            const ListTile(
              leading: Icon(Icons.info_rounded, color: AppColors.primary),
              title: Text('إصدار التطبيق', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.star_rate, color: AppColors.secondaryContainer),
              title: const Text('تقييم التطبيق', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_left, color: AppColors.textTertiary),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.privacy_tip_rounded, color: AppColors.primary),
              title: const Text('سياسة الخصوصية', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_left, color: AppColors.textTertiary),
              onTap: () => context.push('/privacy'),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.description_rounded, color: AppColors.primary),
              title: const Text('الشروط والأحكام', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_left, color: AppColors.textTertiary),
              onTap: () => context.push('/terms'),
            ),
          ]),

          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Made with ❤️ in Algeria 🇩🇿',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar': return 'العربية';
      case 'ar_dz': return 'الدارجة';
      case 'fr': return 'Français';
      case 'en': return 'English';
      default: return 'العربية';
    }
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref, String currentLang) {
    final languages = [
      {'code': 'ar', 'name': 'العربية', 'flag': '🇩🇿'},
      {'code': 'ar_dz', 'name': 'الدارجة', 'flag': '🇩🇿'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر لغة التطبيق',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...languages.map((l) => RadioListTile<String>(
                title: Row(
                  children: [
                    Text(l['flag']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Text(l['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                value: l['code']!,
                groupValue: currentLang,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  if (val != null) {
                    ref.read(languageProvider.notifier).setLanguage(val);
                    Navigator.pop(ctx);
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoQualitySheet(BuildContext context, WidgetRef ref, String currentQuality) {
    final qualities = ['HD', 'SD', 'منخفضة'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'جودة الفيديو',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...qualities.map((q) => RadioListTile<String>(
                title: Text(q, style: const TextStyle(fontWeight: FontWeight.bold)),
                value: q,
                groupValue: currentQuality,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  if (val != null) {
                    ref.read(videoQualityProvider.notifier).set(val);
                    Navigator.pop(ctx);
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
        content: const Text('هل أنت متأكد أنك تريد حذف حسابك نهائياً؟ لا يمكن التراجع عن هذا الإجراء.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Perform deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );
  }
}
