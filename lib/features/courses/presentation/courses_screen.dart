import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_card.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/core/providers/user_provider.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';
import 'package:magnumopus/features/courses/presentation/course_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magnumopus/features/search/presentation/search_screen.dart';

/// Provider to get the current user's course categories
final courseCategoriesProvider = StreamProvider<List<CourseCategory>>((ref) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getCategories();
});

/// Provider to get featured courses
final featuredCoursesProvider = FutureProvider<List<Course>>((ref) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getFeaturedCourses();
});

/// Provider factory to get courses for a specific category
final coursesByCategoryProvider = StreamProvider.family<List<Course>, String>((ref, categoryId) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getCoursesByCategory(categoryId);
});

/// Screen that displays all available courses
class CoursesScreen extends HookConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(courseCategoriesProvider);
    final featuredCoursesAsync = ref.watch(featuredCoursesProvider);
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(courseCategoriesProvider);
          ref.refresh(featuredCoursesProvider);
        },
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: AppTheme.cardColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Courses',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              )
            ),
            
            // Main content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // User welcome
                    userAsync.when(
                      data: (user) {
                        if (user == null) return const SizedBox.shrink();
                        return _buildUserWelcome(context, user);
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Featured courses section
                    _buildSectionTitle('Featured Courses'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: featuredCoursesAsync.when(
                        data: (courses) => _buildFeaturedCourses(context, ref, courses),
                        loading: () => const Center(
                          child: AppLoadingIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading featured courses',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Categories and their courses
            categoriesAsync.when(
              data: (categories) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      return _buildCategorySection(context, ref, category);
                    },
                    childCount: categories.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: AppLoadingIndicator(),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error loading categories',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ),
            ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the welcome section with user info
  Widget _buildUserWelcome(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // User avatar or placeholder
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Welcome text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          
          // Subscription badge
          if (user.tier != SubscriptionTier.free)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.tier == SubscriptionTier.elite
                    ? 'Elite'
                    : 'Advanced',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 20, end: 0, duration: 600.ms);
  }
  
  /// Build the featured courses horizontal list
  Widget _buildFeaturedCourses(BuildContext context, WidgetRef ref, List<Course> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Text(
          'No featured courses available',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      );
    }
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: courses.length,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildFeaturedCourseCard(context, ref, course);
      },
    );
  }
  
  /// Build a featured course card
  Widget _buildFeaturedCourseCard(BuildContext context, WidgetRef ref, Course course) {
    return InkWell(
      onTap: () => _navigateToCourseDetail(context, course),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: course.thumbnailUrl != null
              ? DecorationImage(
                  image: NetworkImage(course.thumbnailUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: course.thumbnailUrl == null
              ? AppTheme.primaryGradient
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Course tier badge
              if (course.tier != SubscriptionTier.free)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: course.tier == SubscriptionTier.elite
                        ? AppTheme.secondaryColor
                        : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    course.tier == SubscriptionTier.elite
                        ? 'Elite'
                        : 'Advanced',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              
              // Course title
              Text(
                course.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Course info
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.play_circle_outlined,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course.lessonCount} lessons',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(course.totalDuration),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a category section with its courses
  Widget _buildCategorySection(BuildContext context, WidgetRef ref, CourseCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSectionTitle(category.name),
          ),
          const SizedBox(height: 16),
          
          // Courses for this category
          SizedBox(
            height: 156,
            child: _buildCategoryCoursesHorizontalList(context, ref, category.id),
          ),
        ],
      ),
    );
  }
  
  /// Build courses horizontal list for a category
  Widget _buildCategoryCoursesHorizontalList(BuildContext context, WidgetRef ref, String categoryId) {
    final coursesAsync = ref.watch(coursesByCategoryProvider(categoryId));
    
    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) {
          return Center(
            child: Text(
              'No courses in this category',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          );
        }
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: courses.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            final course = courses[index];
            return _buildCourseCard(context, course);
          },
        );
      },
      loading: () => const Center(
        child: AppLoadingIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading courses',
          style: TextStyle(color: AppTheme.errorColor),
        ),
      ),
    );
  }
  
  /// Build a course card for category lists
  Widget _buildCourseCard(BuildContext context, Course course) {
    return InkWell(
      onTap: () => _navigateToCourseDetail(context, course),
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: AppCard(
          padding: EdgeInsets.zero,
          isLocked: course.tier != SubscriptionTier.free, // Simple lock example, should check user's tier
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: course.thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(course.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient: course.thumbnailUrl == null
                      ? AppTheme.primaryGradient
                      : null,
                ),
                child: course.thumbnailUrl == null
                    ? Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white.withOpacity(0.8),
                          size: 32,
                        ),
                      )
                    : null,
              ),
              
              // Course info
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          size: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.lessonCount} lessons',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }
  
  /// Format duration from seconds to HH:MM:SS
  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0 min';
    
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '$minutes min';
    }
  }
  
  /// Navigate to course detail screen
  void _navigateToCourseDetail(BuildContext context, Course course) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(courseId: course.id),
      ),
    );
  }

  /// Debug method to check Firestore data
  void _debugCheckFirestoreData(WidgetRef ref) async {
    final firestore = FirebaseFirestore.instance;
    
    // Check courses
    try {
      final coursesSnapshot = await firestore.collection('courses').get();
      debugPrint('COURSES COUNT: ${coursesSnapshot.docs.length}');
      for (final doc in coursesSnapshot.docs) {
        debugPrint('COURSE: ${doc.id} - ${doc.data()['title']}');
      }
    } catch (e) {
      debugPrint('ERROR FETCHING COURSES: $e');
    }
    
    // Check categories
    try {
      final categoriesSnapshot = await firestore.collection('categories').get();
      debugPrint('CATEGORIES COUNT: ${categoriesSnapshot.docs.length}');
      for (final doc in categoriesSnapshot.docs) {
        debugPrint('CATEGORY: ${doc.id} - ${doc.data()['name']}');
      }
    } catch (e) {
      debugPrint('ERROR FETCHING CATEGORIES: $e');
    }
  }
} 