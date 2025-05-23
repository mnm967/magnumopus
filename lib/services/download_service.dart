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

/// Provider to get download progress for a specific lesson
final lessonDownloadProgressProvider = StreamProvider.family<int, String>((ref, lessonId) {
  return ref.watch(downloadServiceProvider).getDownloadProgress(lessonId);
});

/// Service to handle downloading and storing video lessons
@pragma('vm:entry-point')
class DownloadService {
  static const _boxName = 'downloaded_lessons';
  
  /// Port name for communication with the download isolate
  static const _portName = 'downloader_send_port';
  
  /// Send port for receiving download status updates
  final ReceivePort _port = ReceivePort();

  /// Map to store current download progress
  final Map<String, StreamController<int>> _progressControllers = {};
  
  /// Initialize the download service
  Future<void> initialize() async {
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
      
      // Update progress for any active downloads
      _updateProgress(taskId, progress);
      
      _updateDownloadStatus(taskId, status, progress);
    });
  }
  
  /// Clean up resources when the service is no longer needed
  void dispose() {
    IsolateNameServer.removePortNameMapping(_portName);
    
    // Close all progress controllers
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
  }
  
  /// Static download callback that runs in the download isolate
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final sendPort = IsolateNameServer.lookupPortByName(_portName);
    if (sendPort != null) {
      final taskStatus = DownloadTaskStatus.values[status];
      sendPort.send([id, taskStatus, progress]);
    }
  }

  /// Update progress for a download task
  void _updateProgress(String taskId, int progress) {
    // Check if we have a task ID mapping to a lesson ID
    _getTaskToLessonMapping().then((taskToLessonMap) {
      final lessonId = taskToLessonMap[taskId];
      if (lessonId != null) {
        // Get or create a controller for this lesson
        if (!_progressControllers.containsKey(lessonId)) {
          _progressControllers[lessonId] = StreamController<int>.broadcast();
        }
        
        // Add the progress update to the stream
        if (!_progressControllers[lessonId]!.isClosed) {
          _progressControllers[lessonId]!.add(progress);
        }
        
        // If download is complete or failed, close the controller
        if (progress == 100) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_progressControllers.containsKey(lessonId) && 
                !_progressControllers[lessonId]!.isClosed) {
              _progressControllers[lessonId]!.close();
              _progressControllers.remove(lessonId);
            }
          });
        }
      }
    });
  }
  
  /// Get a mapping from task IDs to lesson IDs
  Future<Map<String, String>> _getTaskToLessonMapping() async {
    final Map<String, String> taskToLessonMap = {};
    
    // Get the box containing downloaded lessons
    final box = await Hive.openBox<Lesson>(_boxName);
    
    // For each entry, store the task ID to lesson ID mapping
    for (final entry in box.toMap().entries) {
      final taskId = entry.key.toString();
      final lesson = entry.value;
      taskToLessonMap[taskId] = lesson.id;
    }
    
    return taskToLessonMap;
  }
  
  /// Get a stream of download progress for a specific lesson
  Stream<int> getDownloadProgress(String lessonId) async* {
    // Initial progress value
    yield 0;
    
    // Check if we have an active controller for this lesson
    if (_progressControllers.containsKey(lessonId)) {
      yield* _progressControllers[lessonId]!.stream;
    } else {
      // Create a new controller for this lesson
      _progressControllers[lessonId] = StreamController<int>.broadcast();
      
      // Check if there's an active download task for this lesson
      final taskId = await _getTaskIdForLesson(lessonId);
      if (taskId != null) {
        // Get current progress from FlutterDownloader
        final tasks = await FlutterDownloader.loadTasks();
        if (tasks != null) {
          for (final task in tasks) {
            if (task.taskId == taskId) {
              // Add current progress to the stream
              _progressControllers[lessonId]!.add(task.progress);
              break;
            }
          }
        }
      }
      
      yield* _progressControllers[lessonId]!.stream;
    }
  }
  
  /// Get the task ID for a lesson
  Future<String?> _getTaskIdForLesson(String lessonId) async {
    final taskToLessonMap = await _getTaskToLessonMapping();
    
    // Find the task ID where the lesson ID matches
    for (final entry in taskToLessonMap.entries) {
      if (entry.value == lessonId) {
        return entry.key;
      }
    }
    
    return null;
  }
  
  /// Start downloading a lesson
  Future<void> downloadLesson(Lesson lesson) async {
    try {
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
      
      // Start the download
      final taskId = await FlutterDownloader.enqueue(
        url: lesson.videoUrl!,
        savedDir: downloadsDir.path,
        fileName: 'lesson_${lesson.id}.mp4',
        showNotification: true,
        openFileFromNotification: true,
      );
      
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
        localPath: '${downloadsDir.path}/lesson_${lesson.id}.mp4',
      );
      
      // Save the lesson to Hive with the taskId as the key
      await box.put(taskId, lessonCopy);
      
      // Create a stream controller for this download if it doesn't exist
      if (!_progressControllers.containsKey(lesson.id)) {
        _progressControllers[lesson.id] = StreamController<int>.broadcast();
      }
      
    } catch (e) {
      debugPrint('Error downloading lesson: $e');
      rethrow;
    }
  }
  
  /// Cancel a download in progress
  Future<void> cancelDownload(String lessonId) async {
    try {
      // Find the task ID for this lesson
      final taskId = await _getTaskIdForLesson(lessonId);
      if (taskId != null) {
        await FlutterDownloader.cancel(taskId: taskId);
        
        // Remove from Hive
        final box = await Hive.openBox<Lesson>(_boxName);
        await box.delete(taskId);
        
        // Close and remove the progress controller
        if (_progressControllers.containsKey(lessonId)) {
          if (!_progressControllers[lessonId]!.isClosed) {
            _progressControllers[lessonId]!.close();
          }
          _progressControllers.remove(lessonId);
        }
      }
    } catch (e) {
      debugPrint('Error cancelling download: $e');
      rethrow;
    }
  }
  
  /// Delete a downloaded lesson
  Future<void> deleteDownload(Lesson lesson) async {
    try {
      // Find the task for this lesson
      final tasks = await FlutterDownloader.loadTasks();
      String? taskId;
      
      if (tasks != null) {
        for (final task in tasks) {
          if (task.url == lesson.videoUrl) {
            taskId = task.taskId;
            break;
          }
        }
      }
      
      // If the task exists, remove it
      if (taskId != null) {
        await FlutterDownloader.remove(
          taskId: taskId,
          shouldDeleteContent: true,
        );
      }
      
      // Remove the file
      if (lesson.localPath != null) {
        final file = File(lesson.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Remove from Hive
      final box = await Hive.openBox<Lesson>(_boxName);
      
      // Look for the lesson by its ID
      for (final key in box.keys) {
        final storedLesson = box.get(key);
        if (storedLesson != null && storedLesson.id == lesson.id) {
          await box.delete(key);
          break;
        }
      }
      
      // Close and remove the progress controller if it exists
      if (_progressControllers.containsKey(lesson.id)) {
        if (!_progressControllers[lesson.id]!.isClosed) {
          _progressControllers[lesson.id]!.close();
        }
        _progressControllers.remove(lesson.id);
      }
    } catch (e) {
      debugPrint('Error deleting download: $e');
      rethrow;
    }
  }
  
  /// Update the download status in Hive
  Future<void> _updateDownloadStatus(String taskId, DownloadTaskStatus status, int progress) async {
    try {
      final box = await Hive.openBox<Lesson>(_boxName);
      final lesson = box.get(taskId);
      
      if (lesson != null) {
        // If download is complete, update the lesson
        if (status == DownloadTaskStatus.complete) {
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
          
          // Close the progress controller with a final 100% update
          if (_progressControllers.containsKey(lesson.id)) {
            if (!_progressControllers[lesson.id]!.isClosed) {
              _progressControllers[lesson.id]!.add(100);
              // We'll close it after a delay to ensure the UI can show 100%
            }
          }
        } 
        // If download failed, remove it from the box
        else if (status == DownloadTaskStatus.failed || status == DownloadTaskStatus.canceled) {
          await box.delete(taskId);
          
          // Send error to progress controller and close it
          if (_progressControllers.containsKey(lesson.id)) {
            if (!_progressControllers[lesson.id]!.isClosed) {
              _progressControllers[lesson.id]!.addError('Download ${status.toString().split('.').last}');
              _progressControllers[lesson.id]!.close();
              _progressControllers.remove(lesson.id);
            }
          }
        }
        // If download is in progress, update the progress controller
        else if (status == DownloadTaskStatus.running) {
          if (_progressControllers.containsKey(lesson.id)) {
            if (!_progressControllers[lesson.id]!.isClosed) {
              _progressControllers[lesson.id]!.add(progress);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating download status: $e');
    }
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