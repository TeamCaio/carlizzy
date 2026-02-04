import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search functionality
            },
          ),
        ],
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          _buildCategoryGrid(),
          const SizedBox(height: ThemeConstants.spacingXLarge),
          Text(
            'Coming Soon',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          _buildComingSoonCard(context),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      _CategoryItem('Tops', Icons.dry_cleaning, const Color(0xFF667EEA)),
      _CategoryItem('Bottoms', Icons.accessibility_new, const Color(0xFF11998E)),
      _CategoryItem('Dresses', Icons.woman, const Color(0xFFFC466B)),
      _CategoryItem('Outerwear', Icons.checkroom, const Color(0xFF764BA2)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: ThemeConstants.spacingMedium,
        crossAxisSpacing: ThemeConstants.spacingMedium,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(category: category);
      },
    );
  }

  Widget _buildComingSoonCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConstants.primaryColor.withOpacity(0.05),
            ThemeConstants.highlightColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        border: Border.all(color: ThemeConstants.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 48,
            color: ThemeConstants.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          Text(
            'Store Integration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: ThemeConstants.spacingSmall),
          Text(
            'Browse and try on clothes from your favorite stores directly in the app',
            style: TextStyle(
              fontSize: 14,
              color: ThemeConstants.textSecondaryColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  _CategoryItem(this.name, this.icon, this.color);
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category
      },
      child: Container(
        decoration: BoxDecoration(
          color: ThemeConstants.surfaceColor,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          border: Border.all(color: ThemeConstants.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 28,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ThemeConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
