import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/sample_images.dart';
import '../../../../core/constants/theme_constants.dart';

class SamplePeopleGallery extends StatelessWidget {
  final ValueChanged<String> onImageSelected;

  const SamplePeopleGallery({
    super.key,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingMedium,
          ),
          child: Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 18,
                color: ThemeConstants.textSecondaryColor,
              ),
              const SizedBox(width: ThemeConstants.spacingSmall),
              Text(
                'Sample Photos',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ThemeConstants.textSecondaryColor,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingMedium,
            ),
            itemCount: SampleImages.people.length,
            itemBuilder: (context, index) {
              final sample = SampleImages.people[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < SampleImages.people.length - 1
                      ? ThemeConstants.spacingSmall
                      : 0,
                ),
                child: _SampleImageTile(
                  imageUrl: sample.url,
                  label: sample.label,
                  onTap: () => onImageSelected(sample.url),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SampleClothingGallery extends StatelessWidget {
  final ValueChanged<String> onImageSelected;
  final String? categoryFilter;

  const SampleClothingGallery({
    super.key,
    required this.onImageSelected,
    this.categoryFilter,
  });

  @override
  Widget build(BuildContext context) {
    final filteredItems = categoryFilter != null
        ? SampleImages.clothing
            .where((item) => item.category == categoryFilter)
            .toList()
        : SampleImages.clothing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingMedium,
          ),
          child: Row(
            children: [
              Icon(
                Icons.checkroom_outlined,
                size: 18,
                color: ThemeConstants.textSecondaryColor,
              ),
              const SizedBox(width: ThemeConstants.spacingSmall),
              Text(
                'Sample Clothing',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ThemeConstants.textSecondaryColor,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingMedium,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final sample = filteredItems[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < filteredItems.length - 1
                      ? ThemeConstants.spacingSmall
                      : 0,
                ),
                child: _SampleImageTile(
                  imageUrl: sample.url,
                  label: sample.label,
                  onTap: () => onImageSelected(sample.url),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SampleImageTile extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;

  const _SampleImageTile({
    required this.imageUrl,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
          border: Border.all(color: ThemeConstants.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: ThemeConstants.backgroundColor,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: ThemeConstants.backgroundColor,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: ThemeConstants.textHintColor,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen gallery for browsing all samples
class SampleGallerySheet extends StatefulWidget {
  final bool isPeopleGallery;
  final ValueChanged<String> onImageSelected;

  const SampleGallerySheet({
    super.key,
    required this.isPeopleGallery,
    required this.onImageSelected,
  });

  @override
  State<SampleGallerySheet> createState() => _SampleGallerySheetState();
}

class _SampleGallerySheetState extends State<SampleGallerySheet> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final items = widget.isPeopleGallery
        ? SampleImages.people
        : _getFilteredClothing();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ThemeConstants.radiusXLarge),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ThemeConstants.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingMedium),
                    Row(
                      children: [
                        Icon(
                          widget.isPeopleGallery
                              ? Icons.people_outline
                              : Icons.checkroom_outlined,
                          color: ThemeConstants.primaryColor,
                        ),
                        const SizedBox(width: ThemeConstants.spacingSmall),
                        Text(
                          widget.isPeopleGallery
                              ? 'Choose a Person'
                              : 'Choose Clothing',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Category filter for clothing
              if (!widget.isPeopleGallery) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingMedium,
                  ),
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'All',
                        isSelected: _selectedCategory == 'all',
                        onTap: () => setState(() => _selectedCategory = 'all'),
                      ),
                      _CategoryChip(
                        label: 'Tops',
                        isSelected: _selectedCategory == 'upper_body',
                        onTap: () =>
                            setState(() => _selectedCategory = 'upper_body'),
                      ),
                      _CategoryChip(
                        label: 'Bottoms',
                        isSelected: _selectedCategory == 'lower_body',
                        onTap: () =>
                            setState(() => _selectedCategory = 'lower_body'),
                      ),
                      _CategoryChip(
                        label: 'Dresses',
                        isSelected: _selectedCategory == 'dresses',
                        onTap: () =>
                            setState(() => _selectedCategory = 'dresses'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacingMedium),
              ],

              // Grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: ThemeConstants.spacingSmall,
                    mainAxisSpacing: ThemeConstants.spacingSmall,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _GalleryGridItem(
                      imageUrl: item.url,
                      label: item.label,
                      onTap: () {
                        widget.onImageSelected(item.url);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<SampleImage> _getFilteredClothing() {
    if (_selectedCategory == 'all') {
      return SampleImages.clothing;
    }
    return SampleImages.clothing
        .where((item) => item.category == _selectedCategory)
        .toList();
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: ThemeConstants.spacingSmall),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingMedium,
            vertical: ThemeConstants.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeConstants.primaryColor
                : ThemeConstants.backgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusRound),
            border: Border.all(
              color: isSelected
                  ? ThemeConstants.primaryColor
                  : ThemeConstants.borderColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : ThemeConstants.textPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryGridItem extends StatelessWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;

  const _GalleryGridItem({
    required this.imageUrl,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          border: Border.all(color: ThemeConstants.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: ThemeConstants.backgroundColor,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: ThemeConstants.backgroundColor,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: ThemeConstants.textHintColor,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
