import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/saved_outfits_service.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Created Outfits'),
            Tab(text: 'My Articles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CreatedOutfitsTab(),
          _MyArticlesTab(),
        ],
      ),
    );
  }
}

class _CreatedOutfitsTab extends StatefulWidget {
  const _CreatedOutfitsTab();

  @override
  State<_CreatedOutfitsTab> createState() => _CreatedOutfitsTabState();
}

class _CreatedOutfitsTabState extends State<_CreatedOutfitsTab> {
  List<SavedOutfit>? _outfits;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    final service = await SavedOutfitsService.getInstance();
    final outfits = await service.getSavedOutfits();
    if (mounted) {
      setState(() {
        _outfits = outfits;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteOutfit(SavedOutfit outfit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Outfit'),
        content: const Text('Are you sure you want to delete this outfit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = await SavedOutfitsService.getInstance();
      await service.deleteOutfit(outfit.id);
      _loadOutfits();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_outfits == null || _outfits!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.collections_outlined,
        title: 'No Created Outfits',
        subtitle: 'Your AI-generated outfits will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOutfits,
      child: GridView.builder(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: ThemeConstants.spacingMedium,
          mainAxisSpacing: ThemeConstants.spacingMedium,
          childAspectRatio: 0.75,
        ),
        itemCount: _outfits!.length,
        itemBuilder: (context, index) {
          final outfit = _outfits![index];
          return _OutfitCard(
            outfit: outfit,
            onTap: () => _showOutfitDetail(outfit),
            onDelete: () => _deleteOutfit(outfit),
          );
        },
      ),
    );
  }

  void _showOutfitDetail(SavedOutfit outfit) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(outfit.imagePath),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
              child: Column(
                children: [
                  if (outfit.description != null)
                    Text(
                      outfit.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  Text(
                    'Created ${_formatDate(outfit.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeConstants.textSecondaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ThemeConstants.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: ThemeConstants.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: ThemeConstants.textSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final SavedOutfit outfit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _OutfitCard({
    required this.outfit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(outfit.imagePath),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyArticlesTab extends StatefulWidget {
  const _MyArticlesTab();

  @override
  State<_MyArticlesTab> createState() => _MyArticlesTabState();
}

class _MyArticlesTabState extends State<_MyArticlesTab> {
  String _selectedCategory = 'all';
  List<SavedArticle>? _articles;
  bool _isLoading = true;
  final _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'label': 'All', 'icon': Icons.grid_view},
    {'id': 'tops', 'label': 'Tops', 'icon': Icons.dry_cleaning},
    {'id': 'bottoms', 'label': 'Bottoms', 'icon': Icons.straighten},
    {'id': 'dresses', 'label': 'Dresses', 'icon': Icons.checkroom},
  ];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final service = await SavedOutfitsService.getInstance();
    final articles = await service.getSavedArticles(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
    );
    if (mounted) {
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    }
  }

  Future<void> _addArticle() async {
    final category = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(ThemeConstants.spacingMedium),
              child: Text(
                'Select Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dry_cleaning),
              title: const Text('Top'),
              onTap: () => Navigator.pop(context, 'tops'),
            ),
            ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Bottom'),
              onTap: () => Navigator.pop(context, 'bottoms'),
            ),
            ListTile(
              leading: const Icon(Icons.checkroom),
              title: const Text('Dress'),
              onTap: () => Navigator.pop(context, 'dresses'),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
          ],
        ),
      ),
    );

    if (category == null || !mounted) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final service = await SavedOutfitsService.getInstance();
      await service.saveArticleFromFile(
        File(pickedFile.path),
        category: category,
      );

      _loadArticles();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save article: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteArticle(SavedArticle article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text('Are you sure you want to delete this article?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = await SavedOutfitsService.getInstance();
      await service.deleteArticle(article.id);
      _loadArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Category filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(category['label'] as String),
                      avatar: Icon(
                        category['icon'] as IconData,
                        size: 18,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category['id'] as String;
                          _isLoading = true;
                        });
                        _loadArticles();
                      },
                    ),
                  );
                },
              ),
            ),
            // Articles grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _articles == null || _articles!.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadArticles,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: ThemeConstants.spacingSmall,
                              mainAxisSpacing: ThemeConstants.spacingSmall,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _articles!.length,
                            itemBuilder: (context, index) {
                              final article = _articles![index];
                              return _ArticleCard(
                                article: article,
                                onTap: () => _showArticleDetail(article),
                                onDelete: () => _deleteArticle(article),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
        // Add button
        Positioned(
          right: ThemeConstants.spacingMedium,
          bottom: ThemeConstants.spacingMedium,
          child: FloatingActionButton(
            onPressed: _addArticle,
            backgroundColor: ThemeConstants.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showArticleDetail(SavedArticle article) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(article.imagePath),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
              child: Column(
                children: [
                  Text(
                    _getCategoryLabel(article.category),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  Text(
                    'Saved ${_formatDate(article.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeConstants.textSecondaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'tops':
        return 'Top';
      case 'bottoms':
        return 'Bottom';
      case 'dresses':
        return 'Dress';
      default:
        return category;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ThemeConstants.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 64,
                color: ThemeConstants.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Text(
              'No Articles Saved',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              'Save individual clothing items to build your virtual wardrobe',
              style: TextStyle(
                fontSize: 15,
                color: ThemeConstants.textSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final SavedArticle article;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ArticleCard({
    required this.article,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
          child: Image.file(
            File(article.imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
