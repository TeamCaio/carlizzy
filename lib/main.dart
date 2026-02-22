import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/revenuecat_service.dart';
import 'core/services/supabase_service.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize();
  await RevenueCatService.initialize();
  await initializeDependencies();
  runApp(const MuseApp());
}
