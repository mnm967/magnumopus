import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/services/firebase_service.dart';
import 'package:magnumopus/core/utils/logger.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/models/user_model.dart';

/// Provider for the course repository
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return CourseRepository(firebaseService);
});

/// Provider for the course categories
final courseCategoriesProvider = StreamProvider<List<CourseCategory>>((ref) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getCategories();
});

/// Repository for handling course-related operations
class CourseRepository {
  final FirebaseService _firebaseService;
  
  CourseRepository(this._firebaseService);
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  
  /// Get all course categories
  Stream<List<CourseCategory>> getCategories() {
    try {
      return _firestore
          .collection('categories')
          .orderBy('order')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              // Simulate Freezed model conversion
              final data = doc.data();
              return CourseCategory(
                id: doc.id,
                name: data['name'] as String? ?? 'Unknown',
                description: data['description'] as String?,
                imageUrl: data['imageUrl'] as String?,
                order: data['order'] as int? ?? 0,
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching categories', e, stack);
      rethrow;
    }
  }
  
  /// Get all courses for a specific category
  Stream<List<Course>> getCoursesByCategory(String categoryId) {
    try {
      return _firestore
          .collection('courses')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('order')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              // Simulate Freezed model conversion
              final data = doc.data();
              return Course(
                id: doc.id,
                title: data['title'] as String? ?? 'Unknown',
                categoryId: data['categoryId'] as String? ?? categoryId,
                description: data['description'] as String?,
                tier: _parseTier(data['tier']),
                thumbnailUrl: data['thumbnailUrl'] as String?,
                createdAt: _parseTimestamp(data['createdAt']),
                lastUpdated: _parseTimestamp(data['lastUpdated']),
                order: data['order'] as int? ?? 0,
                lessonCount: data['lessonCount'] as int? ?? 0,
                totalDuration: data['totalDuration'] as int? ?? 0,
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching courses', e, stack);
      rethrow;
    }
  }
  
  /// Get a specific course by ID
  Future<Course?> getCourse(String courseId) async {
    try {
      final docSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .get();
      
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }
      
      // Simulate Freezed model conversion
      final data = docSnapshot.data()!;
      return Course(
        id: docSnapshot.id,
        title: data['title'] as String? ?? 'Unknown',
        categoryId: data['categoryId'] as String? ?? '',
        description: data['description'] as String?,
        tier: _parseTier(data['tier']),
        thumbnailUrl: data['thumbnailUrl'] as String?,
        createdAt: _parseTimestamp(data['createdAt']),
        lastUpdated: _parseTimestamp(data['lastUpdated']),
        order: data['order'] as int? ?? 0,
        lessonCount: data['lessonCount'] as int? ?? 0,
        totalDuration: data['totalDuration'] as int? ?? 0,
      );
    } catch (e, stack) {
      AppLogger.error('Error fetching course', e, stack);
      return null;
    }
  }
  
  /// Get all lessons for a course
  Stream<List<Lesson>> getLessons(String courseId) {
    try {
      return _firestore
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .orderBy('order')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              // Simulate Freezed model conversion
              final data = doc.data();
              return Lesson(
                id: doc.id,
                courseId: courseId,
                title: data['title'] as String? ?? 'Unknown',
                type: data['type'] as String? ?? 'video',
                description: data['description'] as String?,
                duration: data['duration'] as int?,
                videoUrl: data['videoUrl'] as String?,
                thumbnailUrl: data['thumbnailUrl'] as String?,
                textContent: data['textContent'] as String?,
                freePreview: data['freePreview'] as bool? ?? false,
                resources: data['resources'] as Map<String, dynamic>? ?? {},
                order: data['order'] as int? ?? 0,
                createdAt: _parseTimestamp(data['createdAt']),
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching lessons', e, stack);
      rethrow;
    }
  }
  
  /// Get a specific lesson by ID
  Future<Lesson?> getLesson({required String courseId, required String lessonId}) async {
    try {
      final docSnapshot = await _firestore
          .collection('lessons')
          .doc(lessonId)
          .get();
      
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }
      
      // Simulate Freezed model conversion
      final data = docSnapshot.data()!;
      return Lesson(
        id: docSnapshot.id,
        courseId: courseId,
        title: data['title'] as String? ?? 'Unknown',
        type: data['type'] as String? ?? 'video',
        description: data['description'] as String?,
        duration: data['duration'] as int?,
        videoUrl: data['videoUrl'] as String?,
        thumbnailUrl: data['thumbnailUrl'] as String?,
        textContent: data['textContent'] as String?,
        freePreview: data['freePreview'] as bool? ?? false,
        resources: data['resources'] as Map<String, dynamic>? ?? {},
        order: data['order'] as int? ?? 0,
        createdAt: _parseTimestamp(data['createdAt']),
      );
    } catch (e, stack) {
      AppLogger.error('Error fetching lesson', e, stack);
      return null;
    }
  }
  
  /// Get comments for a lesson
  Stream<List<Comment>> getComments(String lessonId) {
    try {
      return _firestore
          .collection('comments')
          .where('lessonId', isEqualTo: lessonId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              // Simulate Freezed model conversion
              final data = doc.data();
              return Comment(
                id: doc.id,
                lessonId: lessonId,
                userId: data['userId'] as String? ?? '',
                userName: data['userName'] as String? ?? 'Anonymous',
                userAvatarUrl: data['userAvatarUrl'] as String?,
                text: data['text'] as String? ?? '',
                timestamp: _parseTimestamp(data['timestamp']) ?? DateTime.now(),
                parentCommentId: data['parentCommentId'] as String?,
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching comments', e, stack);
      rethrow;
    }
  }
  
  /// Add a comment to a lesson
  Future<void> addComment({
    required String lessonId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      await _firestore
          .collection('comments')
          .add({
            'lessonId': lessonId,
            'userId': userId,
            'userName': userName,
            'userAvatarUrl': userAvatarUrl,
            'text': text,
            'timestamp': FieldValue.serverTimestamp(),
            'parentCommentId': parentCommentId,
          });
    } catch (e, stack) {
      AppLogger.error('Error adding comment', e, stack);
      rethrow;
    }
  }
  
  /// Delete a comment from a lesson (admin or comment owner)
  Future<void> deleteComment({
    required String lessonId,
    required String commentId,
    required String userId,
    required bool isAdmin,
  }) async {
    try {
      // Check if user is admin or comment owner
      if (!isAdmin) {
        final comment = await _firestore
            .collection('comments')
            .doc(commentId)
            .get();
        
        if (!comment.exists || comment.data() == null) {
          throw Exception('Comment not found');
        }
        
        final commentUserId = comment.data()!['userId'] as String?;
        if (commentUserId != userId) {
          throw Exception('You are not authorized to delete this comment');
        }
      }
      
      // Delete the comment
      await _firestore
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e, stack) {
      AppLogger.error('Error deleting comment', e, stack);
      rethrow;
    }
  }
  
  /// Search for courses based on query and filters
  Future<List<Course>> searchCourses({
    String query = '',
    Map<String, dynamic> filters = const {},
    String sortOption = 'relevance',
  }) async {
    try {
      Query coursesQuery = _firestore.collection('courses');
      
      // Apply filters
      if (filters.containsKey('categoryId')) {
        coursesQuery = coursesQuery.where('categoryId', isEqualTo: filters['categoryId']);
      }
      
      if (filters.containsKey('tier')) {
        coursesQuery = coursesQuery.where('tier', isEqualTo: filters['tier']);
      }
      
      // We could add more complex filters here, but for demo we'll keep it simple
      
      // Execute the query
      final snapshot = await coursesQuery.get();
      
      // Convert to courses
      List<Course> courses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Course(
          id: doc.id,
          title: data['title'] as String? ?? 'Unknown',
          categoryId: data['categoryId'] as String? ?? '',
          description: data['description'] as String?,
          tier: _parseTier(data['tier']),
          thumbnailUrl: data['thumbnailUrl'] as String?,
          createdAt: _parseTimestamp(data['createdAt']),
          lastUpdated: _parseTimestamp(data['lastUpdated']),
          order: data['order'] as int? ?? 0,
          lessonCount: data['lessonCount'] as int? ?? 0,
          totalDuration: data['totalDuration'] as int? ?? 0,
        );
      }).toList();
      
      // Filter by search query if provided (done client-side for demo)
      if (query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        courses = courses.where((course) {
          return course.title.toLowerCase().contains(queryLower) ||
                (course.description?.toLowerCase().contains(queryLower) ?? false);
        }).toList();
      }

      // Filter by duration if provided
      if (filters.containsKey('minDuration') && filters.containsKey('maxDuration')) {
        final minDuration = filters['minDuration'] as int;
        final maxDuration = filters['maxDuration'] as int;
        courses = courses.where((course) {
          return course.totalDuration >= minDuration && 
                 course.totalDuration <= maxDuration;
        }).toList();
      }
      
      // Sort results
      _sortCourses(courses, sortOption);
      
      return courses;
    } catch (e, stack) {
      AppLogger.error('Error searching courses', e, stack);
      return [];
    }
  }
  
  /// Search for lessons based on query and filters
  Future<List<Lesson>> searchLessons({
    String query = '',
    Map<String, dynamic> filters = const {},
    String sortOption = 'relevance',
  }) async {
    try {
      Query lessonsQuery = _firestore.collection('lessons');
      
      // Apply filters
      if (filters.containsKey('courseId')) {
        lessonsQuery = lessonsQuery.where('courseId', isEqualTo: filters['courseId']);
      }
      
      if (filters.containsKey('freePreviewOnly') && filters['freePreviewOnly'] == true) {
        lessonsQuery = lessonsQuery.where('freePreview', isEqualTo: true);
      }
      
      // Execute the query
      final snapshot = await lessonsQuery.get();
      
      // Convert to lessons
      List<Lesson> lessons = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Lesson(
          id: doc.id,
          courseId: data['courseId'] as String? ?? '',
          title: data['title'] as String? ?? 'Unknown',
          type: data['type'] as String? ?? 'video',
          description: data['description'] as String?,
          duration: data['duration'] as int?,
          videoUrl: data['videoUrl'] as String?,
          thumbnailUrl: data['thumbnailUrl'] as String?,
          textContent: data['textContent'] as String?,
          freePreview: data['freePreview'] as bool? ?? false,
          resources: data['resources'] as Map<String, dynamic>? ?? {},
          order: data['order'] as int? ?? 0,
          createdAt: _parseTimestamp(data['createdAt']),
        );
      }).toList();
      
      // Filter by search query if provided (done client-side for demo)
      if (query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        lessons = lessons.where((lesson) {
          return lesson.title.toLowerCase().contains(queryLower) ||
                (lesson.description?.toLowerCase().contains(queryLower) ?? false) ||
                (lesson.textContent?.toLowerCase().contains(queryLower) ?? false);
        }).toList();
      }
      
      // Filter by duration if provided
      if (filters.containsKey('minDuration') && filters.containsKey('maxDuration')) {
        final minDuration = filters['minDuration'] as int;
        final maxDuration = filters['maxDuration'] as int;
        lessons = lessons.where((lesson) {
          return (lesson.duration ?? 0) >= minDuration && 
                 (lesson.duration ?? 0) <= maxDuration;
        }).toList();
      }
      
      // Sort results
      _sortLessons(lessons, sortOption);
      
      return lessons;
    } catch (e, stack) {
      AppLogger.error('Error searching lessons', e, stack);
      return [];
    }
  }
  
  /// Sort a list of courses based on the specified sort option
  void _sortCourses(List<Course> courses, String sortOption) {
    switch (sortOption) {
      case 'newest':
        courses.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        break;
      case 'oldest':
        courses.sort((a, b) => (a.createdAt ?? DateTime.now())
            .compareTo(b.createdAt ?? DateTime.now()));
        break;
      case 'titleAsc':
        courses.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'titleDesc':
        courses.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'durationAsc':
        courses.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
        break;
      case 'durationDesc':
        courses.sort((a, b) => b.totalDuration.compareTo(a.totalDuration));
        break;
      default:
        // Default is by relevance (no specific sort)
        break;
    }
  }
  
  /// Sort a list of lessons based on the specified sort option
  void _sortLessons(List<Lesson> lessons, String sortOption) {
    switch (sortOption) {
      case 'newest':
        lessons.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        break;
      case 'oldest':
        lessons.sort((a, b) => (a.createdAt ?? DateTime.now())
            .compareTo(b.createdAt ?? DateTime.now()));
        break;
      case 'titleAsc':
        lessons.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'titleDesc':
        lessons.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'durationAsc':
        lessons.sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
        break;
      case 'durationDesc':
        lessons.sort((a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0));
        break;
      default:
        // Default is by relevance (no specific sort)
        break;
    }
  }
  
  /// Get featured or popular courses
  Future<List<Course>> getFeaturedCourses() async {
    try {
      // In a real app, this might be based on view count, rating, etc.
      final coursesSnapshot = await _firestore
          .collection('courses')
          .where('isFeatured', isEqualTo: true)
          .limit(5)
          .get();
      
      return coursesSnapshot.docs.map((doc) {
        // Simulate Freezed model conversion
        final data = doc.data();
        return Course(
          id: doc.id,
          title: data['title'] as String? ?? 'Unknown',
          categoryId: data['categoryId'] as String? ?? '',
          description: data['description'] as String?,
          tier: _parseTier(data['tier']),
          thumbnailUrl: data['thumbnailUrl'] as String?,
          createdAt: _parseTimestamp(data['createdAt']),
          lastUpdated: _parseTimestamp(data['lastUpdated']),
          order: data['order'] as int? ?? 0,
          lessonCount: data['lessonCount'] as int? ?? 0,
          totalDuration: data['totalDuration'] as int? ?? 0,
        );
      }).toList();
    } catch (e, stack) {
      AppLogger.error('Error fetching featured courses', e, stack);
      return [];
    }
  }
  
  /// Parse subscription tier from Firestore
  SubscriptionTier _parseTier(dynamic value) {
    if (value == null) return SubscriptionTier.free;
    
    switch (value.toString().toLowerCase()) {
      case 'advanced':
        return SubscriptionTier.advanced;
      case 'elite':
        return SubscriptionTier.elite;
      default:
        return SubscriptionTier.free;
    }
  }
  
  /// Parse Firestore timestamp to DateTime
  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    
    if (value is Timestamp) {
      return value.toDate();
    }
    
    return null;
  }
  
  /// Create a new course
  Future<String> createCourse({
    required String title,
    required String categoryId,
    required String description,
    required SubscriptionTier tier,
    String? thumbnailUrl,
  }) async {
    try {
      // Get the highest order value to put new course at the end
      final lastCourse = await _firestore
          .collection('courses')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('order', descending: true)
          .limit(1)
          .get();
      
      int order = 0;
      if (lastCourse.docs.isNotEmpty) {
        order = lastCourse.docs.first.data()['order'] as int? ?? 0;
        order += 1;
      }
      
      // Create the new course
      final courseRef = _firestore.collection('courses').doc();
      
      await courseRef.set({
        'title': title,
        'categoryId': categoryId,
        'description': description,
        'tier': tier.toString().split('.').last,
        'thumbnailUrl': thumbnailUrl,
        'order': order,
        'lessonCount': 0,
        'totalDuration': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      return courseRef.id;
    } catch (e, stack) {
      AppLogger.error('Error creating course', e, stack);
      rethrow;
    }
  }
  
  /// Update an existing course
  Future<void> updateCourse({
    required String courseId,
    String? title,
    String? categoryId,
    String? description,
    SubscriptionTier? tier,
    String? thumbnailUrl,
    int? order,
  }) async {
    try {
      final updates = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      
      if (title != null) updates['title'] = title;
      if (categoryId != null) updates['categoryId'] = categoryId;
      if (description != null) updates['description'] = description;
      if (tier != null) updates['tier'] = tier.toString().split('.').last;
      if (thumbnailUrl != null) updates['thumbnailUrl'] = thumbnailUrl;
      if (order != null) updates['order'] = order;
      
      await _firestore.collection('courses').doc(courseId).update(updates);
    } catch (e, stack) {
      AppLogger.error('Error updating course', e, stack);
      rethrow;
    }
  }
  
  /// Delete a course and all its lessons
  Future<void> deleteCourse(String courseId) async {
    try {
      // Use a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Get all lessons for this course
        final lessonDocs = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .get();
        
        // Delete each lesson
        for (final lessonDoc in lessonDocs.docs) {
          transaction.delete(lessonDoc.reference);
        }
        
        // Delete the course
        transaction.delete(_firestore.collection('courses').doc(courseId));
      });
    } catch (e, stack) {
      AppLogger.error('Error deleting course', e, stack);
      rethrow;
    }
  }
  
  /// Create a new lesson for a course
  Future<String> createLesson({
    required String courseId,
    required String title,
    required String description,
    required String type,
    int? duration,
    String? videoUrl,
    String? thumbnailUrl,
    String? textContent,
    bool freePreview = false,
    Map<String, dynamic>? resources,
  }) async {
    try {
      // Get the highest order value to put new lesson at the end
      final lastLesson = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .orderBy('order', descending: true)
          .limit(1)
          .get();
      
      int order = 0;
      if (lastLesson.docs.isNotEmpty) {
        order = lastLesson.docs.first.data()['order'] as int? ?? 0;
        order += 1;
      }
      
      // Create the new lesson
      final lessonRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc();
      
      await lessonRef.set({
        'title': title,
        'description': description,
        'type': type,
        'duration': duration ?? 0,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'textContent': textContent,
        'freePreview': freePreview,
        'resources': resources ?? {},
        'order': order,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Update course metadata
      await _updateCourseMetadata(courseId);
      
      return lessonRef.id;
    } catch (e, stack) {
      AppLogger.error('Error creating lesson', e, stack);
      rethrow;
    }
  }
  
  /// Update an existing lesson
  Future<void> updateLesson({
    required String courseId,
    required String lessonId,
    String? title,
    String? description,
    String? type,
    int? duration,
    String? videoUrl,
    String? thumbnailUrl,
    String? textContent,
    bool? freePreview,
    Map<String, dynamic>? resources,
    int? order,
  }) async {
    try {
      final updates = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (type != null) updates['type'] = type;
      if (duration != null) updates['duration'] = duration;
      if (videoUrl != null) updates['videoUrl'] = videoUrl;
      if (thumbnailUrl != null) updates['thumbnailUrl'] = thumbnailUrl;
      if (textContent != null) updates['textContent'] = textContent;
      if (freePreview != null) updates['freePreview'] = freePreview;
      if (resources != null) updates['resources'] = resources;
      if (order != null) updates['order'] = order;
      
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .update(updates);
      
      // Update course metadata if duration changed
      if (duration != null) {
        await _updateCourseMetadata(courseId);
      }
    } catch (e, stack) {
      AppLogger.error('Error updating lesson', e, stack);
      rethrow;
    }
  }
  
  /// Delete a lesson
  Future<void> deleteLesson({
    required String courseId,
    required String lessonId,
  }) async {
    try {
      // Delete the lesson document
      await _firestore.collection('lessons').doc(lessonId).delete();
      
      // Update the course's lesson count
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      if (courseDoc.exists && courseDoc.data() != null) {
        final currentCount = courseDoc.data()!['lessonCount'] as int? ?? 0;
        if (currentCount > 0) {
          await _firestore.collection('courses').doc(courseId).update({
            'lessonCount': currentCount - 1,
          });
        }
      }
    } catch (e, stack) {
      AppLogger.error('Error deleting lesson', e, stack);
      rethrow;
    }
  }
  
  /// Update course metadata (lesson count and total duration)
  Future<void> _updateCourseMetadata(String courseId) async {
    try {
      // Get all lessons
      final lessonsSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .get();
      
      final lessonCount = lessonsSnapshot.docs.length;
      
      // Calculate total duration
      int totalDuration = 0;
      for (final lessonDoc in lessonsSnapshot.docs) {
        totalDuration += lessonDoc.data()['duration'] as int? ?? 0;
      }
      
      // Update course
      await _firestore.collection('courses').doc(courseId).update({
        'lessonCount': lessonCount,
        'totalDuration': totalDuration,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      AppLogger.error('Error updating course metadata', e, stack);
      rethrow;
    }
  }
  
  /// Get all courses
  Stream<List<Course>> getAllCourses() {
    try {
      return _firestore
          .collection('courses')
          .orderBy('order')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              // Simulate Freezed model conversion
              final data = doc.data();
              return Course(
                id: doc.id,
                title: data['title'] as String? ?? 'Unknown',
                categoryId: data['categoryId'] as String? ?? '',
                description: data['description'] as String?,
                tier: _parseTier(data['tier']),
                thumbnailUrl: data['thumbnailUrl'] as String?,
                createdAt: _parseTimestamp(data['createdAt']),
                lastUpdated: _parseTimestamp(data['lastUpdated']),
                order: data['order'] as int? ?? 0,
                lessonCount: data['lessonCount'] as int? ?? 0,
                totalDuration: data['totalDuration'] as int? ?? 0,
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching all courses', e, stack);
      rethrow;
    }
  }
  
  /// Update the order of a lesson
  Future<void> updateLessonOrder(
    String courseId,
    String lessonId,
    int newOrder,
  ) async {
    try {
      await _firestore
          .collection('lessons')
          .doc(lessonId)
          .update({'order': newOrder});
    } catch (e, stack) {
      AppLogger.error('Error updating lesson order', e, stack);
      rethrow;
    }
  }
} 