import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/course_repository.dart';

/// Repository for managing search history
class SearchHistoryRepository {
  final FirebaseFirestore _firestore;
  final String _userId;
  
  SearchHistoryRepository(this._firestore, this._userId);
  
  /// Get recent searches for the current user
  Stream<List<String>> getRecentSearches() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
      .collection('users')
      .doc(_userId)
      .collection('search_history')
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => doc.data()['query'] as String).toList();
      });
  }
  
  /// Add a search query to history
  Future<void> addSearchQuery(String query) async {
    if (_userId.isEmpty || query.trim().isEmpty) {
      return;
    }
    
    await _firestore
      .collection('users')
      .doc(_userId)
      .collection('search_history')
      .add({
        'query': query.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
  }
  
  /// Clear search history
  Future<void> clearSearchHistory() async {
    if (_userId.isEmpty) {
      return;
    }
    
    final batch = _firestore.batch();
    final snapshot = await _firestore
      .collection('users')
      .doc(_userId)
      .collection('search_history')
      .get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
}

/// Provider for the search history repository
final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((ref) {
  // In a real app, you would get the current user ID from the auth repository
  // For now, we'll use a mock user ID
  const userId = 'user1';
  return SearchHistoryRepository(FirebaseFirestore.instance, userId);
});

/// Search types
enum SearchType {
  courses,
  lessons,
}

/// Sort options
enum SortOption {
  relevance,
  newest,
  oldest,
  titleAsc,
  titleDesc,
  durationAsc,
  durationDesc,
}

/// Provider for the search controller
final searchControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for the active search type
final searchTypeProvider = StateProvider<SearchType>((ref) => SearchType.courses);

/// Provider for the active sort option
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.relevance);

/// Provider for the active filters
final activeFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

/// Provider for search results
final searchResultsProvider = FutureProvider<List<dynamic>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final searchType = ref.watch(searchTypeProvider);
  final sortOption = ref.watch(sortOptionProvider);
  final filters = ref.watch(activeFiltersProvider);
  final courseRepository = ref.watch(courseRepositoryProvider);
  
  // Add to search history if query is not empty
  if (query.isNotEmpty) {
    ref.read(searchHistoryRepositoryProvider).addSearchQuery(query);
  }
  
  // If query is empty and filters are empty, return empty list
  if (query.isEmpty && filters.isEmpty) {
    return Future.value([]);
  }
  
  if (searchType == SearchType.courses) {
    return courseRepository.searchCourses(
      query: query,
      filters: filters,
      sortOption: _getSortOptionString(sortOption),
    );
  } else {
    return courseRepository.searchLessons(
      query: query,
      filters: filters,
      sortOption: _getSortOptionString(sortOption),
    );
  }
});

/// Provider for recent searches
final recentSearchesProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(searchHistoryRepositoryProvider).getRecentSearches();
});

/// Provider for popular categories
final popularCategoriesProvider = Provider<List<CourseCategory>>((ref) {
  // In a real app, you would get this from the repository
  // For now, we'll return mock data
  return [
    const CourseCategory(
      id: 'cat1',
      name: 'Trading Fundamentals',
      description: 'Essential knowledge for beginners in trading',
    ),
    const CourseCategory(
      id: 'cat2',
      name: 'Technical Analysis',
      description: 'Learn how to analyze charts and identify patterns',
    ),
    const CourseCategory(
      id: 'cat3',
      name: 'Advanced Strategies',
      description: 'Complex trading strategies for experienced traders',
    ),
    const CourseCategory(
      id: 'cat4',
      name: 'Risk Management',
      description: 'Protect your capital with proper risk management techniques',
    ),
  ];
});

/// Convert sort option enum to string for repository
String _getSortOptionString(SortOption option) {
  switch (option) {
    case SortOption.relevance:
      return 'relevance';
    case SortOption.newest:
      return 'newest';
    case SortOption.oldest:
      return 'oldest';
    case SortOption.titleAsc:
      return 'titleAsc';
    case SortOption.titleDesc:
      return 'titleDesc';
    case SortOption.durationAsc:
      return 'durationAsc';
    case SortOption.durationDesc:
      return 'durationDesc';
  }
} 