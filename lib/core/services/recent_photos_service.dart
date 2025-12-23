import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentPhotosService {
  static const String _key = 'recent_model_photos';
  static const int _maxPhotos = 4;

  /// Get the list of recently used model photos
  static Future<List<String>> getRecentPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    try {
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.cast<String>();
    } catch (_) {
      return [];
    }
  }

  /// Add a photo to recent history
  static Future<void> addPhoto(String photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    final photos = await getRecentPhotos();

    // Remove if already exists (to move to front)
    photos.remove(photoPath);

    // Add to front
    photos.insert(0, photoPath);

    // Keep only max photos
    final trimmed = photos.take(_maxPhotos).toList();

    await prefs.setString(_key, json.encode(trimmed));
  }

  /// Clear all recent photos
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
