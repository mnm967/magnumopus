import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/utils/logger.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/features/auth/presentation/forgot_password_screen.dart';
import 'package:magnumopus/features/auth/presentation/register_screen.dart';
import 'package:magnumopus/features/home/presentation/home_screen.dart';

/// Provider to manage login state
final loginStateProvider = StateProvider.autoDispose<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Login screen for the app
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final loginState = ref.watch(loginStateProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and app name
              Column(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // App name
                  Text(
                    'Wizard Gift',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trading Education Platform',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0, duration: 600.ms),
              
              const SizedBox(height: 48),
              
              // Login form
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                  ),
                  
                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 200.ms).fadeIn(duration: 600.ms).moveY(begin: 20, end: 0, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              // Login button
              AppButton(
                label: 'Log In',
                isLoading: loginState is AsyncLoading,
                fullWidth: true,
                onPressed: loginState is AsyncLoading
                    ? null
                    : () => _login(context, ref, emailController.text, passwordController.text),
              ).animate(delay: 400.ms).fadeIn(duration: 600.ms).moveY(begin: 20, end: 0, duration: 600.ms),
              
              const SizedBox(height: 16),
              
              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 600.ms).fadeIn(duration: 600.ms),
              
              // Error message
              if (loginState is AsyncError)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    loginState.error.toString(),
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
  
  /// Handle login with email and password
  Future<void> _login(BuildContext context, WidgetRef ref, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      ref.read(loginStateProvider.notifier).state = const AsyncValue.error(
        'Please enter both email and password',
        StackTrace.empty,
      );
      return;
    }

    debugPrint('[LoginScreen] Attempting login with email: $email');
    ref.read(loginStateProvider.notifier).state = const AsyncValue.loading();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('[LoginScreen] authRepository.loginWithEmailAndPassword reported success.');

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint('[LoginScreen] WARNING: FirebaseAuth.instance.currentUser is NULL immediately after successful login API call.');
      } else {
        debugPrint('[LoginScreen] FirebaseAuth.instance.currentUser: ${firebaseUser.uid}');
      }

      if (!context.mounted) {
        debugPrint('[LoginScreen] Context unmounted after login attempt, aborting navigation.');
        return;
      }

      ref.read(loginStateProvider.notifier).state = const AsyncValue.data(null);
      debugPrint('[LoginScreen] loginStateProvider set to AsyncValue.data(null).');
      
      // Short delay to allow state propagation, if necessary
      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        debugPrint('[LoginScreen] Context still mounted. Attempting navigation to HomeScreen...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        debugPrint('[LoginScreen] Navigation to HomeScreen initiated.');
      } else {
        debugPrint('[LoginScreen] Context became unmounted before HomeScreen navigation.');
      }

    } catch (e, stack) {
      debugPrint('[LoginScreen] Login exception: $e');
      AppLogger.error('Login error', e, stack);
      if (context.mounted) {
        ref.read(loginStateProvider.notifier).state = AsyncValue.error(
          _getLoginErrorMessage(e),
          stack,
        );
      }
    }
  }
  
  /// Get a user-friendly error message for login errors
  String _getLoginErrorMessage(dynamic error) {
    final errorMessage = error.toString();
    
    if (errorMessage.contains('user-not-found')) {
      return 'No user found with this email. Please check your email or register.';
    } else if (errorMessage.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'Invalid email format. Please enter a valid email.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (errorMessage.contains('too-many-requests')) {
      return 'Too many failed login attempts. Please try again later.';
    } else if (errorMessage.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorMessage.contains('invalid-credential')) {
      return 'Authentication failed. Please check your email and password.';
    }
    
    return 'An error occurred during login. Please try again.';
  }
} 