import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/providers/user_provider.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/features/admin/presentation/manage_courses_screen.dart';
import 'package:magnumopus/features/admin/presentation/manage_lessons_screen.dart';

/// Main screen for the admin panel
class AdminScreen extends HookConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);
    
    return userAsyncValue.when(
      data: (user) {
        if (user == null || !user.isAdmin) {
          return _buildUnauthorizedView(context);
        }
        
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppTheme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Admin Panel'),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.school),
                    text: 'Courses',
                  ),
                  Tab(
                    icon: Icon(Icons.menu_book),
                    text: 'Lessons',
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                ManageCoursesScreen(),
                ManageLessonsScreen(),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppTheme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _buildUnauthorizedView(context),
    );
  }
  
  /// Build the view for unauthorized users
  Widget _buildUnauthorizedView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AppTheme.errorColor.withOpacity(0.6),
              ),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You do not have administrator privileges to access this section.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 