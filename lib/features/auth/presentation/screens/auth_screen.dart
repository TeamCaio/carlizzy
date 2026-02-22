import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/credits_service.dart';
import '../../../../core/services/supabase_service.dart';
import 'subscription_screen.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Could not find ID Token from Apple Sign In');
      }

      await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (mounted) {
        await _navigateToSubscription();
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        setState(() => _errorMessage = 'Apple Sign In failed: ${e.message}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Sign in failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToSubscription() async {
    // Check if user already has a subscription
    final creditsService = await CreditsService.getInstance();
    final subscriptionType = creditsService.getSubscriptionType();

    if (subscriptionType != null && subscriptionType.isNotEmpty) {
      // User already has a subscription, skip to home
      widget.onAuthSuccess();
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SubscriptionScreen(
          onComplete: widget.onAuthSuccess,
        ),
      ),
    );
  }

  Future<void> _continueWithoutAccount() async {
    await _navigateToSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.checkroom,
                  size: 50,
                  color: ThemeConstants.primaryColor,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingLarge),
              // Title
              Text(
                'Welcome to Muse',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConstants.spacingSmall),
              Text(
                'Sign in to sync your outfits across devices',
                style: TextStyle(
                  fontSize: 16,
                  color: ThemeConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacingMedium),
              ],
              // Sign in buttons
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                // Apple Sign In
                if (Platform.isIOS)
                  _SignInButton(
                    onPressed: _signInWithApple,
                    icon: Icons.apple,
                    label: 'Continue with Apple',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                if (Platform.isIOS)
                  const SizedBox(height: ThemeConstants.spacingLarge),
                // Skip button
                TextButton(
                  onPressed: _continueWithoutAccount,
                  child: Text(
                    'Continue without an account',
                    style: TextStyle(
                      color: ThemeConstants.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Terms
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeConstants.textHintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SignInButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
