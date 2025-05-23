import 'package:flutter/material.dart';
import 'package:magnumopus/features/ai_assistant/presentation/ai_assistant_screen.dart';
import 'package:magnumopus/features/auth/presentation/forgot_password_screen.dart';
import 'package:magnumopus/features/auth/presentation/login_screen.dart';
import 'package:magnumopus/features/auth/presentation/register_screen.dart';
import 'package:magnumopus/features/home/presentation/home_screen.dart';
import 'package:magnumopus/features/courses/presentation/course_detail_screen.dart';
import 'package:magnumopus/features/courses/presentation/courses_screen.dart';
import 'package:magnumopus/features/courses/presentation/lesson_player_screen.dart';
import 'package:magnumopus/features/community/presentation/community_screen.dart';
import 'package:magnumopus/features/profile/presentation/profile_screen.dart';
import 'package:magnumopus/features/onboarding/presentation/onboarding_screen.dart';
import 'package:magnumopus/features/downloads/presentation/downloads_screen.dart';

/// Routes class for managing app navigation
class AppRoutes {
  // Route names
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String courseDetail = '/course-detail';
  static const String lessonPlayer = '/lesson-player';
  static const String community = '/community';
  static const String chat = '/chat';
  static const String aiAssistant = '/ai-assistant';
  static const String profile = '/profile';
  static const String downloads = '/downloads';
  
  // Home screen getter for direct navigation
  static Widget getHomeScreen() => const HomeScreen();
  
  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
        
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
        
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case courses:
        return MaterialPageRoute(builder: (_) => const CoursesScreen());
        
      case courseDetail:
        // Extract the courseId from the arguments
        final args = settings.arguments as Map<String, dynamic>?;
        final courseId = args?['courseId'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => CourseDetailScreen(courseId: courseId));
        
      case lessonPlayer:
        // Extract the courseId and lessonId from the arguments
        final args = settings.arguments as Map<String, dynamic>?;
        final courseId = args?['courseId'] as String? ?? '';
        final lessonId = args?['lessonId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => LessonPlayerScreen(
            courseId: courseId,
            lessonId: lessonId,
          ),
        );
        
      case community:
        return MaterialPageRoute(builder: (_) => const CommunityScreen());
        
      case chat:
        // For the chat screen, we'll just go back to the community screen
        // Implementation can be added later when ChatScreen is available
        return MaterialPageRoute(builder: (_) => const CommunityScreen());
        
      case aiAssistant:
        return MaterialPageRoute(builder: (_) => const AIAssistantScreen());
        
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
        
      case downloads:
        return MaterialPageRoute(builder: (_) => const DownloadsScreen());
        
      default:
        // If the route is not found, redirect to home
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}

// Import placeholders to make the router work
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold();
} 