import 'package:flutter/material.dart';

import 'package:habit_coach/core/design/app_colors.dart';
import 'package:habit_coach/core/design/app_spacing.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedPlan = 1; // 0=weekly, 1=annual, 2=lifetime
  bool _showDismiss = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showDismiss = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  AppSpacing.vGap32,

                  // --- Hero ---
                  const Text(
                    '\u{2728}',
                    style: TextStyle(fontSize: 64),
                  ),
                  AppSpacing.vGap16,
                  Text(
                    'Unlock Your Full Potential',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vGap8,
                  Text(
                    'Join 10,000+ habit builders',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vGap24,

                  // --- Feature Comparison ---
                  _buildFeatureComparison(cs, tt),
                  AppSpacing.vGap24,

                  // --- Pricing Cards ---
                  _buildPricingCard(
                    index: 0,
                    title: 'Weekly',
                    price: '\$2.99',
                    period: '/week',
                    badge: null,
                    ribbon: null,
                    cs: cs,
                    tt: tt,
                  ),
                  AppSpacing.vGap12,
                  _buildPricingCard(
                    index: 1,
                    title: 'Annual',
                    price: '\$39.99',
                    period: '/year',
                    badge: 'SAVE 75%',
                    ribbon: 'Most Popular',
                    cs: cs,
                    tt: tt,
                  ),
                  AppSpacing.vGap12,
                  _buildPricingCard(
                    index: 2,
                    title: 'Lifetime',
                    price: '\$79.99',
                    period: ' one-time',
                    badge: 'Best Value',
                    ribbon: null,
                    cs: cs,
                    tt: tt,
                  ),
                  AppSpacing.vGap24,

                  // --- CTA Button ---
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primary,
                          const Color(0xFF8B5CF6),
                        ],
                      ),
                      borderRadius: AppSpacing.borderRadiusMedium,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: AppSpacing.borderRadiusMedium,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Free trial started! (Demo mode)'),
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            'Start 7-Day Free Trial',
                            style: tt.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.vGap12,

                  // --- Restore Purchases ---
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No previous purchases found.'),
                        ),
                      );
                    },
                    child: Text(
                      'Restore Purchases',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AppSpacing.vGap4,

                  // --- Trust Text ---
                  Text(
                    'Cancel anytime \u{2022} No commitment',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vGap24,
                ],
              ),
            ),

            // --- Dismiss Button ---
            if (_showDismiss)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppSpacing.borderRadiusLarge,
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Feature', style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
              ),
              Expanded(
                child: Text('Free', textAlign: TextAlign.center,
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text('Pro', textAlign: TextAlign.center,
                  style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          _featureRow('Habits', '3', 'Unlimited', cs, tt),
          _featureRow('Streaks', 'Basic', '\u{2713}', cs, tt),
          _featureRow('Statistics', 'Basic', 'Detailed', cs, tt),
          _featureRow('AI Coaching', '\u{2014}', '\u{2713}', cs, tt),
          _featureRow('Export Data', '\u{2014}', '\u{2713}', cs, tt),
          _featureRow('Themes', '\u{2014}', '\u{2713}', cs, tt),
          _featureRow('Ads', 'Yes', 'No', cs, tt),
        ],
      ),
    );
  }

  Widget _featureRow(
      String feature, String free, String pro, ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(feature, style: tt.bodySmall),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              pro,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required int index,
    required String title,
    required String price,
    required String period,
    required String? badge,
    required String? ribbon,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primaryContainer.withValues(alpha: 0.3)
              : cs.surface,
          borderRadius: AppSpacing.borderRadiusMedium,
          border: Border.all(
            color: isSelected
                ? cs.primary
                : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            AppSpacing.hGap12,
            // Plan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (ribbon != null) ...[
                        AppSpacing.hGap8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text(
                            ribbon,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      period,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (badge != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Text(
                      badge,
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
