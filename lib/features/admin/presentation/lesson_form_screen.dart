import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';
import 'package:magnumopus/features/courses/presentation/course_detail_screen.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

/// Provider for managing form state
final lessonFormStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Screen for creating or editing a lesson
class LessonFormScreen extends HookConsumerWidget {
  final String courseId;
  final Lesson? lesson;
  
  const LessonFormScreen({
    super.key,
    required this.courseId,
    this.lesson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(lessonFormStateProvider);
    final courseAsync = ref.watch(courseProvider(courseId));
    
    // Controllers
    final titleController = TextEditingController(text: lesson?.title ?? '');
    final descriptionController = TextEditingController(text: lesson?.description ?? '');
    final textContentController = TextEditingController(text: lesson?.textContent ?? '');
    
    // State variables
    final selectedType = useState<String>(lesson?.type ?? 'video');
    final freePreview = useState<bool>(lesson?.freePreview ?? false);
    final duration = useState<int>(lesson?.duration ?? 0);
    final videoFile = useState<File?>(null);
    final videoUrl = useState<String?>(lesson?.videoUrl);
    final thumbnailFile = useState<File?>(null);
    final thumbnailUrl = useState<String?>(lesson?.thumbnailUrl);
    final resources = useState<Map<String, dynamic>>(
      lesson?.resources ?? <String, dynamic>{},
    );
    final newResourceName = useState<String>('');
    final isUploading = useState<bool>(false);
    final videoController = useState<VideoPlayerController?>(null);
    
    // Load video if URL exists
    useEffect(() {
      if (videoUrl.value != null) {
        videoController.value = VideoPlayerController.network(videoUrl.value!)
          ..initialize().then((_) {
            if (duration.value == null || duration.value == 0) {
              duration.value = videoController.value!.value.duration.inSeconds;
            }
          });
      }
      return () {
        videoController.value?.dispose();
      };
    }, [videoUrl.value]);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(lesson == null ? 'Create Lesson' : 'Edit Lesson'),
      ),
      body: formState.when(
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              const Text(
                'Lesson Title',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter lesson title',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description field
              const Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter lesson description',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Lesson type selector
              const Text(
                'Lesson Type',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildTypeSelector(selectedType),
              const SizedBox(height: 16),
              
              // Free preview toggle
              Row(
                children: [
                  Switch(
                    value: freePreview.value,
                    onChanged: (value) {
                      freePreview.value = value;
                    },
                    activeColor: AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Make this lesson available as a free preview',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Video content
              if (selectedType.value == 'video')
                _buildVideoSection(
                  context,
                  videoFile,
                  videoUrl,
                  videoController,
                  thumbnailFile,
                  thumbnailUrl,
                  duration,
                  isUploading,
                ),
              
              // Text content
              if (selectedType.value == 'text')
                _buildTextSection(textContentController),
              
              const SizedBox(height: 24),
              
              // Resources section
              _buildResourcesSection(
                context,
                resources,
                newResourceName,
                isUploading,
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: lesson == null ? 'Create Lesson' : 'Save Changes',
                  style: AppButtonStyle.primary,
                  isLoading: isUploading.value,
                  onPressed: isUploading.value
                      ? null
                      : () => _saveLesson(
                          context,
                          ref,
                          titleController.text,
                          descriptionController.text,
                          selectedType.value,
                          textContentController.text,
                          freePreview.value,
                          duration.value ?? 0,
                          videoFile.value,
                          videoUrl.value,
                          thumbnailFile.value,
                          thumbnailUrl.value,
                          resources.value,
                          isUploading,
                        ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: AppLoadingIndicator(),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
  
  /// Build the lesson type selector
  Widget _buildTypeSelector(ValueNotifier<String> selectedType) {
    return Row(
      children: [
        _buildTypeOption(
          label: 'Video',
          value: 'video',
          selectedType: selectedType,
          icon: Icons.video_library,
        ),
        const SizedBox(width: 16),
        _buildTypeOption(
          label: 'Text',
          value: 'text',
          selectedType: selectedType,
          icon: Icons.article,
        ),
      ],
    );
  }
  
  /// Build a single type option
  Widget _buildTypeOption({
    required String label,
    required String value,
    required ValueNotifier<String> selectedType,
    required IconData icon,
  }) {
    final isSelected = selectedType.value == value;
    
    return Expanded(
      child: InkWell(
        onTap: () => selectedType.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build the video section
  Widget _buildVideoSection(
    BuildContext context,
    ValueNotifier<File?> videoFile,
    ValueNotifier<String?> videoUrl,
    ValueNotifier<VideoPlayerController?> videoController,
    ValueNotifier<File?> thumbnailFile,
    ValueNotifier<String?> thumbnailUrl,
    ValueNotifier<int?> duration,
    ValueNotifier<bool> isUploading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        
        // Video preview or upload button
        if (videoFile.value != null)
          // Local video preview
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.video_file,
                  size: 64,
                  color: Colors.white54,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Text(
                      'Selected video: ${path.basename(videoFile.value!.path)}',
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (videoUrl.value != null && videoController.value != null)
          // Existing video preview
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (videoController.value!.value.isInitialized)
                  AspectRatio(
                    aspectRatio: videoController.value!.value.aspectRatio,
                    child: VideoPlayer(videoController.value!),
                  )
                else
                  const AppLoadingIndicator(),
                
                // Play button
                IconButton(
                  icon: Icon(
                    videoController.value!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                  onPressed: () {
                    if (videoController.value!.value.isPlaying) {
                      videoController.value!.pause();
                    } else {
                      videoController.value!.play();
                    }
                  },
                ),
              ],
            ),
          )
        else
          // Upload button
          InkWell(
            onTap: () => _selectVideo(videoFile),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload,
                    color: Colors.white54,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click to upload a video',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Video actions
        if (videoFile.value != null || videoUrl.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                // Remove video button
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Remove Video'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {
                    videoFile.value = null;
                    if (videoUrl.value != null && lesson?.videoUrl == videoUrl.value) {
                      // If we're editing and using the original URL, keep it for now
                      // We'll handle deletion on save if needed
                    } else {
                      videoUrl.value = null;
                    }
                    videoController.value?.dispose();
                    videoController.value = null;
                  },
                ),
                
                const Spacer(),
                
                // Manual duration entry
                Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Duration (sec)',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                      border: InputBorder.none,
                    ),
                    controller: TextEditingController(
                      text: duration.value?.toString() ?? '',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        try {
                          duration.value = int.parse(value);
                        } catch (_) {}
                      } else {
                        duration.value = 0;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Video thumbnail
        const Text(
          'Video Thumbnail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectImage(thumbnailFile),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: thumbnailFile.value != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      thumbnailFile.value!,
                      fit: BoxFit.cover,
                    ),
                  )
                : thumbnailUrl.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          thumbnailUrl.value!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.white54,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.white54,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Click to add a thumbnail image',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        
        if (thumbnailFile.value != null || thumbnailUrl.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Remove Thumbnail'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                thumbnailFile.value = null;
                if (thumbnailUrl.value != null && lesson?.thumbnailUrl == thumbnailUrl.value) {
                  // If we're editing and using the original URL, keep it for now
                } else {
                  thumbnailUrl.value = null;
                }
              },
            ),
          ),
      ],
    );
  }
  
  /// Build the text content section
  Widget _buildTextSection(TextEditingController textContentController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Text Content',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textContentController,
          style: const TextStyle(color: Colors.white),
          maxLines: 15,
          decoration: InputDecoration(
            hintText: 'Enter lesson content...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: AppTheme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build the resources section
  Widget _buildResourcesSection(
    BuildContext context,
    ValueNotifier<Map<String, dynamic>> resources,
    ValueNotifier<String> newResourceName,
    ValueNotifier<bool> isUploading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Resources',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        
        // Existing resources list
        if (resources.value.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: resources.value.length,
            itemBuilder: (context, index) {
              final resourceName = resources.value.keys.elementAt(index);
              final resourceUrl = resources.value[resourceName];
              
              return Card(
                color: AppTheme.cardColor,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _getResourceIcon(resourceUrl),
                    color: Colors.white70,
                  ),
                  title: Text(
                    resourceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      final updatedResources = Map<String, dynamic>.from(resources.value);
                      updatedResources.remove(resourceName);
                      resources.value = updatedResources;
                    },
                  ),
                ),
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No resources added yet',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Add resource form
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource name input
            Expanded(
              child: TextField(
                onChanged: (value) => newResourceName.value = value,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Resource name (e.g., "Slides PDF")',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Upload button
            AppButton(
              label: 'Upload',
              style: AppButtonStyle.secondary,
              icon: Icons.upload_file,
              isLoading: isUploading.value,
              onPressed: newResourceName.value.trim().isEmpty
                  ? null
                  : () => _uploadResource(
                      context,
                      resources,
                      newResourceName.value,
                      isUploading,
                    ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Select a video file
  Future<void> _selectVideo(ValueNotifier<File?> videoFile) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      videoFile.value = File(result.files.first.path!);
    }
  }
  
  /// Select an image for thumbnail
  Future<void> _selectImage(ValueNotifier<File?> thumbnailFile) async {
    final picker = ImagePicker();
    
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: GlobalContextService.navigatorKey.currentContext!,
      backgroundColor: AppTheme.cardColor,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  final image = await picker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  final image = await picker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context, image);
                },
              ),
            ],
          ),
        );
      },
    );
    
    if (pickedFile != null) {
      thumbnailFile.value = File(pickedFile.path);
    }
  }
  
  /// Upload a resource document
  Future<void> _uploadResource(
    BuildContext context,
    ValueNotifier<Map<String, dynamic>> resources,
    String resourceName,
    ValueNotifier<bool> isUploading,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      isUploading.value = true;
      
      try {
        final file = File(result.files.first.path!);
        final fileName = '${const Uuid().v4()}_${path.basename(file.path)}';
        
        // Upload file to Firebase Storage
        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref().child('lesson_resources/$fileName');
        
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;
        
        // Get download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        // Add to resources map
        final updatedResources = Map<String, dynamic>.from(resources.value);
        updatedResources[resourceName] = downloadUrl;
        resources.value = updatedResources;
        
      } catch (e) {
        debugPrint('Error uploading resource: $e');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading resource: $e')),
          );
        }
      } finally {
        isUploading.value = false;
      }
    }
  }
  
