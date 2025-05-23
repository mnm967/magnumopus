import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/core/providers/course_providers.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';
import 'package:magnumopus/features/admin/presentation/course_form_screen.dart';

/// Screen to manage courses in the admin panel
class ManageCoursesScreen extends HookConsumerWidget {
  const ManageCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(courseCategoriesProvider);
    final coursesAsync = ref.watch(allCoursesProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _navigateToCreateCourse(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(courseCategoriesProvider);
          ref.refresh(allCoursesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, 'Course Categories'),
                
                // Categories list
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return _buildEmptyState('No categories found');
                    }
                    
                    return _buildCategoriesList(context, ref, categories);
                  },
                  loading: () => const Center(
                    child: AppLoadingIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      'Error loading categories: $error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionHeader(context, 'All Courses'),
                
                // Courses list
                coursesAsync.when(
                  data: (courses) {
                    if (courses.isEmpty) {
                      return _buildEmptyState('No courses found');
                    }
                    
                    return _buildCoursesList(context, ref, courses);
                  },
                  loading: () => const Center(
                    child: AppLoadingIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      'Error loading courses: $error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build a section header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          if (title == 'Course Categories')
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Category'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
              onPressed: () => _showAddCategoryDialog(context),
            ),
        ],
      ),
    );
  }
  
  /// Build the categories list
  Widget _buildCategoriesList(
    BuildContext context, 
    WidgetRef ref, 
    List<CourseCategory> categories
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          color: AppTheme.cardColor,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: category.description != null
                ? Text(
                    category.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70),
                  onPressed: () => _showEditCategoryDialog(context, category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteCategoryDialog(context, ref, category),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Build the courses list
  Widget _buildCoursesList(
    BuildContext context, 
    WidgetRef ref, 
    List<Course> courses
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          color: AppTheme.cardColor,
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              course.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _getTierLabel(course.tier),
              style: TextStyle(
                color: _getTierColor(course.tier),
              ),
            ),
            leading: course.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      course.thumbnailUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        child: const Icon(Icons.image_not_supported, color: Colors.white54),
                      ),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    child: const Icon(Icons.school, color: Colors.white70),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70),
                  onPressed: () => _navigateToEditCourse(context, course),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteCourseDialog(context, ref, course),
                ),
              ],
            ),
            children: [
              if (course.description != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    course.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoChip(Icons.play_circle_outline, '${course.lessonCount} lessons'),
                    _buildInfoChip(Icons.timer_outlined, _formatDuration(course.totalDuration)),
                    AppButton(
                      label: 'Manage Lessons',
                      style: AppButtonStyle.secondary,
                      icon: Icons.menu_book,
                      onPressed: () => _navigateToManageLessons(context, course),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Build an empty state widget
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build an info chip for course metadata
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Show dialog to add a new category
  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Add Category',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'description': descriptionController.text.trim(),
              });
            },
          ),
        ],
      ),
    );
    
    if (result != null) {
      // Add category logic here
    }
  }
  
  /// Show dialog to edit a category
  Future<void> _showEditCategoryDialog(
    BuildContext context, 
    CourseCategory category
  ) async {
    final nameController = TextEditingController(text: category.name);
    final descriptionController = TextEditingController(text: category.description);
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Edit Category',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'description': descriptionController.text.trim(),
              });
            },
          ),
        ],
      ),
    );
    
    if (result != null) {
      // Update category logic here
    }
  }
  
  /// Show dialog to confirm category deletion
  Future<void> _showDeleteCategoryDialog(
    BuildContext context, 
    WidgetRef ref, 
    CourseCategory category
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Delete Category',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // Delete category logic here
    }
  }
  
  /// Show dialog to confirm course deletion
  Future<void> _showDeleteCourseDialog(
    BuildContext context, 
    WidgetRef ref, 
    Course course
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Delete Course',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${course.title}"? This will also delete all lessons in this course. This action cannot be undone.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // Delete course logic here
    }
  }
  
  /// Navigate to the create course screen
  void _navigateToCreateCourse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CourseFormScreen(),
      ),
    );
  }
  
  /// Navigate to the edit course screen
  void _navigateToEditCourse(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseFormScreen(course: course),
      ),
    );
  }
  
  /// Navigate to manage lessons for a specific course
  void _navigateToManageLessons(BuildContext context, Course course) {
    // Navigation to manage lessons for a specific course
  }
  
  /// Get the color for a subscription tier
  Color _getTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return AppTheme.primaryColor;
      case SubscriptionTier.advanced:
        return AppTheme.accentColor;
      case SubscriptionTier.elite:
        return AppTheme.secondaryColor;
    }
  }
  
  /// Get the label for a subscription tier
  String _getTierLabel(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Free Tier';
      case SubscriptionTier.advanced:
        return 'Advanced Tier';
      case SubscriptionTier.elite:
        return 'Elite Tier';
    }
  }
  
  /// Format duration from seconds to a readable string
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
} 