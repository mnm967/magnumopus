import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/data/models/course_model.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/features/courses/presentation/course_detail_screen.dart';
import 'package:magnumopus/features/search/presentation/widgets/filter_sheet.dart';
import 'package:magnumopus/features/search/presentation/widgets/sort_sheet.dart';
import 'package:magnumopus/features/search/providers/search_providers.dart';

/// Screen to search for courses and lessons
class SearchScreen extends HookConsumerWidget {
  final String? initialQuery;
  
  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the search query with the initial query if provided
    if (initialQuery != null && initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchQueryProvider.notifier).state = initialQuery!;
        ref.read(searchControllerProvider).text = initialQuery!;
      });
    }
    
    final searchController = ref.watch(searchControllerProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final activeFilters = ref.watch(activeFiltersProvider);
    final selectedSortOption = ref.watch(sortOptionProvider);
    final searchType = ref.watch(searchTypeProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search for courses and lessons...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            isDense: true,
            suffixIcon: searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                  onPressed: () {
                    searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search type toggle and filters bar
          _buildSearchControls(context, ref),
          
          // Results counter and info
          if (searchQuery.isNotEmpty || activeFilters.isNotEmpty)
            searchResultsAsync.when(
              data: (results) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          
          // Search results
          Expanded(
            child: searchQuery.isEmpty && activeFilters.isEmpty
                ? _buildSearchSuggestions(context, ref)
                : _buildSearchResults(context, ref, searchResultsAsync, searchType),
          ),
        ],
      ),
    );
  }

  /// Build the search controls (filters, sort, search type toggle)
  Widget _buildSearchControls(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(activeFiltersProvider);
    final selectedSortOption = ref.watch(sortOptionProvider);
    final searchType = ref.watch(searchTypeProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search type toggle (Courses/Lessons)
          Row(
            children: [
              _buildToggleButton(
                context, 
                label: 'Courses', 
                isSelected: searchType == SearchType.courses,
                onTap: () => ref.read(searchTypeProvider.notifier).state = SearchType.courses,
              ),
              const SizedBox(width: 12),
              _buildToggleButton(
                context, 
                label: 'Lessons', 
                isSelected: searchType == SearchType.lessons,
                onTap: () => ref.read(searchTypeProvider.notifier).state = SearchType.lessons,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Filters and sort
          Row(
            children: [
              // Filter button
              Expanded(
                child: InkWell(
                  onTap: () => _showFilterSheet(context, ref),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: activeFilters.isNotEmpty 
                          ? AppTheme.primaryColor.withOpacity(0.2) 
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: activeFilters.isNotEmpty
                          ? Border.all(color: AppTheme.primaryColor.withOpacity(0.5))
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 18,
                          color: activeFilters.isNotEmpty 
                              ? AppTheme.primaryColor 
                              : Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activeFilters.isNotEmpty
                              ? 'Filters (${activeFilters.length})'
                              : 'Filter',
                          style: TextStyle(
                            color: activeFilters.isNotEmpty 
                                ? AppTheme.primaryColor 
                                : Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Sort button
              Expanded(
                child: InkWell(
                  onTap: () => _showSortSheet(context, ref),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedSortOption != SortOption.relevance 
                          ? AppTheme.primaryColor.withOpacity(0.2) 
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: selectedSortOption != SortOption.relevance
                          ? Border.all(color: AppTheme.primaryColor.withOpacity(0.5))
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort,
                          size: 18,
                          color: selectedSortOption != SortOption.relevance 
                              ? AppTheme.primaryColor 
                              : Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getSortOptionLabel(selectedSortOption),
                          style: TextStyle(
                            color: selectedSortOption != SortOption.relevance 
                                ? AppTheme.primaryColor 
                                : Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build a toggle button for search type
  Widget _buildToggleButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build the search suggestions when no query is entered
  Widget _buildSearchSuggestions(BuildContext context, WidgetRef ref) {
    final recentSearchesAsync = ref.watch(recentSearchesProvider);
    final popularCategories = ref.watch(popularCategoriesProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          recentSearchesAsync.when(
            data: (recentSearches) {
              if (recentSearches.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Searches',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref.read(searchHistoryRepositoryProvider).clearSearchHistory(),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recentSearches.map((search) => _buildSearchChip(
                      context, 
                      label: search,
                      onTap: () {
                        ref.read(searchQueryProvider.notifier).state = search;
                        ref.read(searchControllerProvider).text = search;
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          
          // Popular categories
          const Text(
            'Popular Categories',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: popularCategories.map((category) => _buildCategoryItem(
              context,
              ref,
              category: category,
            )).toList(),
          ),
        ],
      ),
    );
  }
  
  /// Build the search results
  Widget _buildSearchResults(
    BuildContext context, 
    WidgetRef ref,
    AsyncValue<List<dynamic>> searchResultsAsync,
    SearchType searchType,
  ) {
    return searchResultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return _buildNoResults(context);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            
            if (searchType == SearchType.courses) {
              return _buildCourseResultItem(context, result as Course);
            } else {
              return _buildLessonResultItem(context, result as Lesson);
            }
          },
        );
      },
      loading: () => const Center(
        child: AppLoadingIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error fetching results: $error',
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  /// Build a course result item
  Widget _buildCourseResultItem(BuildContext context, Course course) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailScreen(courseId: course.id),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: course.thumbnailUrl != null
                ? Image.network(
                    course.thumbnailUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white.withOpacity(0.7),
                          size: 48,
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white.withOpacity(0.7),
                        size: 48,
                      ),
                    ),
                  ),
            ),
            
            // Course details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course tier badge
                  if (course.tier != SubscriptionTier.free)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: course.tier == SubscriptionTier.elite
                            ? AppTheme.secondaryColor.withOpacity(0.2)
                            : AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.tier == SubscriptionTier.elite
                            ? 'Elite'
                            : 'Advanced',
                        style: TextStyle(
                          color: course.tier == SubscriptionTier.elite
                              ? AppTheme.secondaryColor
                              : AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  
                  // Course title
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  
                  // Course description
                  if (course.description != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        course.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Course meta info
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.play_lesson,
                        size: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.lessonCount} lessons',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(course.totalDuration),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
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
      ).animate().fadeIn(duration: 300.ms).moveY(begin: 20, end: 0, duration: 300.ms),
    );
  }
  
  /// Build a lesson result item
  Widget _buildLessonResultItem(BuildContext context, Lesson lesson) {
    return InkWell(
      onTap: () {
        // Navigate to lesson player through course detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(courseId: lesson.courseId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            // Lesson thumbnail or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: lesson.thumbnailUrl != null
                ? Image.network(
                    lesson.thumbnailUrl!,
                    height: 70,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 70,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: AppTheme.primaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 70,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: AppTheme.primaryColor,
                        size: 30,
                      ),
                    ),
                  ),
            ),
            const SizedBox(width: 16),
            
            // Lesson details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Free preview badge
                  if (lesson.freePreview)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Free Preview',
                        style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  
                  // Lesson title
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Lesson duration
                  if (lesson.duration != null)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.durationFormatted,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // Play icon
            Icon(
              Icons.play_circle_outline,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).moveY(begin: 10, end: 0, duration: 300.ms),
    );
  }
  
  /// Build a search chip for recent searches
  Widget _buildSearchChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 16,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a category item
  Widget _buildCategoryItem(
    BuildContext context,
    WidgetRef ref, {
    required CourseCategory category,
  }) {
    return InkWell(
      onTap: () {
        // Apply category filter and search
        ref.read(activeFiltersProvider.notifier).update((state) => {
          ...state,
          'categoryId': category.id,
        });
        
        // Optional: auto-switch to Courses search type
        ref.read(searchTypeProvider.notifier).state = SearchType.courses;
        
        // Optional: clear existing query
        ref.read(searchQueryProvider.notifier).state = '';
        ref.read(searchControllerProvider).text = '';
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2, // Two columns with spacing
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.category,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (category.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  category.description!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 300.ms,
      ),
    );
  }
  
  /// Build the no results view
  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Show the filter sheet
  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const FilterSheet(),
    );
  }
  
  /// Show the sort sheet
  void _showSortSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SortSheet(),
    );
  }
  
  /// Get label for sort option
  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.titleAsc:
        return 'Title A-Z';
      case SortOption.titleDesc:
        return 'Title Z-A';
      case SortOption.durationAsc:
        return 'Shortest First';
      case SortOption.durationDesc:
        return 'Longest First';
    }
  }
  
  /// Format duration from seconds to a readable string
  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0 min';
    
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '$minutes min';
    }
  }
} 