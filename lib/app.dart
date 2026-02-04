import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/theme_constants.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/virtual_tryon/presentation/bloc/tryon_bloc.dart';
import 'injection_container.dart';

class WardrobeApp extends StatelessWidget {
  const WardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for modern look
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ThemeConstants.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return BlocProvider(
      create: (context) => sl<TryonBloc>(),
      child: MaterialApp(
        title: 'Virtual Wardrobe',
        debugShowCheckedModeBanner: false,
        theme: ThemeConstants.lightTheme,
        home: const _AuthWrapper(),
      ),
    );
  }
}

class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  static const String _hasSeenAuthKey = 'has_seen_auth';
  bool _isLoading = true;
  bool _showAuth = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenAuth = prefs.getBool(_hasSeenAuthKey) ?? false;

    // Show auth screen if user hasn't seen it and isn't logged in
    if (!hasSeenAuth && !SupabaseService.isAuthenticated) {
      setState(() {
        _showAuth = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _showAuth = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _onAuthComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenAuthKey, true);
    if (mounted) {
      setState(() => _showAuth = false);
    }
  }

  void _onLogout() {
    if (mounted) {
      setState(() => _showAuth = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showAuth) {
      return AuthScreen(onAuthSuccess: _onAuthComplete);
    }

    return HomeScreen(onLogout: _onLogout);
  }
}
