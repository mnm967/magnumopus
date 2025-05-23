import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/core/providers/course_providers.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';
import 'package:magnumopus/features/admin/presentation/lesson_form_screen.dart';

/// Provider for selected course ID
final selectedCourseIdProvider = StateProvider<String?>((ref) => null);

/// Screen to manage lessons in the admin panel
class ManageLessonsScreen extends HookConsumerWidget {
  final String? initialCourseId;
  
  const ManageLessonsScreen({
    super.key,
    this.initialCourseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If initialCourseId is provided, set it in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialCourseId != null) {
        ref.read(selectedCourseIdProvider.notifier).state = initialCourseId;
      }
    });
    
    final coursesAsync = ref.watch(allCoursesProvider);
    final selectedCourseId = ref.watch(selectedCourseIdProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      floatingActionButton: selectedCourseId != null
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _navigateToCreateLesson(context, selectedCourseId),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseSelector(context, ref, coursesAsync),
            const SizedBox(height: 24),
            
            // Lessons list
            if (selectedCourseId != null)
              _buildLessonsList(context, ref, selectedCourseId)
            else
              _buildNoSelectionMessage(),
          ],
        ),
      ),
    );
  }
  
  /// Build the course selector dropdown
  Widget _buildCourseSelector(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Course>> coursesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Course',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        coursesAsync.when(
          data: (courses) {
            if (courses.isEmpty) {
              return const Text(
                'No courses available. Please create a course first.',
                style: TextStyle(color: Colors.red),
              );
            }
            
            final selectedCourseId = ref.watch(selectedCourseIdProvider);
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCourseId,
                  hint: Text(
                    'Select a course',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  isExpanded: true,
                  dropdownColor: AppTheme.cardColor,
                  items: courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course.id,
                      child: Text(
                        course.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(selectedCourseIdProvider.notifier).state = value;
                  },
                ),
              ),
            );
          },
          loading: () => const AppLoadingIndicator(),
          error: (_, __) => const Text(
            'Error loading courses',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
  
  /// Build the lessons list for the selected course
  Widget _buildLessonsList(
    BuildContext context,
    WidgetRef ref,
    String courseId,
  ) {
    final lessonsAsync = ref.watch(courseLessonsProvider(courseId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Lessons',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        lessonsAsync.when(
          data: (lessons) {
            if (lessons.isEmpty) {
              return _buildEmptyState('No lessons found for this course');
            }
            
            // Sort lessons by order
            final sortedLessons = List<Lesson>.from(lessons)
              ..sort((a, b) => a.order.compareTo(b.order));
            
            return ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedLessons.length,
              onReorder: (oldIndex, newIndex) => _reorderLessons(
                context, 
                ref, 
                sortedLessons, 
                oldIndex, 
                newIndex,
              ),
              itemBuilder: (context, index) {
                final lesson = sortedLessons[index];
                return _buildLessonItem(
                  context, 
                  ref, 
                  lesson, 
                  index,
                  key: Key(lesson.id),
                );
              },
            );
          },
          loading: () => const Center(
            child: AppLoadingIndicator(),
          ),
          error: (error, _) => Center(
            child: Text(
              'Error loading lessons: $error',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build a single lesson item
  Widget _buildLessonItem(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
    int index, {
    required Key key,
  }) {
    return Card(
      key: key,
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              lesson.type == 'video' ? Icons.play_circle_outline : Icons.article_outlined,
              size: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              lesson.type == 'video' 
                  ? lesson.durationFormatted
                  : 'Text content',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 8),
            if (lesson.freePreview)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Free Preview',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70),
              onPressed: () => _navigateToEditLesson(context, lesson),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteLessonDialog(context, ref, lesson),
            ),
          ],
        ),
      ),
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
  
  /// Build a message for when no course is selected
  Widget _buildNoSelectionMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a course to manage its lessons',
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
  
  /// Handle reordering of lessons
  Future<void> _reorderLessons(
    BuildContext context,
    WidgetRef ref,
    List<Lesson> lessons,
    int oldIndex,
    int newIndex,
  ) async {
    // If moving down, decrement newIndex to account for the removal
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    try {
      final lesson = lessons[oldIndex];
      final courseRepository = ref.read(courseRepositoryProvider);
      
      // Update the order of the lesson
      await courseRepository.updateLessonOrder(
        lesson.courseId,
        lesson.id,
        newIndex,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson order updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating lesson order: $e')),
        );
      }
    }
  }
  
  /// Show dialog to confirm lesson deletion
  Future<void> _showDeleteLessonDialog(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Delete Lesson',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${lesson.title}"? This action cannot be undone.',
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
      try {
        final courseRepository = ref.read(courseRepositoryProvider);
        
        // Delete the lesson
        await courseRepository.deleteLesson(
          courseId: lesson.courseId,
          lessonId: lesson.id,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting lesson: $e')),
          );
        }
      }
    }
  }
  
  /// Navigate to the create lesson screen
  void _navigateToCreateLesson(BuildContext context, String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonFormScreen(courseId: courseId),
      ),
    );
  }
  
  /// Navigate to the edit lesson screen
  void _navigateToEditLesson(BuildContext context, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonFormScreen(
          courseId: lesson.courseId,
          lesson: lesson,
        ),
      ),
    );
  }
} 