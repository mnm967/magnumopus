import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/utils/logger.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';

/// Provider to manage forgot password state
final forgotPasswordStateProvider = StateProvider.autoDispose<AsyncValue<bool>>((ref) {
  return const AsyncValue.data(false);
});

/// Screen for password reset
class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final forgotPasswordState = ref.watch(forgotPasswordStateProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Reset password form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: forgotPasswordState.value == true
                    ? _buildSuccessContent(context)
                    : _buildResetForm(context, ref, emailController, forgotPasswordState),
              ).animate().fadeIn(duration: 500.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.easeOutQuint,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build the reset password form
  Widget _buildResetForm(
    BuildContext context,
    WidgetRef ref,
    TextEditingController emailController,
    AsyncValue<bool> forgotPasswordState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        const Center(
          child: Icon(
            Icons.lock_reset_rounded,
            size: 64,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        
        // Title
        Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we will send you a link to reset your password.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 32),
        
        // Email field
        const Text(
          'Email',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
        ),
        
        const SizedBox(height: 32),
        
        // Reset button
        AppButton(
          label: 'Send Reset Link',
          style: AppButtonStyle.primary,
          isLoading: forgotPasswordState is AsyncLoading,
          fullWidth: true,
          onPressed: forgotPasswordState is AsyncLoading
              ? null
              : () => _resetPassword(context, ref, emailController.text),
        ),
        
        // Error message
        if (forgotPasswordState is AsyncError)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              forgotPasswordState.error.toString(),
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(duration: 300.ms).shake(duration: 400.ms),
      ],
    );
  }
  
  /// Build the success content after sending reset email
  Widget _buildSuccessContent(BuildContext context) {
    return Column(
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 48,
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(height: 24),
        
        // Success message
        Text(
          'Reset Link Sent',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'We have sent a password reset link to your email. Please check your inbox and follow the instructions to reset your password.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Back to login button
        AppButton(
          label: 'Back to Login',
          style: AppButtonStyle.outline,
          fullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
  
  /// Handle password reset
  Future<void> _resetPassword(BuildContext context, WidgetRef ref, String email) async {
    if (email.isEmpty) {
      ref.read(forgotPasswordStateProvider.notifier).state = const AsyncValue.error(
        'Please enter your email address',
        StackTrace.empty,
      );
      return;
    }
    
    ref.read(forgotPasswordStateProvider.notifier).state = const AsyncValue.loading();
    
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.sendPasswordResetEmail(email);
      
      // Show success state
      if (context.mounted) {
        ref.read(forgotPasswordStateProvider.notifier).state = const AsyncValue.data(true);
      }
    } catch (e, stack) {
      AppLogger.error('Password reset error', e, stack);
      ref.read(forgotPasswordStateProvider.notifier).state = AsyncValue.error(
        _getResetPasswordErrorMessage(e),
        stack,
      );
    }
  }
  
  /// Get a user-friendly error message for password reset errors
  String _getResetPasswordErrorMessage(dynamic error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('user-not-found')) {
      return 'No user found with this email address. Please check your email or register.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'The email address is not valid. Please enter a valid email.';
    } else if (errorMessage.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    
    return 'An error occurred while sending the reset link. Please try again later.';
  }
} 