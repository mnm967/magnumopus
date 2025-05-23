import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';

/// Provider to get all courses
final allCoursesProvider = StreamProvider<List<Course>>((ref) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getAllCourses();
});

/// Provider to get lessons for a course
final courseLessonsProvider = StreamProvider.family<List<Lesson>, String>((ref, courseId) {
  final courseRepository = ref.watch(courseRepositoryProvider);
  return courseRepository.getLessons(courseId);
}); 