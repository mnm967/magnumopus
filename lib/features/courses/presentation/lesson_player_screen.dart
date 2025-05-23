import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_card.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';
import 'package:magnumopus/services/download_service.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:magnumopus/core/providers/user_provider.dart';
import 'package:magnumopus/data/models/user_model.dart';

/// Provider to get a specific lesson
final lessonProvider = FutureProvider.family<Lesson?, LessonRequest>((ref, request) async {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getLesson(
    courseId: request.courseId,
    lessonId: request.lessonId,
  );
});

/// Provider to get comments for a lesson
final lessonCommentsProvider = StreamProvider.family<List<Comment>, String>((ref, lessonId) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getComments(lessonId);
});

/// Provider for demo video URL for testing
final demoVideoUrlProvider = Provider<String>((ref) {
  // Use a direct HTTPS URL that is known to work with video_player
  return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
});

/// Data class to hold courseId and lessonId for lesson requests
class LessonRequest {
  final String courseId;
  final String lessonId;
  
  const LessonRequest({
    required this.courseId,
    required this.lessonId,
  });
  
  @override
  int get hashCode => Object.hash(courseId, lessonId);
  
  @override
  bool operator ==(Object other) {
    return other is LessonRequest &&
        other.courseId == courseId &&
        other.lessonId == lessonId;
  }
}

/// Screen that plays a specific lesson's content
class LessonPlayerScreen extends HookConsumerWidget {
  final String courseId;
  final String lessonId;
  final bool isOfflineMode;
  final String? offlineVideoPath;
  
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
    this.isOfflineMode = false,
    this.offlineVideoPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Enter landscape mode for video viewing
    //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    
    final lessonRequest = LessonRequest(courseId: courseId, lessonId: lessonId);
    final lessonAsync = ref.watch(lessonProvider(lessonRequest));
    final commentsAsync = ref.watch(lessonCommentsProvider(lessonId));
    
    // Demo video URL for testing
    final demoVideoUrl = ref.watch(demoVideoUrlProvider);
    
    // Clean up controller when widget is disposed
    useEffect(() {
      return () {
        // Reset orientation when leaving the screen
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      };
    }, const []);
    
    // If in offline mode, use the cached data instead of loading from network
    if (isOfflineMode && offlineVideoPath != null) {
      return _buildOfflinePlayerScreen(context, ref);
    }
    
