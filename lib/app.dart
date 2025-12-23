import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/theme_constants.dart';
import 'features/virtual_tryon/presentation/bloc/tryon_bloc.dart';
import 'features/virtual_tryon/presentation/screens/tryon_screen.dart';
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
        home: const TryOnScreen(),
      ),
    );
  }
}
