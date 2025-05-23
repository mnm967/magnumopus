import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/utils/mock_data_generator.dart';
import 'package:magnumopus/core/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magnumopus/data/models/user_model.dart' as model;
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/features/admin/presentation/admin_screen.dart';
import 'package:magnumopus/features/ai_assistant/presentation/ai_assistant_screen.dart';
import 'package:magnumopus/features/community/presentation/community_screen.dart';
import 'package:magnumopus/features/courses/presentation/courses_screen.dart';
import 'package:magnumopus/features/profile/presentation/profile_screen.dart';
import 'package:magnumopus/features/search/presentation/search_screen.dart';

/// Provider to track the current tab index
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

// Provider for tracking mock data generation state
final mockDataGenerationStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Home screen with bottom tab navigation
class HomeScreen extends HookConsumerWidget {
  HomeScreen({super.key}) {
    // Debug logging when HomeScreen is constructed
    debugPrint('HomeScreen constructor called');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[HomeScreen] build method started.');
    final currentIndex = ref.watch(homeTabIndexProvider);
    final userAsyncValue = ref.watch(currentUserProvider);
    final screens = _getScreens(userAsyncValue);
    final mockDataState = ref.watch(mockDataGenerationStateProvider);
    
    return Scaffold(
      appBar: currentIndex == 0 ? _buildAppBarWithDevTools(context, ref, mockDataState) : null,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, currentIndex, userAsyncValue),
    );
  }
  
  /// Build app bar with developer tools (only on first tab)
  AppBar _buildAppBarWithDevTools(BuildContext context, WidgetRef ref, AsyncValue<void> mockDataState) {
    final isLoading = mockDataState is AsyncLoading;
    
    return AppBar(
      title: const Text("Wizard Gift"),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search courses and lessons',
          onPressed: () => _navigateToSearch(context),
        ),
        
        // Mock data generation button (only in debug mode)
        // if (true) // Replace with !kReleaseMode for production
        //   isLoading 
        //     ? const Padding(
        //         padding: EdgeInsets.all(16.0),
        //         child: SizedBox(
        //           width: 24,
        //           height: 24,
        //           child: CircularProgressIndicator(
        //             color: Colors.white,
        //             strokeWidth: 2.0,
        //           ),
        //         ),
        //       )
        //     : IconButton(
        //         icon: const Icon(Icons.dataset),
        //         tooltip: 'Generate Mock Data',
        //         onPressed: () => _populateMockData(context, ref),
        //       ),
      ],
    );
  }
  
  /// Navigate to the search screen
  void _navigateToSearch(BuildContext context, {String? initialQuery}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialQuery: initialQuery),
      ),
    );
  }
  
  /// Build the bottom navigation bar
  Widget _buildBottomNavigationBar(
    BuildContext context, 
    WidgetRef ref, 
    int currentIndex,
    AsyncValue<model.User?> userAsyncValue,
  ) {
    final isAdmin = userAsyncValue.maybeWhen(
      data: (user) => user?.isAdmin ?? false,
      orElse: () => false,
    );
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                ref,
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.play_circle_outline_rounded,
                activeIcon: Icons.play_circle_rounded,
                label: 'Courses',
              ),
              _buildNavItem(
                context,
                ref,
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: 'Community',
              ),
              _buildNavItem(
                context,
                ref,
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.smart_toy_outlined,
                activeIcon: Icons.smart_toy_rounded,
                label: 'Assistant',
              ),
              if (isAdmin)
                _buildNavItem(
                  context,
                  ref,
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.admin_panel_settings_outlined,
                  activeIcon: Icons.admin_panel_settings,
                  label: 'Admin',
                ),
              _buildNavItem(
                context,
                ref,
                index: isAdmin ? 4 : 3,
                currentIndex: currentIndex,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).moveY(begin: 20, end: 0, duration: 300.ms);
  }
  
  /// Populate Firebase with mock data
  Future<void> _populateMockData(BuildContext context, WidgetRef ref) async {
    ref.read(mockDataGenerationStateProvider.notifier).state = const AsyncValue.loading();
    
    try {
      final mockDataGenerator = MockDataGenerator(
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      );
      
      await mockDataGenerator.generateAllMockData();
      
      if (context.mounted) {
        ref.read(mockDataGenerationStateProvider.notifier).state = const AsyncValue.data(null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mock data generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating mock data: $e');
      if (context.mounted) {
        ref.read(mockDataGenerationStateProvider.notifier).state = AsyncValue.error(e, StackTrace.current);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating mock data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Build a navigation item
  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = index == currentIndex;
    
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(homeTabIndexProvider.notifier).state = index,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
                size: 24,
              )
                .animate(target: isActive ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 200.ms,
                  curve: Curves.easeOutQuad,
                ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Get the screens for each tab
  List<Widget> _getScreens(AsyncValue<model.User?> userAsyncValue) {
    final isAdmin = userAsyncValue.maybeWhen(
      data: (user) => user?.isAdmin ?? false,
      orElse: () => false,
    );
    
    if (isAdmin) {
      return [
        const CoursesScreen(),    // Learning content (courses, videos)
        const CommunityScreen(),  // Community discussions
        const AIAssistantScreen(), // AI assistant chat
        const AdminScreen(),      // Admin panel (only for admins)
        const ProfileScreen(),    // User profile and settings
      ];
    } else {
      return [
        const CoursesScreen(),    // Learning content (courses, videos)
        const CommunityScreen(),  // Community discussions
        const AIAssistantScreen(), // AI assistant chat
        const ProfileScreen(),    // User profile and settings
      ];
    }
  }
} 