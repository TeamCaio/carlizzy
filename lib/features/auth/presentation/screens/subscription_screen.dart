import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/credits_service.dart';
import '../../../../core/services/revenuecat_service.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SubscriptionScreen({super.key, required this.onComplete});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Automatically show paywall on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPaywall();
    });
  }

  Future<void> _showPaywall() async {
    final result = await RevenueCatService.presentPaywall();

    if (result == PaywallResult.purchased || result == PaywallResult.restored) {
      // User subscribed - update local state
      final creditsService = await CreditsService.getInstance();

      // Check which plan they purchased
      final hasSubscription = await RevenueCatService.hasActiveSubscription();
      if (hasSubscription) {
        await creditsService.setSubscriptionType('pro');
        // Credits will be managed by RevenueCat entitlements
      }

      widget.onComplete();
    } else if (result == PaywallResult.cancelled || result == PaywallResult.error) {
      // User cancelled or error - show manual selection
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _skipSubscription() async {
    // Allow users to continue without subscribing (limited features)
    widget.onComplete();
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final customerInfo = await RevenueCatService.restorePurchases();

      if (customerInfo != null &&
          customerInfo.entitlements.active.containsKey(RevenueCatService.entitlementPro)) {
        final creditsService = await CreditsService.getInstance();
        await creditsService.setSubscriptionType('pro');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
        widget.onComplete();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No purchases to restore'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B7355)))
            : Padding(
                padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B7355), Color(0xFFB8956E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B7355).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingLarge),
                    // Title
                    const Text(
                      'Unlock Muse',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3F35),
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingSmall),
                    Text(
                      'Virtual try-on powered by AI',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeConstants.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingXLarge),
                    // Features list
                    _FeatureItem(icon: Icons.checkroom, text: 'Unlimited virtual try-ons'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.cloud_sync, text: 'Sync across devices'),
                    const SizedBox(height: 12),
                    _FeatureItem(icon: Icons.auto_awesome, text: 'AI-powered styling'),
                    const Spacer(flex: 2),
                    // Subscribe button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _showPaywall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7355),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View Plans',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingMedium),
                    // Restore purchases
                    TextButton(
                      onPressed: _restorePurchases,
                      child: const Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: Color(0xFF8B7355),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Skip option
                    TextButton(
                      onPressed: _skipSubscription,
                      child: Text(
                        'Continue with limited features',
                        style: TextStyle(
                          color: ThemeConstants.textHintColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingMedium),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B7355).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF8B7355), size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4A3F35),
          ),
        ),
      ],
    );
  }
}
