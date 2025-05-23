import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:path_provider/path_provider.dart';

/// Provider for the download service
final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

/// Provider for the downloads list
final downloadsProvider = StreamProvider<List<Lesson>>((ref) {
  return ref.watch(downloadServiceProvider).getDownloadedLessons();
});

/// Provider to get a specific lesson's download status
final lessonDownloadStatusProvider = StreamProvider.family<bool, String>((ref, lessonId) {
  return ref.watch(downloadServiceProvider).getLessonDownloadStatus(lessonId);
});

/// Provider for download progress
final downloadProgressProvider = StreamProvider.family<DownloadProgress, String>((ref, lessonId) {
  return ref.watch(downloadServiceProvider).getDownloadProgress(lessonId);
});

/// Class to hold download progress information
class DownloadProgress {
  final int progress; // 0-100
  final DownloadTaskStatus status;
  final String? taskId;

  const DownloadProgress({
    required this.progress,
    required this.status,
    this.taskId,
  });

  bool get isDownloading => status == DownloadTaskStatus.running;
  bool get isCompleted => status == DownloadTaskStatus.complete;
  bool get isFailed => status == DownloadTaskStatus.failed;
  bool get isCanceled => status == DownloadTaskStatus.canceled;
  bool get isPaused => status == DownloadTaskStatus.paused;
  bool get isWaiting => status == DownloadTaskStatus.enqueued;
  bool get isActive => isDownloading || isWaiting;

  static const initial = DownloadProgress(
    progress: 0,
    status: DownloadTaskStatus.undefined,
  );
}

/// Service to handle downloading and storing video lessons
@pragma('vm:entry-point')
class DownloadService {
  static const _boxName = 'downloaded_lessons';
  static const _progressBoxName = 'download_progress';
  
  /// Port name for communication with the download isolate
  static const _portName = 'downloader_send_port';
  
  /// Send port for receiving download status updates
  final ReceivePort _port = ReceivePort();

  /// Map of lessonId to progress controllers
  final _progressControllerMap = <String, StreamController<DownloadProgress>>{};
  
  /// Initialize the download service
  Future<void> initialize() async {
    debugPrint('Initializing download service');
    // Register the download callback
    await FlutterDownloader.registerCallback(downloadCallback, step: 1);
    
    // Register the port for communication between isolates
    IsolateNameServer.registerPortWithName(_port.sendPort, _portName);
    
    // Listen for download status updates
    _port.listen((dynamic data) {
      // Data format: [taskId, status, progress]
      final taskId = data[0] as String;
      final status = data[1] as DownloadTaskStatus;
      final progress = data[2] as int;
      
      debugPrint('Download update for $taskId: status=$status, progress=$progress');
      _updateDownloadStatus(taskId, status, progress);
    });
    
    // Initialize Hive boxes
    await Hive.openBox<Lesson>(_boxName);
    await Hive.openBox<Map>(_progressBoxName);
    
    // Recover any ongoing downloads
    await _recoverDownloads();
  }

