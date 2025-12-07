import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/rounded_pill_button.dart';
import '../../../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = ref.read(authServiceProvider);
        await authService.sendPasswordResetEmail(
          _emailController.text.trim(),
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spacingXXL),
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL),
                // Title
                Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  _emailSent
                      ? 'Check your email for password reset instructions'
                      : 'Enter your email address and we\'ll send you a link to reset your password',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingXXL),
                if (!_emailSent) ...[
                  // Reset Form
                  GlassCard(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppConstants.spacingL),
                        // Reset Button
                        RoundedPillButton(
                          text: 'Send Reset Link',
                          onPressed: _handleResetPassword,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Success Message
                  GlassCard(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(height: AppConstants.spacingL),
                        Text(
                          'Email Sent!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                        RoundedPillButton(
                          text: 'Back to Login',
                          onPressed: () => context.go('/login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

