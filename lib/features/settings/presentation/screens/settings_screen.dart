import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/credits_service.dart';
import '../../../../core/services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const SettingsScreen({super.key, this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _credits = 0;
  String? _subscriptionType;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = await CreditsService.getInstance();
    final user = SupabaseService.client.auth.currentUser;

    setState(() {
      _credits = service.getCredits();
      _subscriptionType = service.getSubscriptionType();
      _userEmail = user?.email;
    });
  }

  bool get _hasActiveSubscription =>
      _subscriptionType != null && _subscriptionType!.isNotEmpty;

  String get _subscriptionLabel {
    switch (_subscriptionType) {
      case 'annual_trial':
        return 'Annual (Trial)';
      case 'annual':
        return 'Annual';
      case 'monthly':
        return 'Monthly';
      default:
        return 'None';
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pop();
        widget.onLogout?.call();
      }
    }
  }

  void _showCreditPacksSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingLarge),
              const Text(
                'Buy Credits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3F35),
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: _CreditPackOption(
                      credits: 25,
                      price: '\$2.99',
                      onTap: () async {
                        Navigator.pop(context);
                        // TODO: Integrate with RevenueCat
                        final service = await CreditsService.getInstance();
                        await service.addCredits(CreditsService.smallPackCredits);
                        _loadData();
                      },
                    ),
                  ),
                  const SizedBox(width: ThemeConstants.spacingMedium),
                  Expanded(
                    child: _CreditPackOption(
                      credits: 60,
                      price: '\$5.99',
                      onTap: () async {
                        Navigator.pop(context);
                        // TODO: Integrate with RevenueCat
                        final service = await CreditsService.getInstance();
                        await service.addCredits(CreditsService.mediumPackCredits);
                        _loadData();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF4A3F35),
            ),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF4A3F35),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _SectionHeader(title: 'Account'),
            const SizedBox(height: ThemeConstants.spacingSmall),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Email',
                  trailing: Text(
                    _userEmail ?? 'Not signed in',
                    style: TextStyle(
                      color: ThemeConstants.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.card_membership,
                  title: 'Subscription',
                  trailing: Text(
                    _subscriptionLabel,
                    style: const TextStyle(
                      color: Color(0xFF8B7355),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: ThemeConstants.spacingLarge),

            // Credits Section
            _SectionHeader(title: 'Credits'),
            const SizedBox(height: ThemeConstants.spacingSmall),
            _SettingsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B7355).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.toll,
                          color: Color(0xFF8B7355),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_credits',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A3F35),
                              ),
                            ),
                            Text(
                              'credits remaining',
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeConstants.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_hasActiveSubscription)
                        ElevatedButton(
                          onPressed: _showCreditPacksSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B7355),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Buy More'),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: ThemeConstants.spacingLarge),

            // Support Section
            _SectionHeader(title: 'Support'),
            const SizedBox(height: ThemeConstants.spacingSmall),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    // TODO: Open help center
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.mail_outline,
                  title: 'Contact Us',
                  onTap: () {
                    // TODO: Open contact
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    // TODO: Open terms
                  },
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO: Open privacy policy
                  },
                ),
              ],
            ),

            const SizedBox(height: ThemeConstants.spacingLarge),

            // Danger Zone
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  iconColor: Colors.red,
                  titleColor: Colors.red,
                  onTap: _handleLogout,
                ),
              ],
            ),

            const SizedBox(height: ThemeConstants.spacingXLarge),

            // App version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeConstants.textHintColor,
                ),
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.textSecondaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMedium,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? const Color(0xFF4A3F35),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: titleColor ?? const Color(0xFF4A3F35),
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right,
                color: ThemeConstants.textHintColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _CreditPackOption extends StatelessWidget {
  final int credits;
  final String price;
  final VoidCallback onTap;

  const _CreditPackOption({
    required this.credits,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8B7355).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$credits',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3F35),
              ),
            ),
            const Text(
              'credits',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4A3F35),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B7355),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
