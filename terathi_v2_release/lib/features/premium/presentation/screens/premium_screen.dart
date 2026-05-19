import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Athera Premium'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryContainer,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.stars, size: 80, color: AppColors.secondaryContainer),
            const SizedBox(height: 24),
            Text(
              'اشترك في النسخة الممتازة',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'استمتع بجولات 360° حصرية، مرشد ذكي متطور، وبدون إعلانات.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildPlanCard(context, 'شهري', '499 دج', 'تجربة لمدة 7 أيام مجاناً'),
            const SizedBox(height: 16),
            _buildPlanCard(context, 'سنوي', '3,999 دج', 'وفر 33% مع الاشتراك السنوي', isBestValue: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('ابدأ اشتراكك الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, String price, String subtitle, {bool isBestValue = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBestValue ? AppColors.primaryContainer.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isBestValue ? AppColors.primaryContainer : Colors.grey.shade300, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryContainer)),
        ],
      ),
    );
  }
}
