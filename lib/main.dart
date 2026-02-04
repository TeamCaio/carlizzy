import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/supabase_service.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await initializeDependencies();
  runApp(const WardrobeApp());
}
