import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/athera_text_field.dart';
import '../../../../shared/widgets/error_banner.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
        );
    final state = ref.read(authProvider);
    if (mounted && state is AuthAuthenticated) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final errorMsg = authState is AuthError ? authState.message : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back button ───────────────────────────
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textPrimary,
                  ).animate().fade(),

                  const SizedBox(height: 12),

                  // ── Header ─────────────────────────────────
                  Text(
                    'إنشاء حساب جديد',
                    style: GoogleFonts.cairo(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fade(delay: 100.ms).slideX(begin: 0.2, end: 0),

                  Text(
                    'انضم إلى مجتمع محبي التراث الجزائري',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fade(delay: 150.ms),

                  const SizedBox(height: 36),

                  // ── Name ──────────────────────────────────
                  AtheraTextField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    hint: 'محمد بن أحمد',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'الرجاء إدخال الاسم';
                      if (v.trim().length < 2) return 'الاسم قصير جداً';
                      return null;
                    },
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // ── Email ─────────────────────────────────
                  AtheraTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'example@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                      final emailReg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailReg.hasMatch(v)) return 'صيغة البريد الإلكتروني غير صحيحة';
                      return null;
                    },
                  ).animate().fade(delay: 250.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // ── Password ──────────────────────────────
                  AtheraTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: '8 أحرف على الأقل',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
                      if (v.length < 8) return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل';
                      return null;
                    },
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // ── Confirm Password ──────────────────────
                  AtheraTextField(
                    controller: _confirmController,
                    label: 'تأكيد كلمة المرور',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'الرجاء تأكيد كلمة المرور';
                      if (v != _passwordController.text) {
                        return 'كلمتا المرور غير متطابقتين';
                      }
                      return null;
                    },
                  ).animate().fade(delay: 350.ms).slideY(begin: 0.1, end: 0),

                  // ── Error banner ──────────────────────────
                  if (errorMsg != null) ...[
                    const SizedBox(height: 16),
                    ErrorBanner(message: errorMsg),
                  ],

                  const SizedBox(height: 32),

                  // ── Register button ───────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primaryContainer.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'إنشاء حساب',
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // ── Login link ────────────────────────────
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب؟ ',
                          style: GoogleFonts.cairo(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'سجّل الدخول',
                            style: GoogleFonts.cairo(
                              color: AppColors.primaryContainer,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 500.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
