import 'dart:io';
import 'package:dio/dio.dart';
import 'ai_provider.dart';
import 'fitroom_provider.dart';

/// Manages the FitRoom AI provider
class AIProviderManager {
  FitRoomProvider? _provider;

  AIProviderManager();

  /// Initialize the FitRoom provider
  Future<void> initialize({required String fitroomApiKey}) async {
    if (fitroomApiKey.isNotEmpty) {
      _provider = FitRoomProvider(
        dio: Dio(),
        apiKey: fitroomApiKey,
      );
    }
  }

  /// Get the FitRoom provider
  AIProvider get currentProvider {
    if (_provider == null) {
      throw Exception('FitRoom provider not configured');
    }
    return _provider!;
  }

  /// Get the current provider type
  AIProviderType get currentType => AIProviderType.fitroom;

  /// Get all available providers (just FitRoom)
  List<AIProviderType> get availableProviders =>
      _provider != null ? [AIProviderType.fitroom] : [];

  /// Check if provider is available
  bool get isConfigured => _provider != null;

  /// Perform try-on with FitRoom
  Future<TryOnResult> tryOn({
    required File personImage,
    required String garmentImage,
    required String category,
    TryOnProgressCallback? onProgress,
  }) async {
    return currentProvider.tryOn(
      personImage: personImage,
      garmentImage: garmentImage,
      category: category,
      onProgress: onProgress,
    );
  }
}
