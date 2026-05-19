import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/athera_text_field.dart';
import '../../../../shared/widgets/error_banner.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  final _emailController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();

  // Step 2
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (_) => FocusNode());

  // Step 3
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _passFormKey = GlobalKey<FormState>();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
      _errorMsg = null;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _sendCode() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await ref
        .read(authProvider.notifier)
        .forgotPassword(_emailController.text.trim());
    setState(() => _isLoading = false);
    if (success && mounted) _goToStep(1);
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      setState(() => _errorMsg = 'الرجاء إدخال رمز التحقق كاملاً');
      return;
    }
    // Mock: any 4-digit code works
    _goToStep(2);
  }

  Future<void> _changePassword() async {
    if (!_passFormKey.currentState!.validate()) return;
    if (_newPassController.text != _confirmPassController.text) {
      setState(() => _errorMsg = 'كلمتا المرور غير متطابقتين');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تغيير كلمة المرور بنجاح!',
            style: GoogleFonts.cairo(),
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: const Color(0xFF006142),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── App bar ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColors.textPrimary,
                      onPressed: () {
                        if (_currentStep > 0) {
                          _goToStep(_currentStep - 1);
                        } else {
                          context.pop();
                        }
                      },
                    ),
                    const Spacer(),
                    Text(
                      'استعادة كلمة المرور',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance
                  ],
                ),
              ),

              // ── Step indicator ───────────────────────────
              _StepIndicator(currentStep: _currentStep),

              const SizedBox(height: 8),

              // ── Page content ─────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _Step1Email(
                      emailController: _emailController,
                      formKey: _emailFormKey,
                      isLoading: _isLoading,
                      onSubmit: _sendCode,
                    ),
                    _Step2Otp(
                      controllers: _otpControllers,
                      focusNodes: _otpFocusNodes,
                      email: _emailController.text,
                      errorMsg: _errorMsg,
                      isLoading: _isLoading,
                      onVerify: _verifyOtp,
                      onResend: () => setState(() {}),
                    ),
                    _Step3NewPassword(
                      newPassController: _newPassController,
                      confirmPassController: _confirmPassController,
                      formKey: _passFormKey,
                      obscureNew: _obscureNew,
                      obscureConfirm: _obscureConfirm,
                      onToggleNew: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      onToggleConfirm: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      errorMsg: _errorMsg,
                      isLoading: _isLoading,
                      onSubmit: _changePassword,
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

// ─────────────────────────────────────────────
// Step Indicator
// ─────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = ['البريد', 'التحقق', 'كلمة المرور'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryContainer
                              : const Color(0xFFE0E3EC),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 18)
                              : Text(
                                  '${i + 1}',
                                  style: GoogleFonts.cairo(
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textTertiary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isActive
                              ? AppColors.primaryContainer
                              : AppColors.textTertiary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      color: i < currentStep
                          ? AppColors.primaryContainer
                          : const Color(0xFFE0E3EC),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step 1: Email
// ─────────────────────────────────────────────

class _Step1Email extends StatelessWidget {
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _Step1Email({
    required this.emailController,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFFE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.email_outlined,
                    size: 36, color: AppColors.primaryContainer),
              ),
            ).animate().fade().scale(),

            const SizedBox(height: 24),

            Text(
              'أدخل بريدك الإلكتروني',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fade(delay: 100.ms),

            const SizedBox(height: 8),

            Text(
              'سنرسل إليك رمز التحقق المكون من 4 أرقام',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fade(delay: 150.ms),

            const SizedBox(height: 28),

            AtheraTextField(
              controller: emailController,
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
            ).animate().fade(delay: 200.ms),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text('إرسال رمز التحقق',
                        style: GoogleFonts.cairo(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ).animate().fade(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step 2: OTP
// ─────────────────────────────────────────────

class _Step2Otp extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final String email;
  final String? errorMsg;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _Step2Otp({
    required this.controllers,
    required this.focusNodes,
    required this.email,
    required this.errorMsg,
    required this.isLoading,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.sms_outlined,
                size: 36, color: Color(0xFF934B00)),
          ).animate().fade().scale(),

          const SizedBox(height: 24),

          Text(
            'رمز التحقق',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fade(delay: 100.ms),

          const SizedBox(height: 8),

          Text(
            'تم إرسال رمز التحقق إلى\n${email.isEmpty ? "بريدك الإلكتروني" : email}',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fade(delay: 150.ms),

          const SizedBox(height: 36),

          // OTP fields
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                width: 64,
                height: 68,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: TextFormField(
                  controller: controllers[i],
                  focusNode: focusNodes[i],
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE0E3EC)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE0E3EC)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.primaryContainer, width: 2),
                    ),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 3) {
                      focusNodes[i + 1].requestFocus();
                    } else if (v.isEmpty && i > 0) {
                      focusNodes[i - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ).animate().fade(delay: 200.ms),

          if (errorMsg != null) ...[
            const SizedBox(height: 16),
            ErrorBanner(message: errorMsg!),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text('تأكيد الرمز',
                      style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ).animate().fade(delay: 300.ms),

          const SizedBox(height: 20),

          TextButton.icon(
            onPressed: onResend,
            icon: const Icon(Icons.refresh_rounded,
                size: 16, color: AppColors.primaryContainer),
            label: Text(
              'إعادة إرسال الرمز',
              style: GoogleFonts.cairo(
                color: AppColors.primaryContainer,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fade(delay: 400.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Step 3: New Password
// ─────────────────────────────────────────────

class _Step3NewPassword extends StatelessWidget {
  final TextEditingController newPassController;
  final TextEditingController confirmPassController;
  final GlobalKey<FormState> formKey;
  final bool obscureNew;
  final bool obscureConfirm;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final String? errorMsg;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _Step3NewPassword({
    required this.newPassController,
    required this.confirmPassController,
    required this.formKey,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.errorMsg,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock_reset_rounded,
                    size: 36, color: Color(0xFF00472F)),
              ),
            ).animate().fade().scale(),

            const SizedBox(height: 24),

            Text(
              'كلمة المرور الجديدة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fade(delay: 100.ms),

            const SizedBox(height: 8),

            Text(
              'أدخل كلمة مرور جديدة لا تقل عن 8 أحرف',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fade(delay: 150.ms),

            const SizedBox(height: 28),

            AtheraTextField(
              controller: newPassController,
              label: 'كلمة المرور الجديدة',
              hint: '8 أحرف على الأقل',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: obscureNew,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onToggleNew,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
                if (v.length < 8) return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل';
                return null;
              },
            ).animate().fade(delay: 200.ms),

            const SizedBox(height: 16),

            AtheraTextField(
              controller: confirmPassController,
              label: 'تأكيد كلمة المرور',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onToggleConfirm,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'الرجاء تأكيد كلمة المرور';
                if (v != newPassController.text) return 'كلمتا المرور غير متطابقتين';
                return null;
              },
            ).animate().fade(delay: 250.ms),

            if (errorMsg != null) ...[
              const SizedBox(height: 16),
              ErrorBanner(message: errorMsg!),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text('تغيير كلمة المرور',
                        style: GoogleFonts.cairo(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ).animate().fade(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