  /// Upload a file to Firebase Storage
  Future<String?> _uploadFile(File file, String folder, ValueNotifier<bool> isUploading) async {
    isUploading.value = true;
    
    try {
      final storage = FirebaseStorage.instance;
      final fileExtension = path.extension(file.path);
      final fileName = '${const Uuid().v4()}$fileExtension';
      final storageRef = storage.ref().child('$folder/$fileName');
      
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    } finally {
      isUploading.value = false;
    }
  }
  
  /// Get icon for resource based on URL
  IconData _getResourceIcon(String url) {
    final extension = path.extension(url).toLowerCase();
    
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  /// Save the lesson to Firestore
  Future<void> _saveLesson(
    BuildContext context,
    WidgetRef ref,
    String title,
    String description,
    String type,
    String textContent,
    bool freePreview,
    int duration,
    File? videoFile,
    String? videoUrl,
    File? thumbnailFile,
    String? thumbnailUrl,
    Map<String, dynamic> resources,
    ValueNotifier<bool> isUploading,
  ) async {
    // Validate inputs
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a lesson title')),
      );
      return;
    }
    
    if (type == 'video' && videoFile == null && videoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a video')),
      );
      return;
    }
    
    if (type == 'text' && textContent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text content')),
      );
      return;
    }
    
    // Set form state to loading
    ref.read(lessonFormStateProvider.notifier).state = const AsyncValue.loading();
    
    try {
      // Handle file uploads if needed
      String? finalVideoUrl = videoUrl;
      String? finalThumbnailUrl = thumbnailUrl;
      
      if (videoFile != null) {
        finalVideoUrl = await _uploadFile(videoFile, 'lesson_videos', isUploading);
        
        if (finalVideoUrl == null) {
          throw Exception('Failed to upload video');
        }
      }
      
      if (thumbnailFile != null) {
        finalThumbnailUrl = await _uploadFile(thumbnailFile, 'lesson_thumbnails', isUploading);
        
        if (finalThumbnailUrl == null) {
          throw Exception('Failed to upload thumbnail');
        }
      }
      
      final courseRepository = ref.read(courseRepositoryProvider);
      
      // Create or update lesson
      if (lesson == null) {
        // Create new lesson
        await courseRepository.createLesson(
          courseId: courseId,
          title: title,
          description: description,
          type: type,
          duration: duration,
          videoUrl: finalVideoUrl,
          thumbnailUrl: finalThumbnailUrl,
          textContent: type == 'text' ? textContent : null,
          freePreview: freePreview,
          resources: resources,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson created successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        // Update existing lesson
        await courseRepository.updateLesson(
          courseId: courseId,
          lessonId: lesson!.id,
          title: title,
          description: description,
          type: type,
          duration: duration,
          videoUrl: finalVideoUrl,
          thumbnailUrl: finalThumbnailUrl,
          textContent: type == 'text' ? textContent : null,
          freePreview: freePreview,
          resources: resources,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson updated successfully')),
          );
          Navigator.pop(context);
        }
      }
      
      // Reset form state
      ref.read(lessonFormStateProvider.notifier).state = const AsyncValue.data(null);
    } catch (e) {
      ref.read(lessonFormStateProvider.notifier).state = AsyncValue.error(e, StackTrace.current);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

/// Service to access the navigator key globally
class GlobalContextService {
  static final navigatorKey = GlobalKey<NavigatorState>();
} 