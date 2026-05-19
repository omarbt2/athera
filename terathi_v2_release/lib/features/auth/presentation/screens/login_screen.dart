import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/terathi_text_field.dart';
import '../../../../shared/widgets/error_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // ── Logo ──────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ).animate().fade(duration: 600.ms).scale(delay: 100.ms),

                  const SizedBox(height: 16),

                  Text(
                    'Athera 3D',
                    style: const TextStyle(fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryContainer,
                    ),
                  ).animate().fade(delay: 200.ms),

                  const SizedBox(height: 36),

                  // ── Title ─────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'مرحباً بعودتك',
                      style: const TextStyle(fontFamily: 'Cairo',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fade(delay: 300.ms).slideX(begin: 0.2, end: 0),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'سجّل دخولك للاستكشاف',
                      style: const TextStyle(fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ).animate().fade(delay: 350.ms),

                  const SizedBox(height: 32),

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
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // ── Password ──────────────────────────────
                  AtheraTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: '••••••••',
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
                      return null;
                    },
                  ).animate().fade(delay: 450.ms).slideY(begin: 0.1, end: 0),

                  // ── Forgot password ───────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.go('/forgot-password'),
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: const TextStyle(fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 500.ms),

                  // ── Error banner ──────────────────────────
                  if (errorMsg != null) ...[
                    const SizedBox(height: 8),
                    ErrorBanner(message: errorMsg),
                  ],

                  const SizedBox(height: 24),

                  // ── Login button ──────────────────────────
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
                              'تسجيل الدخول',
                              style: const TextStyle(fontFamily: 'Cairo',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ).animate().fade(delay: 550.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 28),

                  // ── Divider ───────────────────────────────
                  _OrDivider(),

                  const SizedBox(height: 24),

                  // ── Google button ─────────────────────────
                  _GoogleSignInButton(),

                  const SizedBox(height: 36),

                  // ── Register link ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟ ',
                        style: const TextStyle(fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          'سجّل الآن',
                          style: const TextStyle(fontFamily: 'Cairo',
                            color: AppColors.primaryContainer,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 700.ms),

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

// ─────────────────────────────────────────────
// Or Divider
// ─────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE0E3EC))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'أو',
            style: const TextStyle(fontFamily: 'Cairo',
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE0E3EC))),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Google Sign In Button
// ─────────────────────────────────────────────

class _GoogleSignInButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          ref.read(authProvider.notifier).signInWithGoogle();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE0E3EC), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G logo using text
            Text(
              'G',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4285F4),
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'المتابعة مع Google',
              style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
