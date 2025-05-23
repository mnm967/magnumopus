import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/services/download_service.dart';
import 'package:magnumopus/features/courses/presentation/lesson_player_screen.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Provider for in-progress downloads
final activeDownloadsProvider = StreamProvider<List<Lesson>>((ref) async* {
  debugPrint('Checking for active downloads...');
  final tasks = await FlutterDownloader.loadTasks();
  
  if (tasks == null || tasks.isEmpty) {
    debugPrint('No download tasks found');
    yield [];
    return;
  }
  
  // Filter for active tasks (downloading)
  final activeTasks = tasks.where((task) => 
    task.status == DownloadTaskStatus.running || 
    task.status == DownloadTaskStatus.enqueued).toList();
  
  debugPrint('Found ${activeTasks.length} active download tasks');
  
  if (activeTasks.isEmpty) {
    yield [];
    return;
  }
  
  // Try to find the lessons for these tasks
  final box = await Hive.openBox<Lesson>('downloaded_lessons');
  final activeDownloads = <Lesson>[];
  
  for (final task in activeTasks) {
    debugPrint('Looking for lesson for task: ${task.taskId}');
    // First try direct lookup
    final lesson = box.get(task.taskId);
    if (lesson != null) {
      debugPrint('Found lesson for task ${task.taskId}: ${lesson.title}');
      activeDownloads.add(lesson);
    } else {
      // If no direct match, try searching by URL
      for (final lessonEntry in box.values) {
        if (lessonEntry.videoUrl == task.url) {
          debugPrint('Found lesson by URL for task ${task.taskId}: ${lessonEntry.title}');
          activeDownloads.add(lessonEntry);
          break;
        }
      }
    }
  }
  
  debugPrint('Yielding ${activeDownloads.length} active downloads');
  yield activeDownloads;
  
  // Continue monitoring for changes
  yield* Stream.periodic(const Duration(seconds: 1), (_) async {
    final updatedTasks = await FlutterDownloader.loadTasks();
    if (updatedTasks == null) return <Lesson>[];
    
    final updatedActiveTasks = updatedTasks.where((task) => 
      task.status == DownloadTaskStatus.running || 
      task.status == DownloadTaskStatus.enqueued).toList();
    
    final updatedActiveDownloads = <Lesson>[];
    
    for (final task in updatedActiveTasks) {
      final lesson = box.get(task.taskId);
      if (lesson != null) {
        updatedActiveDownloads.add(lesson);
      } else {
        for (final lessonEntry in box.values) {
          if (lessonEntry.videoUrl == task.url) {
            updatedActiveDownloads.add(lessonEntry);
            break;
          }
        }
      }
    }
    
    return updatedActiveDownloads;
  }).asyncMap((future) async => await future);
});

class DownloadsScreen extends HookConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the downloaded lessons provider
    final downloadsAsync = ref.watch(downloadsProvider);
    final activeDownloadsAsync = ref.watch(activeDownloadsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Downloads'),
        actions: [
          // Show active downloads count
          Center(
            child: activeDownloadsAsync.when(
              data: (downloads) => downloads.isNotEmpty 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${downloads.length} active',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 8),
          
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh downloads',
            onPressed: () {
              ref.refresh(downloadsProvider);
              ref.refresh(activeDownloadsProvider);
            },
          ),
          
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
      body: Column(
        children: [
          // Active downloads section
          activeDownloadsAsync.when(
            data: (activeDownloads) {
              if (activeDownloads.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Downloading',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeDownloads.length,
                    itemBuilder: (context, index) {
                      final lesson = activeDownloads[index];
                      return _buildActiveDownloadItem(context, ref, lesson);
                    },
                  ),
                  const Divider(
                    color: Colors.white24,
                    thickness: 1,
                    height: 32,
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Downloaded content section
          Expanded(
            child: downloadsAsync.when(
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
          ),
        ],
      ),
    );
  }
  
  /// Build an active download item with progress
  Widget _buildActiveDownloadItem(BuildContext context, WidgetRef ref, Lesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail or icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.video_file,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Progress bar
                  Consumer(
                    builder: (context, ref, _) {
                      final progressAsync = ref.watch(downloadProgressProvider(lesson.id));
                      
                      return progressAsync.when(
                        data: (progress) {
                          debugPrint('Rendering progress for ${lesson.id}: ${progress.progress}%');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress.progress / 100,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${progress.progress}% complete',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (progress.taskId != null)
                                    InkWell(
                                      onTap: () {
                                        ref.read(downloadServiceProvider).cancelDownload(progress.taskId!);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                        loading: () => ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            minHeight: 8,
                          ),
                        ),
                        error: (error, __) {
                          debugPrint('Error loading progress: $error');
                          return const Text(
                            'Error loading progress',
                            style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the empty state when no downloads are available
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
            const SizedBox(height: 24),
            
            // Debug information
            Consumer(
              builder: (context, ref, child) {
                return FutureBuilder(
                  future: _getDebugInfo(ref),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    
                    final debugInfo = snapshot.data as Map<String, dynamic>;
                    
                    return ExpansionTile(
                      title: const Text(
                        'Download Status Info',
                        style: TextStyle(color: Colors.white70),
                      ),
                      collapsedIconColor: Colors.white70,
                      iconColor: AppTheme.primaryColor,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDebugText('Tasks found:', '${debugInfo['tasksCount']}'),
                              _buildDebugText('Active tasks:', '${debugInfo['activeTasksCount']}'),
                              _buildDebugText('Download dir:', debugInfo['downloadsDir'] as String),
                              const SizedBox(height: 16),
                              if (debugInfo['tasksCount'] > 0)
                                Text(
                                  'Task IDs:',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ...List.generate(
                                (debugInfo['taskIds'] as List).length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '${index + 1}. ${(debugInfo['taskIds'] as List)[index]}',
                                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDebugText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<Map<String, dynamic>> _getDebugInfo(WidgetRef ref) async {
    final result = <String, dynamic>{};
    try {
      final tasks = await FlutterDownloader.loadTasks();
      result['tasksCount'] = tasks?.length ?? 0;
      result['activeTasksCount'] = tasks?.where((task) => 
          task.status == DownloadTaskStatus.running || 
          task.status == DownloadTaskStatus.enqueued).length ?? 0;
      
      result['taskIds'] = <String>[];
      if (tasks != null) {
        for (final task in tasks) {
          (result['taskIds'] as List).add('${task.taskId} (${task.status.name}) - ${task.progress}%');
        }
      }
      
      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDocDir.path}/downloads');
      result['downloadsDir'] = downloadsDir.path;
      
      if (downloadsDir.existsSync()) {
        final files = downloadsDir.listSync();
        result['filesCount'] = files.length;
      } else {
        result['filesCount'] = 'Directory not found';
      }
    } catch (e) {
      result['error'] = e.toString();
    }
    return result;
  }
  
  /// Build a download item in the list
  Widget _buildDownloadItem(BuildContext context, WidgetRef ref, Lesson lesson) {
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