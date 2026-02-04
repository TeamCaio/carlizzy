import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/credits_service.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SubscriptionScreen({super.key, required this.onComplete});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedPlan;
  bool _isLoading = false;

  Future<void> _selectPlan(String plan) async {
    setState(() {
      _selectedPlan = plan;
    });
  }

  Future<void> _continueToPurchase() async {
    if (_selectedPlan == null) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final creditsService = await CreditsService.getInstance();

      if (_selectedPlan == 'annual_trial') {
        // Start free trial with annual subscription
        final started = await creditsService.startFreeTrial();
        if (!started) {
          if (mounted) _showError('Free trial already used');
          return;
        }
        await creditsService.setSubscriptionType('annual_trial');
      } else if (_selectedPlan == 'annual') {
        // TODO: Integrate with RevenueCat for actual purchase
        await creditsService.setSubscriptionType('annual');
        await creditsService.addCredits(CreditsService.annualCredits);
      } else if (_selectedPlan == 'monthly') {
        // TODO: Integrate with RevenueCat for actual purchase
        await creditsService.setSubscriptionType('monthly');
        await creditsService.addCredits(CreditsService.monthlyCredits);
      }

      widget.onComplete();
    } catch (e) {
      if (mounted) _showError('Failed to process: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: ThemeConstants.spacingLarge),
                    // Header
                    Text(
                      'Choose Your Plan',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A3F35),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ThemeConstants.spacingSmall),
                    Text(
                      'Unlock the virtual fitting room',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeConstants.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ThemeConstants.spacingXLarge),

                    // Annual with Free Trial (Recommended)
                    _PlanCard(
                      title: 'Annual',
                      subtitle: '7 day free trial',
                      price: '\$49.99/year',
                      isSelected: _selectedPlan == 'annual_trial',
                      isRecommended: true,
                      onTap: () => _selectPlan('annual_trial'),
                    ),
                    const SizedBox(height: ThemeConstants.spacingMedium),

                    // Monthly
                    _PlanCard(
                      title: 'Monthly',
                      price: '\$6.99/month',
                      isSelected: _selectedPlan == 'monthly',
                      onTap: () => _selectPlan('monthly'),
                    ),
                    const SizedBox(height: ThemeConstants.spacingXLarge),

                    // Continue button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedPlan != null ? _continueToPurchase : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7355),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
                          ),
                        ),
                        child: Text(
                          _selectedPlan == 'annual_trial'
                              ? 'Start Free Trial'
                              : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingMedium),

                    // Terms
                    Text(
                      _selectedPlan == 'annual_trial'
                          ? '7 day free trial. Then \$49.99/year. Cancel anytime.'
                          : 'Subscriptions auto-renew until cancelled.',
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeConstants.textHintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String price;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    this.subtitle,
    required this.price,
    required this.isSelected,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B7355).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B7355) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Recommended',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? const Color(0xFF8B7355) : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A3F35),
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3F35),
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
