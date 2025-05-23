import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/services/download_service.dart';
import 'package:magnumopus/features/courses/presentation/lesson_player_screen.dart';

// TODO: Create a provider to get downloaded lessons

class DownloadsScreen extends HookConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the downloaded lessons provider
    final downloadsAsync = ref.watch(downloadsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Downloads'),
        actions: [
          // Add clear all button if there are downloads
          downloadsAsync.when(
            data: (downloads) => downloads.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear all downloads',
                    onPressed: () => _showClearAllDialog(context, ref),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: downloadsAsync.when(
        data: (downloads) {
          if (downloads.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final lesson = downloads[index];
              return _buildDownloadItem(context, ref, lesson);
            },
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading downloads: $error',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  
  /// Build the empty state when no downloads are available
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_done_rounded,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'No Downloads Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lessons you download will appear here.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Build a download item in the list
  Widget _buildDownloadItem(BuildContext context, WidgetRef ref, Lesson lesson) {
    final downloadService = ref.read(downloadServiceProvider);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _playDownloadedLesson(context, lesson),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson thumbnail or header
            if (lesson.thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  lesson.thumbnailUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    child: const Icon(
                      Icons.video_library,
                      color: AppTheme.primaryColor,
                      size: 48,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Icon(
                  Icons.video_library,
                  color: AppTheme.primaryColor,
                  size: 48,
                ),
              ),
              
            // Lesson info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (lesson.duration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        lesson.durationFormatted,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  
                  // Download progress indicator (if download is in progress)
                  _buildDownloadProgress(ref, lesson),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Check if downloaded file exists and show appropriate text
                      FutureBuilder<bool>(
                        future: _checkFileExists(lesson.localPath),
                        builder: (context, snapshot) {
                          final fileExists = snapshot.data ?? false;
                          return Row(
                            children: [
                              Icon(
                                fileExists
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color: fileExists
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                fileExists ? 'Ready to play' : 'File not found',
                                style: TextStyle(
                                  color: fileExists
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      // Play and delete buttons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.play_circle_filled,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: () => _playDownloadedLesson(context, lesson),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white70,
                            ),
                            onPressed: () => _showDeleteConfirmation(
                              context,
                              ref,
                              lesson,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the download progress indicator
  Widget _buildDownloadProgress(WidgetRef ref, Lesson lesson) {
    // Watch the progress for this lesson
    final progressAsync = ref.watch(lessonDownloadProgressProvider(lesson.id));
    
    return progressAsync.when(
      data: (progress) {
        // Only show progress bar if download is in progress (not 0 or 100)
        if (progress > 0 && progress < 100) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Downloading...',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$progress%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                minHeight: 4,
              ),
              const SizedBox(height: 8),
              
              // Cancel button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    final downloadService = ref.read(downloadServiceProvider);
                    downloadService.cancelDownload(lesson.id);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink(); // Don't show anything if not downloading
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  
  /// Show confirmation dialog to delete a download
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Delete Download',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${lesson.title}"?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDownload(context, ref, lesson);
            },
          ),
        ],
      ),
    );
  }
  
  /// Show confirmation dialog to clear all downloads
  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Clear All Downloads',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete all downloaded lessons?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              'Delete All',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllDownloads(context, ref);
            },
          ),
        ],
      ),
    );
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
  
  /// Clear all downloads
  Future<void> _clearAllDownloads(BuildContext context, WidgetRef ref) async {
    final downloadService = ref.read(downloadServiceProvider);
    final downloads = ref.read(downloadsProvider).value ?? [];
    
    try {
      for (final lesson in downloads) {
        await downloadService.deleteDownload(lesson);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All downloads cleared'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing downloads: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  /// Play a downloaded lesson
  void _playDownloadedLesson(BuildContext context, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonPlayerScreen(
          courseId: lesson.courseId,
          lessonId: lesson.id,
          isOfflineMode: true,
          offlineVideoPath: lesson.localPath,
        ),
      ),
    );
  }
  
  /// Check if a file exists
  Future<bool> _checkFileExists(String? path) async {
    if (path == null) return false;
    final file = File(path);
    return await file.exists();
  }
} 