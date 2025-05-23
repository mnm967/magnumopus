import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/core/providers/user_provider.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';
import 'package:magnumopus/features/courses/presentation/lesson_player_screen.dart';
import 'package:magnumopus/services/download_service.dart';

/// Provider to get a specific course
final courseProvider = FutureProvider.family<Course?, String>((ref, courseId) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getCourse(courseId);
});

/// Provider to get lessons for a course
final courseLessonsProvider = StreamProvider.family<List<Lesson>, String>((ref, courseId) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getLessons(courseId);
});

/// Screen that displays detailed information about a course
class CourseDetailScreen extends HookConsumerWidget {
  final String courseId;
  
  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider(courseId));
    final lessonsAsync = ref.watch(courseLessonsProvider(courseId));
    final userAsyncValue = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: courseAsync.when(
        data: (course) {
          if (course == null) {
            return const Center(
              child: Text('Course not found'),
            );
          }
          
          return CustomScrollView(
            slivers: [
              // Course header with image
              _buildCourseHeader(context, ref, course),
              
              // Course content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course title and info
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Course metadata
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.play_circle_outline,
                            '${course.lessonCount} lessons',
                          ),
                          const SizedBox(width: 16),
                          _buildInfoChip(
                            Icons.timer_outlined,
                            _formatDuration(course.totalDuration),
                          ),
                          const SizedBox(width: 16),
                          _buildInfoChip(
                            Icons.star_outline_rounded,
                            course.tier.toString().split('.').last,
                            color: course.tier == SubscriptionTier.free
                                ? AppTheme.primaryColor
                                : course.tier == SubscriptionTier.advanced
                                    ? AppTheme.accentColor
                                    : AppTheme.secondaryColor,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Course description
                      if (course.description != null && course.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.description!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      
                      // Lessons section title
                      const Text(
                        'Lessons',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              
              // Lessons list
              lessonsAsync.when(
                data: (lessons) {
                  if (lessons.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No lessons available for this course',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return userAsyncValue.when(
                          data: (user) {
                            final lesson = lessons[index];
                            final isLocked = !_canAccessLesson(lesson, user, course.tier);
                            return _buildLessonItem(context, lesson, index, isLocked);
                          },
                          loading: () => const Center(
                            child: AppLoadingIndicator(),
                          ),
                          error: (_, __) => _buildLessonItem(
                            context, 
                            lessons[index], 
                            index,
                            true, // Lock by default if can't determine user
                          ),
                        );
                      },
                      childCount: lessons.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: AppLoadingIndicator(),
                  ),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error loading lessons',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(),
        ),
        error: (_, __) => const Center(
          child: Text(
            'Error loading course',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
  
  /// Build the course header with background image
  Widget _buildCourseHeader(BuildContext context, WidgetRef ref, Course course) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Course image or gradient
            if (course.thumbnailUrl != null)
              Image.network(
                course.thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white.withOpacity(0.5),
                      size: 64,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Play button for first lesson
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            // Play first lesson logic
            _playFirstLesson(context, ref);
          },
        ),
      ],
    );
  }
  
  /// Play the first lesson of the course
  void _playFirstLesson(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.read(courseLessonsProvider(courseId));
    
    lessonsAsync.whenData((lessons) {
      if (lessons.isNotEmpty) {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => LessonPlayerScreen(
              courseId: courseId,
              lessonId: lessons.first.id,
            ),
          ),
        );
      }
    });
  }
  
  /// Build a lesson item in the list
  Widget _buildLessonItem(BuildContext context, Lesson lesson, int index, bool isLocked) {
    return InkWell(
      onTap: isLocked ? null : () => _openLesson(context, lesson),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            // Lesson number
            Container(
              width: 32,
              height: 32,
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
            const SizedBox(width: 16),
            
            // Lesson details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(isLocked ? 0.5 : 1.0),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (lesson.duration != null && lesson.duration! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        lesson.durationFormatted,
                        style: TextStyle(
                          color: Colors.white.withOpacity(isLocked ? 0.3 : 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Free preview badge
            if (lesson.freePreview)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Free',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            
            // Lock/Play icon
            Icon(
              isLocked ? Icons.lock_outlined : Icons.play_circle_outline,
              color: isLocked
                  ? Colors.white.withOpacity(0.3)
                  : AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            // Download button
            if (!isLocked)
              Consumer(
                builder: (context, ref, _) {
                  final downloadStatus = ref.watch(lessonDownloadStatusProvider(lesson.id));
                  
                  return downloadStatus.when(
                    data: (isDownloaded) => IconButton(
                      icon: Icon(
                        isDownloaded 
                            ? Icons.download_done 
                            : Icons.download_for_offline_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        if (isDownloaded) {
                          _deleteDownload(context, ref, lesson);
                        } else {
                          _downloadLesson(context, ref, lesson);
                        }
                      },
                    ),
                    loading: () => const SizedBox(
                      width: 48,
                      height: 48,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    error: (_, __) => IconButton(
                      icon: const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                      ),
                      onPressed: () {
                        _downloadLesson(context, ref, lesson);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 50.ms * index).moveY(
        begin: 20,
        end: 0,
        duration: 300.ms,
        delay: 50.ms * index,
        curve: Curves.easeOutQuad,
      ),
    );
  }
  
  /// Build an info chip for course metadata
  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color ?? AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
  
  /// Check if user can access a lesson
  bool _canAccessLesson(Lesson lesson, User? user, SubscriptionTier courseTier) {
    // Free preview lessons are always accessible
    if (lesson.freePreview) {
      return true;
    }
    
    // If no user is logged in, only free content is accessible
    if (user == null) {
      return courseTier == SubscriptionTier.free;
    }
    
    // Admin can access everything
    if (user.isAdmin) {
      return true;
    }
    
    // User needs to have the appropriate subscription tier
    return user.canAccessTier(courseTier);
  }
  
  /// Download a lesson for offline viewing
  Future<void> _downloadLesson(BuildContext context, WidgetRef ref, Lesson lesson) async {
    final downloadService = ref.read(downloadServiceProvider);
    
    try {
      if (lesson.videoUrl == null || lesson.videoUrl!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No video available to download'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      
      await downloadService.downloadLesson(lesson);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading "${lesson.title}"'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting download: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  /// Delete a downloaded lesson
  Future<void> _deleteDownload(BuildContext context, WidgetRef ref, Lesson lesson) async {
    final downloadService = ref.read(downloadServiceProvider);
    
    try {
      await downloadService.deleteDownload(lesson);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${lesson.title}"'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting download: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  /// Open a lesson for viewing
  void _openLesson(BuildContext context, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonPlayerScreen(
          courseId: courseId,
          lessonId: lesson.id,
          isOfflineMode: lesson.isDownloaded,
          offlineVideoPath: lesson.isDownloaded ? lesson.localPath : null,
        ),
      ),
    );
  }
} 