import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

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

/// Service to handle downloading and storing video lessons
@pragma('vm:entry-point')
class DownloadService {
  static const _boxName = 'downloaded_lessons';
  
  /// Port name for communication with the download isolate
  static const _portName = 'downloader_send_port';
  
  /// Send port for receiving download status updates
  final ReceivePort _port = ReceivePort();
  
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
      
      _updateDownloadStatus(taskId, status, progress);
    });
  }
  
  /// Clean up resources when the service is no longer needed
  void dispose() {
    IsolateNameServer.removePortNameMapping(_portName);
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
      
    } catch (e) {
      debugPrint('Error downloading lesson: $e');
      rethrow;
    }
  }
  
  /// Cancel a download in progress
  Future<void> cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
    
    // Remove from Hive
    final box = await Hive.openBox<Lesson>(_boxName);
    await box.delete(taskId);
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
        } 
        // If download failed, remove it from the box
        else if (status == DownloadTaskStatus.failed || status == DownloadTaskStatus.canceled) {
          await box.delete(taskId);
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