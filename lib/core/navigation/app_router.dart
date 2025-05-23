import 'package:flutter/material.dart';
import 'package:magnumopus/features/admin/presentation/admin_screen.dart';

class AppRouter {
  static const String adminScreen = '/admin';
  static const String manageCourses = '/admin/courses';
  static const String manageLessons = '/admin/lessons';
  static const String courseForm = '/admin/courses/form';
  static const String lessonForm = '/admin/lessons/form';
  
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case adminScreen:
        return MaterialPageRoute(
          builder: (_) => const AdminScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}