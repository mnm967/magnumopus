import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';


/// Provider for managing form state
final formStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Screen for creating or editing a course
class CourseFormScreen extends HookConsumerWidget {
  final Course? course;
  
  const CourseFormScreen({
    super.key,
    this.course,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formStateProvider);
    final categoriesAsync = ref.watch(courseCategoriesProvider);
    
    // Form controllers
    final titleController = TextEditingController(text: course?.title ?? '');
    final descriptionController = TextEditingController(text: course?.description ?? '');
    
    // State variables
    final selectedTier = useState<SubscriptionTier>(course?.tier ?? SubscriptionTier.free);
    final selectedCategoryId = useState<String?>(course?.categoryId);
    final thumbnailFile = useState<File?>(null);
    final thumbnailUrl = useState<String?>(course?.thumbnailUrl);
    final isUploading = useState<bool>(false);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(course == null ? 'Create Course' : 'Edit Course'),
      ),
      body: formState.when(
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course thumbnail
              _buildThumbnailSection(
                context, 
                thumbnailFile, 
                thumbnailUrl, 
                isUploading,
              ),
              const SizedBox(height: 24),
              
              // Title field
              const Text(
                'Course Title',
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
                  hintText: 'Enter course title',
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
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter course description',
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
              
              // Category selector
              const Text(
                'Category',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Text(
                      'No categories available. Please create a category first.',
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategoryId.value,
                        hint: Text(
                          'Select a category',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                        isExpanded: true,
                        dropdownColor: AppTheme.cardColor,
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(
                              category.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedCategoryId.value = value;
                        },
                      ),
                    ),
                  );
                },
                loading: () => const AppLoadingIndicator(),
                error: (_, __) => const Text(
                  'Error loading categories',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              
              // Subscription tier selector
              const Text(
                'Subscription Tier',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildTierSelector(selectedTier),
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: course == null ? 'Create Course' : 'Save Changes',
                  style: AppButtonStyle.primary,
                  isLoading: isUploading.value,
                  onPressed: isUploading.value
                      ? null
                      : () => _saveCourse(
                          context,
                          ref,
                          titleController.text,
                          descriptionController.text,
                          selectedCategoryId.value,
                          selectedTier.value,
                          thumbnailFile.value,
                          thumbnailUrl.value,
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
  
  /// Build the thumbnail section with upload functionality
  Widget _buildThumbnailSection(
    BuildContext context,
    ValueNotifier<File?> thumbnailFile,
    ValueNotifier<String?> thumbnailUrl,
    ValueNotifier<bool> isUploading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Thumbnail',
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
                              size: 48,
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
                            size: 48,
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
              label: const Text('Remove Image'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                thumbnailFile.value = null;
                if (thumbnailUrl.value != null && course?.thumbnailUrl == thumbnailUrl.value) {
                  // If we're editing and using the original URL, keep it for now
                  // We'll handle deletion on save if needed
                } else {
                  thumbnailUrl.value = null;
                }
              },
            ),
          ),
      ],
    );
  }
  
  /// Build the subscription tier selector
  Widget _buildTierSelector(ValueNotifier<SubscriptionTier> selectedTier) {
    return Row(
      children: [
        _buildTierOption(
          label: 'Free',
          value: SubscriptionTier.free,
          selectedTier: selectedTier,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        _buildTierOption(
          label: 'Advanced',
          value: SubscriptionTier.advanced,
          selectedTier: selectedTier,
          color: AppTheme.accentColor,
        ),
        const SizedBox(width: 8),
        _buildTierOption(
          label: 'Elite',
          value: SubscriptionTier.elite,
          selectedTier: selectedTier,
          color: AppTheme.secondaryColor,
        ),
      ],
    );
  }
  
  /// Build a single tier option
  Widget _buildTierOption({
    required String label,
    required SubscriptionTier value,
    required ValueNotifier<SubscriptionTier> selectedTier,
    required Color color,
  }) {
    final isSelected = selectedTier.value == value;
    
    return Expanded(
      child: InkWell(
        onTap: () => selectedTier.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Select an image from gallery or camera
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
  
  /// Upload an image to Firebase Storage
  Future<String?> _uploadImage(File file, ValueNotifier<bool> isUploading) async {
    isUploading.value = true;
    
    try {
      final storage = FirebaseStorage.instance;
      final fileExtension = path.extension(file.path);
      final fileName = '${const Uuid().v4()}$fileExtension';
      final storageRef = storage.ref().child('course_thumbnails/$fileName');
      
      final uploadTask = storageRef.putFile(file);
      
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    } finally {
      isUploading.value = false;
    }
  }
  
  /// Save the course to Firestore
  Future<void> _saveCourse(
    BuildContext context,
    WidgetRef ref,
    String title,
    String description,
    String? categoryId,
    SubscriptionTier tier,
    File? thumbnailFile,
    String? thumbnailUrl,
    ValueNotifier<bool> isUploading,
  ) async {
    // Validate inputs
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a course title')),
      );
      return;
    }
    
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    
    // Set form state to loading
    ref.read(formStateProvider.notifier).state = const AsyncValue.loading();
    
    try {
      // Handle image upload if needed
      String? finalThumbnailUrl = thumbnailUrl;
      
      if (thumbnailFile != null) {
        finalThumbnailUrl = await _uploadImage(thumbnailFile, isUploading);
        
        if (finalThumbnailUrl == null) {
          throw Exception('Failed to upload thumbnail image');
        }
      }
      
      final courseRepository = ref.read(courseRepositoryProvider);
      
      // Create or update course
      if (course == null) {
        // Create new course
        await courseRepository.createCourse(
          title: title,
          description: description,
          categoryId: categoryId,
          tier: tier,
          thumbnailUrl: finalThumbnailUrl,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course created successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        // Update existing course
        await courseRepository.updateCourse(
          courseId: course!.id,
          title: title,
          description: description,
          categoryId: categoryId,
          tier: tier,
          thumbnailUrl: finalThumbnailUrl,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course updated successfully')),
          );
          Navigator.pop(context);
        }
      }
      
      // Reset form state
      ref.read(formStateProvider.notifier).state = const AsyncValue.data(null);
    } catch (e) {
      ref.read(formStateProvider.notifier).state = AsyncValue.error(e, StackTrace.current);
      
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