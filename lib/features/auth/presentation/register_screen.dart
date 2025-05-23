import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/utils/logger.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/features/home/presentation/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider to manage registration state
final registerStateProvider = StateProvider.autoDispose<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Registration screen for new users
class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final registerState = ref.watch(registerStateProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Join Wizard Gift',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Create an account to access trading education content',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Registration form
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  const Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                  ),
                  const SizedBox(height: 24),
                  
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
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 24),
                  
                  // Password field
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Choose a strong password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Password requirements
                  Text(
                    'Password must be at least 8 characters long',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 20, end: 0, duration: 600.ms),
              
              const SizedBox(height: 32),
              
              // Terms and conditions
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: true,
                      onChanged: (value) {
                        // Implement terms agreement logic
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
              
              const SizedBox(height: 32),
              
              // Register button
              AppButton(
                label: 'Create Account',
                isLoading: registerState is AsyncLoading,
                fullWidth: true,
                onPressed: registerState is AsyncLoading
                    ? null
                    : () => _register(
                          context,
                          ref,
                          nameController.text,
                          emailController.text,
                          passwordController.text,
                        ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
              
              // Error message
              if (registerState is AsyncError)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    registerState.error.toString(),
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 300.ms).shake(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Handle user registration
  Future<void> _register(
    BuildContext context,
    WidgetRef ref,
    String name,
    String email,
    String password,
  ) async {
    // Validate inputs
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ref.read(registerStateProvider.notifier).state = const AsyncValue.error(
        'All fields are required',
        StackTrace.empty,
      );
      return;
    }
    
    if (password.length < 8) {
      ref.read(registerStateProvider.notifier).state = const AsyncValue.error(
        'Password must be at least 8 characters long',
        StackTrace.empty,
      );
      return;
    }
    
    debugPrint('[RegisterScreen] Attempting registration with email: $email');
    ref.read(registerStateProvider.notifier).state = const AsyncValue.loading();
    
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      debugPrint('[RegisterScreen] authRepository.registerWithEmailAndPassword returned user: ${user?.id ?? 'null'}');

      if (!context.mounted) {
        debugPrint('[RegisterScreen] Context unmounted after registration attempt, aborting.');
        return;
      }
      
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint('[RegisterScreen] WARNING: FirebaseAuth.instance.currentUser is NULL immediately after successful registration API call.');
      } else {
        debugPrint('[RegisterScreen] FirebaseAuth.instance.currentUser: ${firebaseUser.uid}');
      }

      if (user != null) {
        ref.read(registerStateProvider.notifier).state = const AsyncValue.data(null);
        debugPrint('[RegisterScreen] registerStateProvider set to AsyncValue.data(null).');
        
        // Short delay to allow state propagation
        await Future.delayed(const Duration(milliseconds: 100));

        if (context.mounted) {
          debugPrint('[RegisterScreen] Context still mounted. Attempting navigation to HomeScreen...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          debugPrint('[RegisterScreen] Navigation to HomeScreen initiated.');
        } else {
          debugPrint('[RegisterScreen] Context became unmounted before HomeScreen navigation.');
        }
      } else {
        debugPrint('[RegisterScreen] Registration API returned null user, throwing error.');
        throw Exception('Failed to create account - API returned null user');
      }
    } catch (e, stack) {
      debugPrint('[RegisterScreen] Registration exception: $e');
      AppLogger.error('Registration error', e, stack);
      if (context.mounted) {
        ref.read(registerStateProvider.notifier).state = AsyncValue.error(
          _getRegisterErrorMessage(e),
          stack,
        );
      }
    }
  }
  
  /// Get a user-friendly error message for registration errors
  String _getRegisterErrorMessage(dynamic error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('email-already-in-use')) {
      return 'An account already exists with this email. Please log in or use a different email.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'The email address is not valid. Please enter a valid email.';
    } else if (errorMessage.contains('weak-password')) {
      return 'The password provided is too weak. Please choose a stronger password.';
    } else if (errorMessage.contains('operation-not-allowed')) {
      return 'Account creation is disabled. Please contact support.';
    } else if (errorMessage.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorMessage.contains('invalid-credential')) {
      return 'Authentication failed. Please check your email and password.';
    }
    
    // Log the exact error for debugging
    debugPrint('Unhandled registration error: $errorMessage');
    return 'An error occurred during account creation. Please try again.';
  }
} 