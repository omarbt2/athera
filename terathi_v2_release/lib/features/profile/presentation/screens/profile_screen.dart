
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final user = ref.read(authStateProvider);
      if (user == null) return;

      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last;
      final path = '${user.id}/avatar.$ext';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(path, bytes,
              fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'));

      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);

      final err = await ref.read(authProvider.notifier).updateProfile(avatarUrl: publicUrl);
      if (err != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل رفع الصورة. حاول مجدداً.')));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const isPremium = false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.9),
                        colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'حسابي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, color: colorScheme.onPrimary),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar
                Positioned(
                  bottom: -60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _pickAndUploadAvatar,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colorScheme.surface, width: 5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: user?.avatarUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: user!.avatarUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      memCacheHeight: 200,
                                      placeholder: (context, url) => Container(
                                        color: colorScheme.surfaceContainerHigh,
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (context, url, error) => Icon(
                                          Icons.person_rounded,
                                          size: 48,
                                          color: colorScheme.primary),
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: colorScheme.surfaceContainerHigh,
                                      child: Icon(Icons.person_rounded,
                                          size: 48, color: colorScheme.primary),
                                    ),
                            ),
                          ),
                          if (_uploadingAvatar)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black38),
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2)),
                              ),
                            ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: colorScheme.surface, width: 2),
                              ),
                              child: Icon(Icons.edit_rounded,
                                  color: colorScheme.onPrimary, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),

          // ── Name & Email ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 72, bottom: 4),
              child: Column(
                children: [
                  Text(
                    user?.name ?? 'ضيف',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Cairo',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (user?.wilaya != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          user!.wilaya!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Cairo',
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (user?.joinDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'عضو منذ ${DateFormat('MMM yyyy', 'ar').format(user!.joinDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Cairo',
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
          ),

          // ── Premium Card ─────────────────────────
          if (!isPremium)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF755B00), Color(0xFFC9A84C)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC9A84C).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⭐ الباقة المميزة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'جولات حصرية · AI غير محدود',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/premium'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF755B00),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('اشترك',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ),
            ),

          // ── Menu ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'تعديل الملف الشخصي',
                      onTap: () => _showEditProfileSheet(context, ref, user),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.lock_reset_rounded,
                      label: 'تغيير كلمة المرور',
                      onTap: () => _showChangePasswordSheet(context, ref),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'الإشعارات',
                      onTap: () => context.push('/notifications'),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.emoji_events_outlined,
                      label: 'إنجازاتي',
                      onTap: () => context.push('/achievements'),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.history_rounded,
                      label: 'رحلة الاستكشاف',
                      onTap: () => context.push('/tour-history'),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.star_outline_rounded,
                      label: 'اشتراكي',
                      onTap: () => context.push('/premium'),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: 'تسجيل الخروج',
                      onTap: () => _showLogoutDialog(context, ref),
                      isDestructive: true,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, AtheraUser? user) {
    final nameCtrl = TextEditingController(text: user?.name);
    final wilayaCtrl = TextEditingController(text: user?.wilaya ?? '');
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تعديل الملف الشخصي',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wilayaCtrl,
              decoration: const InputDecoration(
                labelText: 'الولاية',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final err = await ref
                      .read(authProvider.notifier)
                      .updateProfile(
                        fullName: nameCtrl.text.trim(),
                        wilaya: wilayaCtrl.text.trim().isEmpty
                            ? null
                            : wilayaCtrl.text.trim(),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(err ?? 'تم تحديث الملف الشخصي ✓'),
                      backgroundColor: err == null ? colorScheme.primary : colorScheme.error,
                    ));
                  }
                },
                child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscure1 = true, obscure2 = true;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تغيير كلمة المرور',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: newPassCtrl,
                obscureText: obscure1,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setModalState(() => obscure1 = !obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassCtrl,
                obscureText: obscure2,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setModalState(() => obscure2 = !obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final err = await ref
                        .read(authProvider.notifier)
                        .changePassword(
                          newPassword: newPassCtrl.text,
                          confirmPassword: confirmPassCtrl.text,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(err ?? 'تم تغيير كلمة المرور بنجاح ✓'),
                        backgroundColor: err == null ? colorScheme.primary : colorScheme.error,
                      ));
                    }
                  },
                  child: const Text('تغيير', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('تسجيل الخروج',
            style: TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تسجيل الخروج',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

// ── Menu Item ─────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.primary;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 20,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
