import 'dart:io';

/// Enum representing available AI providers for virtual try-on
enum AIProviderType {
  fitroom,
}

extension AIProviderTypeExtension on AIProviderType {
  String get displayName {
    switch (this) {
      case AIProviderType.fitroom:
        return 'FitRoom';
    }
  }

  String get description {
    switch (this) {
      case AIProviderType.fitroom:
        return 'AI-powered virtual try-on';
    }
  }
}

/// Result of a virtual try-on operation
class TryOnResult {
  final String resultImageUrl;
  final String provider;
  final Duration processingTime;
  final Map<String, dynamic>? metadata;

  const TryOnResult({
    required this.resultImageUrl,
    required this.provider,
    required this.processingTime,
    this.metadata,
  });
}

/// Progress callback for tracking try-on operation progress
typedef TryOnProgressCallback = void Function(double progress, String status);

/// Abstract interface for AI try-on providers
abstract class AIProvider {
  /// The type of this provider
  AIProviderType get type;

  /// Whether this provider is currently configured and ready to use
  Future<bool> isConfigured();

  /// Perform a virtual try-on operation
  Future<TryOnResult> tryOn({
    required File personImage,
    required String garmentImage,
    required String category,
    TryOnProgressCallback? onProgress,
  });

  /// Validate that the provider can handle the given inputs
  Future<void> validateInputs({
    required File personImage,
    required String garmentImage,
  });
}
