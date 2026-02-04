import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../virtual_tryon/presentation/screens/tryon_screen.dart';
import '../../../wardrobe/presentation/screens/wardrobe_screen.dart';
import '../../../browse/presentation/screens/browse_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const HomeScreen({super.key, this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(onLogout: widget.onLogout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ThemeConstants.spacingMedium),
              _buildHeader(context),
              const SizedBox(height: ThemeConstants.spacingXXLarge),
              _buildNavigationCards(context),
              const SizedBox(height: ThemeConstants.spacingXLarge),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ThemeConstants.textSecondaryColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingXSmall),
              Text(
                'Your Wardrobe',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: ThemeConstants.spacingSmall),
              Text(
                'Discover, organize, and try on your perfect style',
                style: TextStyle(
                  fontSize: 15,
                  color: ThemeConstants.textSecondaryColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        // Profile button
        GestureDetector(
          onTap: _openSettings,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF4A3F35),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCards(BuildContext context) {
    return Column(
      children: [
        // AI Fitting Room - Featured card
        _FeatureCard(
          title: 'AI Fitting Room',
          subtitle: 'Try on clothes virtually with AI',
          icon: Icons.auto_awesome,
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () => _navigateTo(context, const TryOnScreen()),
          isLarge: true,
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                title: 'My Wardrobe',
                subtitle: 'Your saved items',
                icon: Icons.checkroom,
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _navigateTo(context, const WardrobeScreen()),
              ),
            ),
            const SizedBox(width: ThemeConstants.spacingMedium),
            Expanded(
              child: _FeatureCard(
                title: 'Browse',
                subtitle: 'Discover styles',
                icon: Icons.explore,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _navigateTo(context, const BrowseScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),
        _QuickActionTile(
          icon: Icons.camera_alt_outlined,
          title: 'New Try-On',
          subtitle: 'Start a virtual fitting session',
          onTap: () => _navigateTo(context, const TryOnScreen()),
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        _QuickActionTile(
          icon: Icons.add_photo_alternate_outlined,
          title: 'Add to Wardrobe',
          subtitle: 'Save a new clothing item',
          onTap: () => _navigateTo(context, const WardrobeScreen()),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isLarge;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 180 : 140,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: isLarge ? 150 : 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(isLarge ? ThemeConstants.spacingLarge : ThemeConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(isLarge ? 10 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isLarge ? 28 : 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLarge ? 22 : 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: isLarge ? 14 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Positioned(
              right: ThemeConstants.spacingMedium,
              bottom: ThemeConstants.spacingMedium,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        decoration: BoxDecoration(
          color: ThemeConstants.surfaceColor,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          border: Border.all(color: ThemeConstants.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeConstants.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: ThemeConstants.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: ThemeConstants.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ThemeConstants.textHintColor,
            ),
          ],
        ),
      ),
    );
  }
}
