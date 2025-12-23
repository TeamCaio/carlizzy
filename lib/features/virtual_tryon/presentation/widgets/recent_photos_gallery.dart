import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/recent_photos_service.dart';

class RecentPhotosGallery extends StatefulWidget {
  final ValueChanged<String> onPhotoSelected;

  const RecentPhotosGallery({
    super.key,
    required this.onPhotoSelected,
  });

  @override
  State<RecentPhotosGallery> createState() => _RecentPhotosGalleryState();
}

class _RecentPhotosGalleryState extends State<RecentPhotosGallery> {
  List<String> _recentPhotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentPhotos();
  }

  Future<void> _loadRecentPhotos() async {
    final photos = await RecentPhotosService.getRecentPhotos();
    setState(() {
      _recentPhotos = photos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_recentPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              size: 18,
              color: ThemeConstants.textSecondaryColor,
            ),
            const SizedBox(width: ThemeConstants.spacingSmall),
            Text(
              'Recent Photos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ThemeConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentPhotos.length,
            itemBuilder: (context, index) {
              final photoPath = _recentPhotos[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _recentPhotos.length - 1
                      ? ThemeConstants.spacingSmall
                      : 0,
                ),
                child: _RecentPhotoTile(
                  photoPath: photoPath,
                  onTap: () => widget.onPhotoSelected(photoPath),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentPhotoTile extends StatelessWidget {
  final String photoPath;
  final VoidCallback onTap;

  const _RecentPhotoTile({
    required this.photoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(photoPath);
    final exists = file.existsSync();

    return GestureDetector(
      onTap: exists ? onTap : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
          border: Border.all(color: ThemeConstants.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: exists
            ? Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: ThemeConstants.backgroundColor,
      child: Icon(
        Icons.broken_image_outlined,
        color: ThemeConstants.textHintColor,
      ),
    );
  }
}
