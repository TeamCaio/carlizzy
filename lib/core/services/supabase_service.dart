import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://qargimaraoeybgsytndr.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhcmdpbWFyYW9leWJnc3l0bmRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1MzAxMDIsImV4cCI6MjA4MjEwNjEwMn0.YOH3Wu-oEwDBoORWsO8iJajcfLQYNrQ524GZXp-YWMU';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  /// Get current user ID (null if not authenticated)
  static String? get currentUserId => client.auth.currentUser?.id;

  /// Check if user is authenticated
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Upload file to storage bucket
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    await client.storage.from(bucket).upload(
      path,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Delete file from storage bucket
  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).remove([path]);
  }

  /// Get signed URL for private file
  static Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600,
  }) async {
    return await client.storage.from(bucket).createSignedUrl(path, expiresIn);
  }
}
