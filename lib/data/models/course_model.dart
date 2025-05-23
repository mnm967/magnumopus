import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:hive/hive.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

/// Model representing a course category
@freezed
abstract class CourseCategory with _$CourseCategory {
  const factory CourseCategory({
    required String id,
    required String name,
    String? description,
    String? imageUrl,
    @Default(0) int order,
  }) = _CourseCategory;
  
  factory CourseCategory.fromJson(Map<String, dynamic> json) => 
      _$CourseCategoryFromJson(json);
}

/// Model representing a course in the application
@freezed
abstract class Course with _$Course {
  const factory Course({
    required String id,
    required String title,
    required String categoryId,
    String? description,
    @Default(SubscriptionTier.free) SubscriptionTier tier,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? lastUpdated,
    @Default(0) int order,
    @Default(0) int lessonCount,
    @Default(0) int totalDuration, // in seconds
  }) = _Course;
  
  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

/// Model representing a lesson in a course
@freezed
@HiveType(typeId: 0)
abstract class Lesson with _$Lesson {
  const factory Lesson({
    @HiveField(0) required String id,
    @HiveField(1) required String courseId,
    @HiveField(2) required String title,
    @HiveField(3) @Default('video') String type, // video, text, etc.
    @HiveField(4) String? description,
    @HiveField(5) int? duration, // in seconds
    @HiveField(6) String? videoUrl,
    @HiveField(7) String? thumbnailUrl,
    @HiveField(8) String? textContent,
    @HiveField(9) @Default(false) bool freePreview, // If true, available to free users regardless of course tier
    @HiveField(10) @Default({}) Map<String, dynamic> resources, // Additional resources (PDFs, links, etc.)
    @HiveField(11) @Default(0) int order,
    @HiveField(12) DateTime? createdAt,
    @HiveField(13) @Default(false) bool isDownloaded,
    @HiveField(14) String? localPath,
  }) = _Lesson;
  
  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  
  const Lesson._();
  
  /// Duration formatted as MM:SS
  String get durationFormatted {
    if (duration == null || duration! <= 0) return '--:--';
    
    final minutes = (duration! ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration! % 60).toString().padLeft(2, '0');
    
    return '$minutes:$seconds';
  }
}

/// Model representing a comment on a lesson
@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String lessonId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String text,
    required DateTime timestamp,
    String? parentCommentId, // If it's a reply to another comment
  }) = _Comment;
  
  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
} 