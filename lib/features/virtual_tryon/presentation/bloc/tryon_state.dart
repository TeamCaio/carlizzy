import 'package:equatable/equatable.dart';
import '../../../../core/ai_providers/ai_provider.dart';
import '../../domain/entities/tryon_result.dart';
import '../../domain/entities/user_image.dart';

/// Represents a selected clothing item
class ClothingSelection extends Equatable {
  final String imagePath; // Can be file path or URL
  final bool isUrl;

  const ClothingSelection({
    required this.imagePath,
    required this.isUrl,
  });

  @override
  List<Object?> get props => [imagePath, isUrl];
}

abstract class TryonState extends Equatable {
  const TryonState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no person selected (but may have clothing)
class TryonInitial extends TryonState {
  final AIProviderType selectedProvider;
  final List<AIProviderType> availableProviders;
  final int credits;
  final Map<String, ClothingSelection> clothingItems;

  const TryonInitial({
    this.selectedProvider = AIProviderType.fitroom,
    this.availableProviders = const [],
    this.credits = 0,
    this.clothingItems = const {},
  });

  @override
  List<Object?> get props => [selectedProvider, availableProviders, credits, clothingItems];
}

/// Ready state - all inputs selected, ready to try on
class TryonReadyState extends TryonState {
  final UserImage personImage;
  final bool isPersonUrl;
  /// Map of category -> clothing selection (supports multiple items)
  final Map<String, ClothingSelection> clothingItems;
  final AIProviderType selectedProvider;
  final List<AIProviderType> availableProviders;
  final int credits;

  const TryonReadyState({
    required this.personImage,
    this.isPersonUrl = false,
    this.clothingItems = const {},
    required this.selectedProvider,
    required this.availableProviders,
    this.credits = 0,
  });

  /// Check if any clothing is selected
  bool get hasClothing => clothingItems.isNotEmpty;

  /// Get count of selected clothing items
  int get clothingCount => clothingItems.length;

  /// Get clothing for a specific category
  ClothingSelection? getClothingForCategory(String category) =>
      clothingItems[category];

  /// For backwards compatibility - get first clothing item
  String? get clothingImage =>
      clothingItems.isNotEmpty ? clothingItems.values.first.imagePath : null;

  bool get isClothingUrl =>
      clothingItems.isNotEmpty ? clothingItems.values.first.isUrl : false;

  String get category =>
      clothingItems.isNotEmpty ? clothingItems.keys.first : 'upper_body';

  TryonReadyState copyWith({
    UserImage? personImage,
    bool? isPersonUrl,
    Map<String, ClothingSelection>? clothingItems,
    AIProviderType? selectedProvider,
    List<AIProviderType>? availableProviders,
    int? credits,
  }) {
    return TryonReadyState(
      personImage: personImage ?? this.personImage,
      isPersonUrl: isPersonUrl ?? this.isPersonUrl,
      clothingItems: clothingItems ?? this.clothingItems,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      availableProviders: availableProviders ?? this.availableProviders,
      credits: credits ?? this.credits,
    );
  }

  /// Add or update clothing for a category
  TryonReadyState withClothing(
      String category, String imagePath, bool isUrl) {
    final newItems = Map<String, ClothingSelection>.from(clothingItems);
    newItems[category] = ClothingSelection(imagePath: imagePath, isUrl: isUrl);
    return copyWith(clothingItems: newItems);
  }

  /// Remove clothing for a category
  TryonReadyState withoutClothing(String category) {
    final newItems = Map<String, ClothingSelection>.from(clothingItems);
    newItems.remove(category);
    return copyWith(clothingItems: newItems);
  }

  @override
  List<Object?> get props => [
        personImage,
        isPersonUrl,
        clothingItems,
        selectedProvider,
        availableProviders,
        credits,
      ];
}

/// Person photo selected, waiting for clothing
class PersonSelectedState extends TryonState {
  final UserImage personImage;
  final bool isPersonUrl;
  final AIProviderType selectedProvider;
  final List<AIProviderType> availableProviders;
  final int credits;

  const PersonSelectedState({
    required this.personImage,
    this.isPersonUrl = false,
    required this.selectedProvider,
    required this.availableProviders,
    this.credits = 0,
  });

  @override
  List<Object?> get props => [personImage, isPersonUrl, selectedProvider, availableProviders, credits];
}

/// Processing the virtual try-on
class ProcessingTryOnState extends TryonState {
  final UserImage personImage;
  final Map<String, ClothingSelection> clothingItems;
  final double progress;
  final String statusMessage;
  final AIProviderType provider;
  /// Current step in multi-garment generation (1-based)
  final int currentStep;
  /// Total steps for multi-garment generation
  final int totalSteps;
  /// Current category being processed
  final String? currentCategory;

  const ProcessingTryOnState({
    required this.personImage,
    required this.clothingItems,
    required this.progress,
    required this.statusMessage,
    required this.provider,
    this.currentStep = 1,
    this.totalSteps = 1,
    this.currentCategory,
  });

  /// Overall progress across all steps
  double get overallProgress {
    if (totalSteps <= 1) return progress;
    final stepProgress = (currentStep - 1) / totalSteps;
    final currentStepContribution = progress / totalSteps;
    return stepProgress + currentStepContribution;
  }

  ProcessingTryOnState copyWith({
    double? progress,
    String? statusMessage,
    int? currentStep,
    int? totalSteps,
    String? currentCategory,
  }) {
    return ProcessingTryOnState(
      personImage: personImage,
      clothingItems: clothingItems,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      provider: provider,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }

  @override
  List<Object?> get props => [
        personImage,
        clothingItems,
        progress,
        statusMessage,
        provider,
        currentStep,
        totalSteps,
        currentCategory,
      ];
}

/// Try-on succeeded
class TryonSuccessState extends TryonState {
  final TryonResult result;
  final UserImage personImage;
  final Map<String, ClothingSelection> clothingItems;
  final AIProviderType usedProvider;
  /// Number of items that were processed
  final int itemsProcessed;

  const TryonSuccessState({
    required this.result,
    required this.personImage,
    required this.clothingItems,
    required this.usedProvider,
    this.itemsProcessed = 1,
  });

  @override
  List<Object?> get props => [result, personImage, clothingItems, usedProvider, itemsProcessed];
}

/// Error occurred
class TryonErrorState extends TryonState {
  final String message;
  final bool canRetry;
  final AIProviderType? lastProvider;

  const TryonErrorState({
    required this.message,
    this.canRetry = true,
    this.lastProvider,
  });

  @override
  List<Object?> get props => [message, canRetry, lastProvider];
}
