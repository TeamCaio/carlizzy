import 'package:equatable/equatable.dart';
import '../../../../core/ai_providers/ai_provider.dart';
import '../../domain/entities/tryon_result.dart';
import '../../domain/entities/user_image.dart';

abstract class TryonState extends Equatable {
  const TryonState();

  @override
  List<Object?> get props => [];
}

/// Initial state - nothing selected
class TryonInitial extends TryonState {
  final AIProviderType selectedProvider;
  final List<AIProviderType> availableProviders;

  const TryonInitial({
    this.selectedProvider = AIProviderType.fitroom,
    this.availableProviders = const [],
  });

  @override
  List<Object?> get props => [selectedProvider, availableProviders];
}

/// Ready state - all inputs selected, ready to try on
class TryonReadyState extends TryonState {
  final UserImage personImage;
  final bool isPersonUrl;
  final String clothingImage; // Can be file path or URL
  final bool isClothingUrl;
  final String category;
  final AIProviderType selectedProvider;
  final List<AIProviderType> availableProviders;

  const TryonReadyState({
    required this.personImage,
    this.isPersonUrl = false,
    required this.clothingImage,
    required this.isClothingUrl,
    required this.category,
    required this.selectedProvider,
    required this.availableProviders,
  });

  TryonReadyState copyWith({
    UserImage? personImage,
    bool? isPersonUrl,
    String? clothingImage,
    bool? isClothingUrl,
    String? category,
    AIProviderType? selectedProvider,
    List<AIProviderType>? availableProviders,
  }) {
    return TryonReadyState(
      personImage: personImage ?? this.personImage,
      isPersonUrl: isPersonUrl ?? this.isPersonUrl,
      clothingImage: clothingImage ?? this.clothingImage,
      isClothingUrl: isClothingUrl ?? this.isClothingUrl,
      category: category ?? this.category,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      availableProviders: availableProviders ?? this.availableProviders,
    );
  }

  @override
  List<Object?> get props => [
        personImage,
        isPersonUrl,
        clothingImage,
        isClothingUrl,
        category,
        selectedProvider,
        availableProviders,
      ];
}

/// Person photo selected, waiting for clothing
class PersonSelectedState extends TryonState {
  final UserImage personImage;
  final bool isPersonUrl;
  final AIProviderType selectedProvider;
  final List<AIProviderType> availableProviders;

  const PersonSelectedState({
    required this.personImage,
    this.isPersonUrl = false,
    required this.selectedProvider,
    required this.availableProviders,
  });

  @override
  List<Object?> get props => [personImage, isPersonUrl, selectedProvider, availableProviders];
}

/// Processing the virtual try-on
class ProcessingTryOnState extends TryonState {
  final UserImage personImage;
  final String clothingImage;
  final double progress;
  final String statusMessage;
  final AIProviderType provider;

  const ProcessingTryOnState({
    required this.personImage,
    required this.clothingImage,
    required this.progress,
    required this.statusMessage,
    required this.provider,
  });

  ProcessingTryOnState copyWith({
    double? progress,
    String? statusMessage,
  }) {
    return ProcessingTryOnState(
      personImage: personImage,
      clothingImage: clothingImage,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      provider: provider,
    );
  }

  @override
  List<Object?> get props => [
        personImage,
        clothingImage,
        progress,
        statusMessage,
        provider,
      ];
}

/// Try-on succeeded
class TryonSuccessState extends TryonState {
  final TryonResult result;
  final UserImage personImage;
  final String clothingImage;
  final AIProviderType usedProvider;

  const TryonSuccessState({
    required this.result,
    required this.personImage,
    required this.clothingImage,
    required this.usedProvider,
  });

  @override
  List<Object?> get props => [result, personImage, clothingImage, usedProvider];
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
