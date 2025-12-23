import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/ai_providers/ai_provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../bloc/tryon_bloc.dart';
import '../bloc/tryon_event.dart';
import '../bloc/tryon_state.dart';
import '../widgets/ai_provider_selector.dart';
import '../widgets/recent_photos_gallery.dart';
import '../widgets/sample_gallery.dart';
import '../widgets/category_selector.dart';

class TryOnScreen extends StatelessWidget {
  const TryOnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<TryonBloc, TryonState>(
          listener: (context, state) {
            if (state is TryonErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ThemeConstants.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TryonState state) {
    if (state is ProcessingTryOnState) {
      return _ProcessingView(state: state);
    }

    if (state is TryonSuccessState) {
      return _ResultView(state: state);
    }

    return _MainView(state: state);
  }
}

class _MainView extends StatefulWidget {
  final TryonState state;

  const _MainView({required this.state});

  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedCategory = 'upper_body';

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPersonImage = widget.state is PersonSelectedState ||
        widget.state is TryonReadyState;
    final hasClothingImage = widget.state is TryonReadyState;

    String? personImagePath;
    bool isPersonUrl = false;
    String? clothingImage;
    bool isClothingUrl = false;
    AIProviderType selectedProvider = AIProviderType.fitroom;
    List<AIProviderType> availableProviders = [];

    if (widget.state is TryonInitial) {
      selectedProvider = (widget.state as TryonInitial).selectedProvider;
      availableProviders = (widget.state as TryonInitial).availableProviders;
    } else if (widget.state is PersonSelectedState) {
      final s = widget.state as PersonSelectedState;
      personImagePath = s.personImage.path;
      isPersonUrl = s.isPersonUrl;
      selectedProvider = s.selectedProvider;
      availableProviders = s.availableProviders;
    } else if (widget.state is TryonReadyState) {
      final s = widget.state as TryonReadyState;
      personImagePath = s.personImage.path;
      isPersonUrl = s.isPersonUrl;
      clothingImage = s.clothingImage;
      isClothingUrl = s.isClothingUrl;
      selectedProvider = s.selectedProvider;
      availableProviders = s.availableProviders;
      _selectedCategory = s.category;
    }

    return Column(
      children: [
        // Header
        _Header(
          selectedProvider: selectedProvider,
          availableProviders: availableProviders,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image selection row
                Row(
                  children: [
                    // Person image
                    Expanded(
                      child: _ImageCard(
                        label: 'Your Photo',
                        imagePath: personImagePath,
                        isUrl: isPersonUrl,
                        icon: Icons.person_outline,
                        onTap: () => _showPersonImagePicker(context),
                        onClear: hasPersonImage
                            ? () => context.read<TryonBloc>().add(const ResetTryonEvent())
                            : null,
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.spacingMedium),
                    // Clothing image
                    Expanded(
                      child: _ImageCard(
                        label: 'Clothing',
                        imagePath: clothingImage,
                        isUrl: isClothingUrl,
                        icon: Icons.checkroom_outlined,
                        onTap: hasPersonImage
                            ? () => _showClothingOptions(context)
                            : null,
                        onClear: hasClothingImage
                            ? () => context.read<TryonBloc>().add(const ClearClothingEvent())
                            : null,
                        disabled: !hasPersonImage,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ThemeConstants.spacingLarge),

                // Category selector
                if (hasPersonImage) ...[
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: ThemeConstants.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  CategorySelector(
                    selected: _selectedCategory,
                    onChanged: (category) {
                      setState(() => _selectedCategory = category);
                      context.read<TryonBloc>().add(SetCategoryEvent(category));
                    },
                  ),
                ],

                const SizedBox(height: ThemeConstants.spacingXLarge),

                // Try on button
                if (hasClothingImage)
                  _TryOnButton(
                    onPressed: () {
                      context.read<TryonBloc>().add(const StartTryOnEvent());
                    },
                    provider: selectedProvider,
                  ),

                // Instructions
                if (!hasPersonImage) ...[
                  const SizedBox(height: ThemeConstants.spacingXLarge),
                  _InstructionsCard(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPersonImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PersonImagePickerSheet(
        onCameraTap: () {
          Navigator.pop(context);
          context.read<TryonBloc>().add(
                const SelectPersonPhotoEvent(ImageSource.camera),
              );
        },
        onGalleryTap: () {
          Navigator.pop(context);
          context.read<TryonBloc>().add(
                const SelectPersonPhotoEvent(ImageSource.gallery),
              );
        },
        onRecentSelected: (path) {
          Navigator.pop(context);
          context.read<TryonBloc>().add(SetPersonImagePathEvent(path));
        },
      ),
    );
  }

  void _showClothingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ClothingOptionsSheet(
        urlController: _urlController,
        onCameraTap: () {
          Navigator.pop(context);
          context.read<TryonBloc>().add(
                const SelectClothingImageEvent(ImageSource.camera),
              );
        },
        onGalleryTap: () {
          Navigator.pop(context);
          context.read<TryonBloc>().add(
                const SelectClothingImageEvent(ImageSource.gallery),
              );
        },
        onUrlSubmit: (url) {
          Navigator.pop(context);
          context.read<TryonBloc>().add(SetClothingUrlEvent(url));
        },
        onSampleSelected: (url) {
          Navigator.pop(context);
          context.read<TryonBloc>().add(SetClothingUrlEvent(url));
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AIProviderType selectedProvider;
  final List<AIProviderType> availableProviders;

  const _Header({
    required this.selectedProvider,
    required this.availableProviders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Virtual Try-On',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                'See how clothes look on you',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          AIProviderSelector(
            selected: selectedProvider,
            available: availableProviders,
            onChanged: (provider) {
              context.read<TryonBloc>().add(ChangeProviderEvent(provider));
            },
          ),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final bool isUrl;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool disabled;

  const _ImageCard({
    required this.label,
    required this.imagePath,
    required this.isUrl,
    required this.icon,
    required this.onTap,
    this.onClear,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: disabled
                    ? ThemeConstants.textHintColor
                    : ThemeConstants.textSecondaryColor,
              ),
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        GestureDetector(
          onTap: disabled ? null : onTap,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: disabled
                  ? ThemeConstants.backgroundColor
                  : ThemeConstants.surfaceColor,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
              border: Border.all(
                color: hasImage
                    ? ThemeConstants.primaryColor.withOpacity(0.3)
                    : ThemeConstants.borderColor,
                width: hasImage ? 2 : 1,
              ),
              boxShadow: hasImage ? ThemeConstants.shadowSmall : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  isUrl
                      ? CachedNetworkImage(
                          imageUrl: imagePath!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) => _EmptyContent(
                            icon: Icons.broken_image_outlined,
                            label: 'Failed to load',
                            disabled: disabled,
                          ),
                        )
                      : Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                        )
                else
                  _EmptyContent(
                    icon: icon,
                    label: disabled ? 'Select photo first' : 'Tap to select',
                    disabled: disabled,
                  ),
                if (hasImage && onClear != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool disabled;

  const _EmptyContent({
    required this.icon,
    required this.label,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: disabled
                ? ThemeConstants.textHintColor.withOpacity(0.5)
                : ThemeConstants.textHintColor,
          ),
          const SizedBox(height: ThemeConstants.spacingSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: disabled
                      ? ThemeConstants.textHintColor.withOpacity(0.5)
                      : ThemeConstants.textHintColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _TryOnButton extends StatelessWidget {
  final VoidCallback onPressed;
  final AIProviderType provider;

  const _TryOnButton({
    required this.onPressed,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        gradient: LinearGradient(
          colors: [
            ThemeConstants.primaryColor,
            ThemeConstants.accentColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 20),
            const SizedBox(width: ThemeConstants.spacingSmall),
            Text(
              'Try On with ${provider.displayName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: ThemeConstants.surfaceColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        border: Border.all(color: ThemeConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 20,
                color: ThemeConstants.highlightColor,
              ),
              const SizedBox(width: ThemeConstants.spacingSmall),
              Text(
                'How it works',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          _InstructionStep(
            number: '1',
            text: 'Upload a photo of yourself',
          ),
          _InstructionStep(
            number: '2',
            text: 'Select or upload clothing to try on',
          ),
          _InstructionStep(
            number: '3',
            text: 'AI generates you wearing the outfit',
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeConstants.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: ThemeConstants.spacingSmall),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonImagePickerSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final ValueChanged<String> onRecentSelected;

  const _PersonImagePickerSheet({
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onRecentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeConstants.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: ThemeConstants.spacingLarge),
          Text(
            'Select Your Photo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: ThemeConstants.spacingLarge),
          Row(
            children: [
              Expanded(
                child: _OptionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: onCameraTap,
                ),
              ),
              const SizedBox(width: ThemeConstants.spacingMedium),
              Expanded(
                child: _OptionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: onGalleryTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingLarge),
          RecentPhotosGallery(
            onPhotoSelected: onRecentSelected,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
        ],
      ),
    );
  }
}

class _ClothingOptionsSheet extends StatelessWidget {
  final TextEditingController urlController;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final ValueChanged<String> onUrlSubmit;
  final ValueChanged<String> onSampleSelected;

  const _ClothingOptionsSheet({
    required this.urlController,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onUrlSubmit,
    required this.onSampleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeConstants.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Text(
              'Add Clothing',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Row(
              children: [
                Expanded(
                  child: _OptionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: onCameraTap,
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacingMedium),
                Expanded(
                  child: _OptionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: onGalleryTap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingMedium,
                  ),
                  child: Text(
                    'or choose a sample',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            SampleClothingGallery(
              onImageSelected: onSampleSelected,
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingMedium,
                  ),
                  child: Text(
                    'or paste URL',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/clothing.jpg',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  onUrlSubmit(value);
                }
              },
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            ElevatedButton(
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  onUrlSubmit(urlController.text);
                }
              },
              child: const Text('Use URL'),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: ThemeConstants.spacingSmall),
          Text(label),
        ],
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  final ProcessingTryOnState state;

  const _ProcessingView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 4,
                    backgroundColor: ThemeConstants.borderColor,
                    valueColor: AlwaysStoppedAnimation(ThemeConstants.primaryColor),
                  ),
                ),
                Text(
                  '${(state.progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThemeConstants.spacingXLarge),
          Text(
            state.statusMessage,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.spacingSmall),
          Text(
            'Using ${state.provider.displayName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(flex: 2),
          Text(
            'This may take up to 30 seconds',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ThemeConstants.textHintColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final TryonSuccessState state;

  const _ResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Result',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Generated with ${state.usedProvider.displayName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  context.read<TryonBloc>().add(const ResetTryonEvent());
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),

        // Result image
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingMedium,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
              child: CachedNetworkImage(
                imageUrl: state.result.resultImageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            ),
          ),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<TryonBloc>().add(const ClearClothingEvent());
                  },
                  icon: const Icon(Icons.checkroom_outlined),
                  label: const Text('Try Different'),
                ),
              ),
              const SizedBox(width: ThemeConstants.spacingMedium),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<TryonBloc>().add(const ResetTryonEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Start Over'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