  /// Recover any ongoing downloads from previous sessions
  Future<void> _recoverDownloads() async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks != null) {
        for (final task in tasks) {
          // Lookup the lesson for this task
          final box = await Hive.openBox<Lesson>(_boxName);
          Lesson? lesson;
          for (final entry in box.values) {
            if (entry.localPath?.contains(task.taskId) == true ||
                entry.videoUrl == task.url) {
              lesson = entry;
              break;
            }
          }
          
          if (lesson != null) {
            // Update the progress controller
            final progress = DownloadProgress(
              progress: task.progress,
              status: task.status,
              taskId: task.taskId,
            );
            _notifyProgress(lesson.id, progress);
          }
        }
      }
    } catch (e) {
      debugPrint('Error recovering downloads: $e');
    }
  }
  
  /// Clean up resources when the service is no longer needed
  void dispose() {
    IsolateNameServer.removePortNameMapping(_portName);
    
    // Close all progress controllers
    for (final controller in _progressControllerMap.values) {
      controller.close();
    }
    _progressControllerMap.clear();
  }
  
  /// Static download callback that runs in the download isolate
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    debugPrint('Download callback: id=$id, status=$status, progress=$progress');
    final sendPort = IsolateNameServer.lookupPortByName(_portName);
    if (sendPort != null) {
      final taskStatus = DownloadTaskStatus.values[status];
      sendPort.send([id, taskStatus, progress]);
    }
  }
  
  /// Start downloading a lesson
  Future<String?> downloadLesson(Lesson lesson) async {
    try {
      debugPrint('Starting download for lesson ${lesson.title}');
      // Ensure the lesson has a videoUrl
      if (lesson.videoUrl == null || lesson.videoUrl!.isEmpty) {
        throw Exception('No video URL available for this lesson');
      }
      
      // Create directory for downloads
      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDocDir.path}/downloads');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }
      
      // File name for the download
      final fileName = 'lesson_${lesson.id}.mp4';
      final filePath = '${downloadsDir.path}/$fileName';
      
      debugPrint('Downloading to $filePath');
      
      // Initial progress notification
      _notifyProgress(lesson.id, DownloadProgress(
        progress: 0,
        status: DownloadTaskStatus.enqueued,
      ));
      
      // Start the download
      final taskId = await FlutterDownloader.enqueue(
        url: lesson.videoUrl!,
        savedDir: downloadsDir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      
      if (taskId == null) {
        throw Exception('Failed to start download');
      }
      
      debugPrint('Download started with taskId: $taskId');
      
      // Get the Hive box for downloaded lessons
      final box = await Hive.openBox<Lesson>(_boxName);
      
      // Store information about this download in Hive
      // We'll create a copy of the lesson with additional info
      final lessonCopy = Lesson(
        id: lesson.id,
        courseId: lesson.courseId,
        title: lesson.title,
        type: lesson.type,
        description: lesson.description,
        duration: lesson.duration,
        videoUrl: lesson.videoUrl,
        thumbnailUrl: lesson.thumbnailUrl,
        textContent: lesson.textContent,
        freePreview: lesson.freePreview,
        resources: lesson.resources,
        order: lesson.order,
        createdAt: lesson.createdAt,
        isDownloaded: false, // We'll set this to true when download completes
        localPath: filePath,
      );
      
      // Save the lesson to Hive with the taskId as the key
      await box.put(taskId, lessonCopy);

      // Store the taskId association with the lessonId
      final progressBox = await Hive.openBox<Map>(_progressBoxName);
      await progressBox.put(lesson.id, {'taskId': taskId});
      
      // Update progress with task ID
      _notifyProgress(lesson.id, DownloadProgress(
        progress: 0,
        status: DownloadTaskStatus.running,
        taskId: taskId,
      ));
      
      return taskId;
    } catch (e) {
      debugPrint('Error downloading lesson: $e');
      // Notify failure
      _notifyProgress(lesson.id, DownloadProgress(
        progress: 0,
        status: DownloadTaskStatus.failed,
      ));
      rethrow;
    }
  }
  
  /// Cancel a download in progress
  Future<void> cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
    
    // Remove from Hive
    final box = await Hive.openBox<Lesson>(_boxName);
    final lesson = box.get(taskId);
    if (lesson != null) {
      // Notify that the download was canceled
      _notifyProgress(lesson.id, DownloadProgress(
        progress: 0,
        status: DownloadTaskStatus.canceled,
      ));
    }
    await box.delete(taskId);
    
    // Clean up the task ID mapping
    final progressBox = await Hive.openBox<Map>(_progressBoxName);
    for (final key in progressBox.keys) {
      final map = progressBox.get(key);
      if (map != null && map['taskId'] == taskId) {
        await progressBox.delete(key);
        break;
      }
    }
  }
  
  /// Delete a downloaded lesson
  Future<void> deleteDownload(Lesson lesson) async {
    try {
      debugPrint('Deleting download for lesson ${lesson.title}');
      
      // Find the task for this lesson
      String? taskId = await _getTaskIdForLesson(lesson.id);
      
      // If we found a taskId, check if there's an active download
      if (taskId != null) {
        debugPrint('Found taskId $taskId for lesson ${lesson.id}');
        final tasks = await FlutterDownloader.loadTasks();
        if (tasks != null) {
          final task = tasks.where((t) => t.taskId == taskId).firstOrNull;
          if (task != null) {
            debugPrint('Found active task, removing it: ${task.status}');
            await FlutterDownloader.remove(
              taskId: taskId,
              shouldDeleteContent: true,
            );
          }
        }
      } else {
        // Try to find by URL
        final tasks = await FlutterDownloader.loadTasks();
        if (tasks != null) {
          for (final task in tasks) {
            if (task.url == lesson.videoUrl) {
              taskId = task.taskId;
              debugPrint('Found task by URL: $taskId');
              await FlutterDownloader.remove(
                taskId: taskId,
                shouldDeleteContent: true,
              );
              break;
            }
          }
        }
      }
      
      // Remove the file
      if (lesson.localPath != null) {
        final file = File(lesson.localPath!);
        if (await file.exists()) {
          debugPrint('Deleting file: ${lesson.localPath}');
          await file.delete();
        }
      }
      
      // Remove from Hive
      final box = await Hive.openBox<Lesson>(_boxName);
      
      // Look for the lesson by its ID
      String? lessonTaskId;
      for (final key in box.keys) {
        final storedLesson = box.get(key);
        if (storedLesson != null && storedLesson.id == lesson.id) {
          lessonTaskId = key.toString();
          await box.delete(key);
          break;
        }
      }
      
      // Clean up the progressBox
      final progressBox = await Hive.openBox<Map>(_progressBoxName);
      await progressBox.delete(lesson.id);
      
      // Notify that the download was removed
      _notifyProgress(lesson.id, DownloadProgress(
        progress: 0,
        status: DownloadTaskStatus.undefined,
      ));
      
    } catch (e) {
      debugPrint('Error deleting download: $e');
      rethrow;
    }
  }
  
  /// Get the task ID associated with a lesson ID
  Future<String?> _getTaskIdForLesson(String lessonId) async {
    try {
      final progressBox = await Hive.openBox<Map>(_progressBoxName);
      final map = progressBox.get(lessonId);
      return map?['taskId'] as String?;
    } catch (e) {
      debugPrint('Error getting taskId for lesson $lessonId: $e');
      return null;
    }
  }
  
  /// Update the download status in Hive
  Future<void> _updateDownloadStatus(String taskId, DownloadTaskStatus status, int progress) async {
    try {
      debugPrint('Updating download status: taskId=$taskId, status=$status, progress=$progress');
      final box = await Hive.openBox<Lesson>(_boxName);
      final lesson = box.get(taskId);
      
      if (lesson != null) {
        // Find the lessonId
        final lessonId = lesson.id;
        
        // Store current progress in a separate box for easier retrieval
        final progressBox = await Hive.openBox<Map>(_progressBoxName);
        await progressBox.put(lessonId, {
          'taskId': taskId,
          'progress': progress,
          'status': status.index,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        
        // Update progress for this lessonId
        _notifyProgress(lessonId, DownloadProgress(
          progress: progress,
          status: status,
          taskId: taskId,
        ));
        
        // If download is complete, update the lesson
        if (status == DownloadTaskStatus.complete) {
          debugPrint('Download complete for lesson $lessonId');
          
          final updatedLesson = Lesson(
            id: lesson.id,
            courseId: lesson.courseId,
            title: lesson.title,
            type: lesson.type,
            description: lesson.description,
            duration: lesson.duration,
            videoUrl: lesson.videoUrl,
            thumbnailUrl: lesson.thumbnailUrl,
            textContent: lesson.textContent,
            freePreview: lesson.freePreview,
            resources: lesson.resources,
            order: lesson.order,
            createdAt: lesson.createdAt,
            isDownloaded: true,
            localPath: lesson.localPath,
          );
          
          await box.put(taskId, updatedLesson);
          
          // Update progress one more time to ensure UI gets final state
          _notifyProgress(lessonId, DownloadProgress(
            progress: 100,
            status: DownloadTaskStatus.complete,
            taskId: taskId,
          ));
        } 
        // If download failed or was canceled, remove it from the box
        else if (status == DownloadTaskStatus.failed || status == DownloadTaskStatus.canceled) {
          await box.delete(taskId);
          // Clean up the progressBox
          await progressBox.delete(lessonId);
          
          // Notify with failed state
          _notifyProgress(lessonId, DownloadProgress(
            progress: 0,
            status: status,
            taskId: null,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error updating download status: $e');
    }
  }
  
  /// Notify subscribers of download progress for a lesson
  void _notifyProgress(String lessonId, DownloadProgress progress) {
    debugPrint('Notifying progress for lesson $lessonId: ${progress.progress}%');
    if (!_progressControllerMap.containsKey(lessonId)) {
      debugPrint('Creating new progress controller for lesson $lessonId');
      _progressControllerMap[lessonId] = StreamController<DownloadProgress>.broadcast();
    }
    _progressControllerMap[lessonId]!.add(progress);
  }
  
  /// Get a stream of download progress for a lesson
  Stream<DownloadProgress> getDownloadProgress(String lessonId) async* {
    debugPrint('Getting download progress for lesson $lessonId');
    
    // Check if a task ID exists for this lesson
    final taskId = await _getTaskIdForLesson(lessonId);
    debugPrint('Task ID for lesson $lessonId: $taskId');
    
    // If we have a taskId, check the current status
    if (taskId != null) {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks != null) {
        final task = tasks.where((t) => t.taskId == taskId).firstOrNull;
        if (task != null) {
          final progress = DownloadProgress(
            progress: task.progress,
            status: task.status,
            taskId: taskId,
          );
          debugPrint('Yielding initial progress for $lessonId: ${progress.progress}%');
          yield progress;
        }
      }
    } else {
      // Check if the lesson is already downloaded
      final box = await Hive.openBox<Lesson>(_boxName);
      for (final lesson in box.values) {
        if (lesson.id == lessonId && lesson.isDownloaded) {
          debugPrint('Lesson $lessonId is already downloaded');
          yield DownloadProgress(
            progress: 100,
            status: DownloadTaskStatus.complete,
          );
          return;
        }
      }
      
      // If we get here, there's no download in progress or completed
      debugPrint('No download found for lesson $lessonId, yielding initial status');
      yield DownloadProgress.initial;
    }
    
    // Create a controller if needed
    if (!_progressControllerMap.containsKey(lessonId)) {
      debugPrint('Creating progress controller for lesson $lessonId');
      _progressControllerMap[lessonId] = StreamController<DownloadProgress>.broadcast();
    }
    
    // Yield values from the stream
    debugPrint('Listening to progress updates for lesson $lessonId');
    yield* _progressControllerMap[lessonId]!.stream;
  }
  
  /// Get a stream of downloaded lessons
  Stream<List<Lesson>> getDownloadedLessons() async* {
    final box = await Hive.openBox<Lesson>(_boxName);
    
    // Initial yield
    yield box.values.where((lesson) => lesson.isDownloaded).toList();
    
    // Watch for changes
    yield* box.watch().map((_) {
      return box.values.where((lesson) => lesson.isDownloaded).toList();
    });
  }
  
  /// Get a stream of a specific lesson's download status
  Stream<bool> getLessonDownloadStatus(String lessonId) async* {
    final box = await Hive.openBox<Lesson>(_boxName);
    
    // Check if lesson exists in Hive
    bool isDownloaded = false;
    for (final lesson in box.values) {
      if (lesson.id == lessonId) {
        isDownloaded = lesson.isDownloaded;
        break;
      }
    }
    
    // Initial yield
    yield isDownloaded;
    
    // Watch for changes
    yield* box.watch().map((_) {
      for (final lesson in box.values) {
        if (lesson.id == lessonId) {
          return lesson.isDownloaded;
        }
      }
      return false;
    });
  }
} 