    // Normal online mode
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: lessonAsync.when(
        data: (lesson) {
          if (lesson == null) {
            return const Center(
              child: Text('Lesson not found'),
            );
          }
          
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player
                _buildVideoPlayer(context, lesson, demoVideoUrl),
                
                // Lesson content
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        // Tabs
                        TabBar(
                          labelColor: AppTheme.primaryColor,
                          unselectedLabelColor: AppTheme.secondaryTextColor,
                          indicatorColor: AppTheme.primaryColor,
                          tabs: const [
                            Tab(text: 'Description'),
                            Tab(text: 'Comments'),
                          ],
                        ),
                        
                        // Tab content
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Description tab
                              _buildDescriptionTab(context, lesson),
                              
                              // Comments tab
                              _buildCommentsTab(context, ref, commentsAsync),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading lesson: $error',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
  
  /// Build the offline player screen
  Widget _buildOfflinePlayerScreen(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Offline Lesson'),
        backgroundColor: AppTheme.cardColor,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline video player
            _buildOfflineVideoPlayer(context),
            
            // Offline content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You are viewing this lesson offline.',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Comments and other interactive features are not available in offline mode.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the offline video player
  Widget _buildOfflineVideoPlayer(BuildContext context) {
    // Use offline video path
    final videoController = useMemoized(() {
      if (offlineVideoPath != null) {
        return VideoPlayerController.file(File(offlineVideoPath!));
      }
      return null;
    }, [offlineVideoPath]);
    
    final videoControllerInitialized = useState(false);
    final isPlaying = useState(false);
    
    // Initialize controller if available
    useEffect(() {
      if (videoController != null) {
        videoController.initialize().then((_) {
          videoControllerInitialized.value = true;
        });
        
        return () {
          videoController.dispose();
        };
      }
      return null;
    }, [videoController]);
    
    return Container(
      width: double.infinity,
      height: 240,
      color: Colors.black,
      child: Stack(
        children: [
          // Video from local file
          Center(
            child: videoController != null && videoControllerInitialized.value
                ? AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        color: AppTheme.primaryColor,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Offline Video',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Path: ${offlineVideoPath?.split('/').last}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
          
          // Play button overlay (only if video is initialized)
          if (videoController != null && videoControllerInitialized.value)
            Center(
              child: GestureDetector(
                onTap: () {
                  if (isPlaying.value) {
                    videoController.pause();
                  } else {
                    videoController.play();
                  }
                  isPlaying.value = !isPlaying.value;
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying.value ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
          
          // Add a tap gesture detector to the entire video area
          Positioned.fill(
            child: Row(
              children: [
                // Left side - double tap to rewind
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: (videoController != null && videoControllerInitialized.value)
                      ? () {
                          debugPrint('Double tap left - rewind 10 seconds');
                          final newPosition = Duration(
                            milliseconds: max(0, videoController.value.position.inMilliseconds - 10000)
                          );
                          videoController.seekTo(newPosition);
                        }
                      : null,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
                // Center area - play/pause on tap
                Expanded(
                  child: GestureDetector(
                    onTap: (videoController != null && videoControllerInitialized.value)
                      ? () {
                          debugPrint('Video tap detected, playing: ${isPlaying.value}');
                          if (isPlaying.value) {
                            videoController.pause();
                          } else {
                            videoController.play();
                          }
                          isPlaying.value = !isPlaying.value;
                        }
                      : null,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
                // Right side - double tap to skip forward
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: (videoController != null && videoControllerInitialized.value)
                      ? () {
                          debugPrint('Double tap right - skip 10 seconds');
                          final duration = videoController.value.duration;
                          final newPosition = Duration(
                            milliseconds: min(
                              duration.inMilliseconds, 
                              videoController.value.position.inMilliseconds + 10000
                            )
                          );
                          videoController.seekTo(newPosition);
                        }
                      : null,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
          
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build the video player section
  Widget _buildVideoPlayer(BuildContext context, Lesson lesson, String demoVideoUrl) {
    // Use the demo video URL instead of the lesson video URL for testing
    final videoUrl = lesson.videoUrl ?? demoVideoUrl;
    debugPrint('Loading video from URL: $videoUrl');
    
    // Initialize video controller
    final videoController = useMemoized(() => VideoPlayerController.network(videoUrl), [videoUrl]);
    final videoControllerInitialized = useState(false);
    final isPlaying = useState(false);
    final currentPosition = useState(Duration.zero);
    final errorMessage = useState<String?>(null);
    
    // Initialize the controller
    useEffect(() {
      debugPrint('Initializing video controller...');
      videoController.initialize().then((_) {
        debugPrint('Video controller initialized successfully');
        videoControllerInitialized.value = true;
        // Add listener to update position
        videoController.addListener(() {
          currentPosition.value = videoController.value.position;
        });
      }).catchError((error) {
        debugPrint('Error initializing video controller: $error');
        errorMessage.value = error.toString();
      });
      
      return () {
        debugPrint('Disposing video controller');
        videoController.dispose();
      };
    }, [videoController]);
    
    // Calculate video progress
    final progress = videoControllerInitialized.value && videoController.value.duration.inMilliseconds > 0
        ? currentPosition.value.inMilliseconds / videoController.value.duration.inMilliseconds
        : 0.0;
        
    return Container(
      width: double.infinity,
      height: 240,
      color: Colors.black,
      child: Stack(
        children: [
          // Actual video player
          Center(
            child: errorMessage.value != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          errorMessage.value!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : videoControllerInitialized.value
                    ? AspectRatio(
                        aspectRatio: videoController.value.aspectRatio,
                        child: VideoPlayer(videoController),
                      )
                    : CachedNetworkImage(
                        imageUrl: lesson.thumbnailUrl ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => _buildVideoPlaceholder(),
                        errorWidget: (context, url, error) => _buildVideoPlaceholder(),
                      ),
          ),
          
          // Video controls overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Positioned.fill to make sure taps work across the entire video
          Positioned.fill(
            child: Row(
              children: [
                // Left side - double tap to rewind
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: (videoControllerInitialized.value && errorMessage.value == null)
                      ? () {
                          debugPrint('Double tap left - rewind 10 seconds');
                          final newPosition = Duration(
                            milliseconds: max(0, currentPosition.value.inMilliseconds - 10000)
                          );
                          videoController.seekTo(newPosition);
                        }
                      : null,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
                // Center area - play/pause on tap
                Expanded(
                  child: GestureDetector(
                    onTap: (videoControllerInitialized.value && errorMessage.value == null)
                      ? () {
                          debugPrint('Video tap detected, playing: ${isPlaying.value}');
                          if (isPlaying.value) {
                            videoController.pause();
                          } else {
                            videoController.play();
                          }
                          isPlaying.value = !isPlaying.value;
                        }
                      : null,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
                // Right side - double tap to skip forward
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: (videoControllerInitialized.value && errorMessage.value == null)
                      ? () {
                          debugPrint('Double tap right - skip 10 seconds');
                          final duration = videoController.value.duration;
                          final newPosition = Duration(
                            milliseconds: min(
                              duration.inMilliseconds, 
                              currentPosition.value.inMilliseconds + 10000
                            )
                          );
                          videoController.seekTo(newPosition);
                        }
                      : null,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
          
          // Play button
          if (errorMessage.value == null) 
            Center(
              child: videoControllerInitialized.value
                  ? GestureDetector(
                      onTap: () {
                        debugPrint('Play button tap detected, playing: ${isPlaying.value}');
                        if (isPlaying.value) {
                          videoController.pause();
                        } else {
                          videoController.play();
                        }
                        isPlaying.value = !isPlaying.value;
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying.value ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 42,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    ).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),
          ),
          
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Video title
          Positioned(
            top: 16,
            left: 64,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Download button
                Consumer(
                  builder: (context, ref, _) {
                    final downloadStatus = ref.watch(lessonDownloadStatusProvider(lesson.id));
                    final downloadProgress = ref.watch(downloadProgressProvider(lesson.id));
                    
                    return downloadProgress.when(
                      data: (progress) {
                        // If downloading is in progress, show progress indicator
                        if (progress.isActive) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer circle to make it more visible
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Progress circle
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  value: progress.progress / 100,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3,
                                ),
                              ),
                              // Progress text
                              Text(
                                "${progress.progress}%",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        } 
                        // If download completed, show appropriate icon
                        else if (progress.isCompleted) {
                          return IconButton(
                            icon: const Icon(
                              Icons.download_done,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _deleteDownload(context, ref, lesson);
                            },
                          );
                        }
                        // For all other states (not downloaded or error)
                        return IconButton(
                          icon: const Icon(
                            Icons.download_for_offline_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _downloadLesson(context, ref, lesson);
                          },
                        );
                      },
                      loading: () => const SizedBox(
                        width: 48,
                        height: 48,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
          ),
          
          // Video progress bar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Progress bar with gesture detector for seeking
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth;
                    // Ensure progress is between 0.0 and 1.0 before calculating dotPosition
                    final clampedProgress = progress.clamp(0.0, 1.0);
                    final dotPosition = (clampedProgress * barWidth);

                    return SizedBox(
                      height: 24,  // Increased height for easier touch target
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // The actual progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress, // Use original progress for the bar itself
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              minHeight: 4,
                            ),
                          ),
                          
                          // Gesture detector for seeking
                          Positioned.fill(
                            child: GestureDetector(
                              onHorizontalDragStart: (videoControllerInitialized.value && errorMessage.value == null)
                                  ? (_) {
                                      // Pause video while seeking
                                      if (isPlaying.value) {
                                        videoController.pause();
                                      }
                                    }
                                  : null,
                              onHorizontalDragUpdate: (videoControllerInitialized.value && errorMessage.value == null)
                                  ? (details) {
                                      // Use constraints.maxWidth for accurate seeking relative to the bar
                                      final position = details.localPosition.dx / barWidth;
                                      final clampedPosition = position.clamp(0.0, 1.0);
                                      final duration = videoController.value.duration;
                                      final newPosition = Duration(
                                        milliseconds: (clampedPosition * duration.inMilliseconds).toInt(),
                                      );
                                      // Update current position for immediate UI feedback
                                      currentPosition.value = newPosition;
                                      videoController.seekTo(newPosition);
                                    }
                                  : null,
                              onHorizontalDragEnd: (videoControllerInitialized.value && errorMessage.value == null)
                                  ? (_) {
                                      // Resume playing if it was playing before
                                      if (isPlaying.value) {
                                        videoController.play();
                                      }
                                    }
                                  : null,
                              onTapUp: (videoControllerInitialized.value && errorMessage.value == null)
                                  ? (details) {
                                     // Use constraints.maxWidth for accurate seeking relative to the bar
                                      final position = details.localPosition.dx / barWidth;
                                      final clampedPosition = position.clamp(0.0, 1.0);
                                      final duration = videoController.value.duration;
                                      final newPosition = Duration(
                                        milliseconds: (clampedPosition * duration.inMilliseconds).toInt(),
                                      );
                                      videoController.seekTo(newPosition);
                                    }
                                  : null,
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          
                          // Thumb indicator
                          if (videoControllerInitialized.value && progress >= 0 && progress <=1)
                            Positioned(
                              left: dotPosition - 6, // Center the 12px dot
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                
                // Time info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(currentPosition.value),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      videoControllerInitialized.value 
                          ? _formatDuration(videoController.value.duration)
                          : lesson.durationFormatted,
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
        ],
      ),
    );
  }
  
  /// Format duration to MM:SS format
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  /// Build a placeholder for video content
  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library,
              color: Colors.white.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Video Placeholder',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'In a real app, this would be a video player',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the description tab content
  Widget _buildDescriptionTab(BuildContext context, Lesson lesson) {
    final showAiSummary = useState(false);
    final isGeneratingAiSummary = useState(false);
    final animationController = useAnimationController(duration: const Duration(milliseconds: 1500));
    
    // Animation effect for AI summary generation
    useEffect(() {
      if (isGeneratingAiSummary.value) {
        animationController.repeat();
      } else {
        animationController.reset();
      }
      return null;
    }, [isGeneratingAiSummary.value]);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson title
          Text(
            lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          
          if (lesson.description != null && lesson.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            // Lesson description
            Text(
              lesson.description!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
          
          // AI Summary Section
          if (showAiSummary.value) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Summary',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      // Close button
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white54,
                          size: 16,
                        ),
                        onPressed: () {
                          showAiSummary.value = false;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This lesson explores the fundamental concepts of the topic, covering the main principles and practical applications. It addresses common challenges and provides solutions with detailed examples.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
                ],
              ),
            ),
          ],
          
          // Additional resources section
          if (lesson.resources.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Additional Resources',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            
            // Resources list
            ...lesson.resources.entries.map((entry) {
              return ListTile(
                leading: const Icon(
                  Icons.attach_file,
                  color: AppTheme.primaryColor,
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  entry.value is String ? entry.value as String : 'Resource',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  // Open resource logic
                },
              );
            }).toList(),
          ],
          
          // AI summary button
          const SizedBox(height: 32),
          Center(
            child: AppButton(
              label: isGeneratingAiSummary.value 
                  ? 'Generating Summary...' 
                  : 'Generate AI Summary',
              style: AppButtonStyle.primary,
              icon: isGeneratingAiSummary.value
                  ? null
                  : Icons.auto_awesome,
              onPressed: () {
                if (isGeneratingAiSummary.value) return;
                
                isGeneratingAiSummary.value = true;
                
                // Simulate AI summary generation
                Future.delayed(const Duration(seconds: 2), () {
                  isGeneratingAiSummary.value = false;
                  showAiSummary.value = true;
                });
              },
              isLoading: isGeneratingAiSummary.value,
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  /// Build the comments tab content
  Widget _buildCommentsTab(BuildContext context, WidgetRef ref, AsyncValue<List<Comment>> commentsAsync) {
    final commentController = useTextEditingController();
    final isSubmitting = useState(false);
    final currentUserAsync = ref.watch(currentUserProvider);

    // Function to submit a new comment
    void submitComment() async {
      if (commentController.text.trim().isEmpty) return;
      
      // Only submit if we have a user
      final currentUser = currentUserAsync.valueOrNull;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to comment'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      
      isSubmitting.value = true;
      try {
        final courseRepository = ref.read(courseRepositoryProvider);
        await courseRepository.addComment(
          lessonId: lessonId,
          text: commentController.text.trim(),
          userId: currentUser.id,
          userName: currentUser.name,
        );
        commentController.clear();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding comment: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    return commentsAsync.when(
      data: (comments) {
        return Column(
          children: [
            // Comments list
            Expanded(
              child: comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to comment',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return currentUserAsync.when(
                          data: (currentUser) => _buildCommentItem(context, comment, currentUser),
                          loading: () => _buildCommentItem(context, comment, null),
                          error: (_, __) => _buildCommentItem(context, comment, null),
                        );
                      },
                    ),
            ),
            
            // Add comment field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // User avatar
                  currentUserAsync.when(
                    data: (currentUser) => CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      backgroundImage: currentUser?.avatarUrl != null
                          ? NetworkImage(currentUser!.avatarUrl!)
                          : null,
                      child: currentUser?.avatarUrl == null
                          ? Text(
                              currentUser?.name.isNotEmpty == true
                                  ? currentUser!.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    loading: () => const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    error: (_, __) => CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.errorColor.withOpacity(0.2),
                      child: const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Comment text field
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => submitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Send button
                  GestureDetector(
                    onTap: isSubmitting.value ? null : submitComment,
                    child: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      radius: 20,
                      child: isSubmitting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 16,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: AppLoadingIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading comments: $error',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
  
  /// Build a comment item
  Widget _buildCommentItem(BuildContext context, Comment comment, User? currentUser) {
    final isCurrentUser = currentUser != null && comment.userId == currentUser.id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isCurrentUser 
                ? AppTheme.primaryColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            backgroundImage: comment.userAvatarUrl != null
                ? NetworkImage(comment.userAvatarUrl!)
                : isCurrentUser && currentUser.avatarUrl != null
                    ? NetworkImage(currentUser.avatarUrl!)
                    : null,
            child: (comment.userAvatarUrl == null && 
                   !(isCurrentUser && currentUser.avatarUrl != null))
                ? Text(
                    comment.userName.isNotEmpty
                        ? comment.userName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: isCurrentUser ? AppTheme.primaryColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and timestamp
                Row(
                  children: [
                    Text(
                      isCurrentUser ? currentUser.name : comment.userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Comment text
                Text(
                  comment.text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                
                // Comment actions
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // Reply logic
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            color: AppTheme.primaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        // Like logic
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.thumb_up_outlined,
                            size: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Like',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Format a timestamp to a readable string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
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
      
      final taskId = await downloadService.downloadLesson(lesson);
      
      if (taskId != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Started downloading "${lesson.title}"'),
              backgroundColor: AppTheme.successColor,
              action: SnackBarAction(
                label: 'View Downloads',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to downloads screen
                  Navigator.of(context).pushNamed('/downloads');
                },
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to start download - no task ID returned');
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
} 