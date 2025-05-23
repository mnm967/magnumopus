import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/features/search/providers/search_providers.dart';

// Local filter state provider to track changes before applying
final _localFiltersProvider = StateProvider<Map<String, dynamic>>((ref) {
  // Initialize with current active filters
  return Map.from(ref.watch(activeFiltersProvider));
});

/// Bottom sheet for filtering search results
class FilterSheet extends HookConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(activeFiltersProvider);
    final searchType = ref.watch(searchTypeProvider);
    final localFilters = ref.watch(_localFiltersProvider);
    
    // Initialize local filters with active filters if they're empty
    if (localFilters.isEmpty && activeFilters.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_localFiltersProvider.notifier).state = Map.from(activeFilters);
      });
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Results',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Scrollable filter content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter (only for courses)
                  if (searchType == SearchType.courses)
                    _buildCategoryFilter(context, ref),
                  
                  // Subscription tier filter
                  _buildTierFilter(context, ref),
                  
                  // Duration filter
                  _buildDurationFilter(context, ref),
                  
                  // Free Preview filter (only for lessons)
                  if (searchType == SearchType.lessons)
                    _buildFreePreviewFilter(context, ref),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              // Reset button
              Expanded(
                child: AppButton(
                  label: 'Reset',
                  style: AppButtonStyle.outline,
                  onPressed: () {
                    ref.read(_localFiltersProvider.notifier).state = {};
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Apply button
              Expanded(
                child: AppButton(
                  label: 'Apply Filters',
                  style: AppButtonStyle.primary,
                  onPressed: () {
                    // Apply the local filters to the global filter state
                    ref.read(activeFiltersProvider.notifier).state = 
                        Map.from(ref.read(_localFiltersProvider));
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build the category filter section
  Widget _buildCategoryFilter(
    BuildContext context, 
    WidgetRef ref,
  ) {
    final popularCategories = ref.watch(popularCategoriesProvider);
    final localFilters = ref.watch(_localFiltersProvider);
    final selectedCategoryId = localFilters.containsKey('categoryId') 
        ? localFilters['categoryId'] as String
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularCategories.map((category) {
            final isSelected = selectedCategoryId == category.id;
            
            return FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(_localFiltersProvider.notifier).update((state) => {
                    ...state,
                    'categoryId': category.id,
                  });
                } else {
                  ref.read(_localFiltersProvider.notifier).update((state) {
                    final newState = Map<String, dynamic>.from(state);
                    newState.remove('categoryId');
                    return newState;
                  });
                }
              },
              backgroundColor: AppTheme.surfaceColor,
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  /// Build the subscription tier filter section
  Widget _buildTierFilter(
    BuildContext context, 
    WidgetRef ref,
  ) {
    final localFilters = ref.watch(_localFiltersProvider);
    final selectedTier = localFilters.containsKey('tier') 
        ? localFilters['tier'] as String
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subscription Tier',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTierChip(
              ref,
              tier: 'free',
              label: 'Free',
              selectedTier: selectedTier,
              chipColor: AppTheme.primaryColor,
            ),
            _buildTierChip(
              ref,
              tier: 'advanced',
              label: 'Advanced',
              selectedTier: selectedTier,
              chipColor: AppTheme.accentColor,
            ),
            _buildTierChip(
              ref,
              tier: 'elite',
              label: 'Elite',
              selectedTier: selectedTier,
              chipColor: AppTheme.secondaryColor,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  /// Build a tier filter chip
  Widget _buildTierChip(
    WidgetRef ref, {
    required String tier,
    required String label,
    required String? selectedTier,
    required Color chipColor,
  }) {
    final isSelected = selectedTier == tier;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(_localFiltersProvider.notifier).update((state) => {
            ...state,
            'tier': tier,
          });
        } else {
          ref.read(_localFiltersProvider.notifier).update((state) {
            final newState = Map<String, dynamic>.from(state);
            newState.remove('tier');
            return newState;
          });
        }
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Colors.white,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : Colors.transparent,
      ),
    );
  }
  
  /// Build the duration filter section
  Widget _buildDurationFilter(
    BuildContext context, 
    WidgetRef ref,
  ) {
    final localFilters = ref.watch(_localFiltersProvider);
    final minDuration = localFilters.containsKey('minDuration') 
        ? localFilters['minDuration'] as int
        : 0;
    final maxDuration = localFilters.containsKey('maxDuration') 
        ? localFilters['maxDuration'] as int
        : 7200; // 2 hours in seconds
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            // Min duration text
            Text(
              _formatDuration(minDuration),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            
            const Spacer(),
            
            // Max duration text
            Text(
              _formatDuration(maxDuration),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Duration slider
        RangeSlider(
          values: RangeValues(minDuration.toDouble(), maxDuration.toDouble()),
          min: 0,
          max: 7200, // 2 hours in seconds
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.primaryColor.withOpacity(0.2),
          onChanged: (values) {
            ref.read(_localFiltersProvider.notifier).update((state) => {
              ...state,
              'minDuration': values.start.toInt(),
              'maxDuration': values.end.toInt(),
            });
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  /// Build the free preview filter section (for lessons only)
  Widget _buildFreePreviewFilter(
    BuildContext context, 
    WidgetRef ref,
  ) {
    final localFilters = ref.watch(_localFiltersProvider);
    final showFreePreviewOnly = localFilters.containsKey('freePreviewOnly') 
        ? localFilters['freePreviewOnly'] as bool
        : false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text(
            'Free Previews Only',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Show only lessons available as free previews',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          value: showFreePreviewOnly,
          onChanged: (value) {
            ref.read(_localFiltersProvider.notifier).update((state) => {
              ...state,
              'freePreviewOnly': value,
            });
          },
          activeColor: AppTheme.secondaryColor,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
      ],
    );
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