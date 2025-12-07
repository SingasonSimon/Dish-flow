import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Listen to auth state changes
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (mounted) {
          if (user != null) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        }
      });
    });

    // Also check current state immediately
    final authState = ref.read(authStateProvider);
    authState.whenData((user) {
      if (mounted) {
        if (user != null) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(duration: AppConstants.animationSlow)
                .scale(delay: AppConstants.animationMedium),
            const SizedBox(height: AppConstants.spacingXL),
            // App Name
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
            )
                .animate()
                .fadeIn(
                  delay: AppConstants.animationMedium,
                  duration: AppConstants.animationSlow,
                ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Discover & Share Recipes',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 600),
                  duration: AppConstants.animationSlow,
                ),
          ],
        ),
      ),
    );
  }
}

