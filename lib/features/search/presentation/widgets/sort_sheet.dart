import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/features/search/providers/search_providers.dart';

/// Bottom sheet for sorting search results
class SortSheet extends HookConsumerWidget {
  const SortSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOption = ref.watch(sortOptionProvider);
    
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
                'Sort Results',
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
          const SizedBox(height: 16),
          
          // Sort options list in a scrollable container
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSortOption(
                    context, 
                    ref,
                    option: SortOption.relevance,
                    label: 'Relevance',
                    icon: Icons.auto_awesome,
                    isSelected: selectedOption == SortOption.relevance,
                  ),
                  
                  _buildSortOption(
                    context, 
                    ref,
                    option: SortOption.newest,
                    label: 'Newest First',
                    icon: Icons.calendar_today,
                    isSelected: selectedOption == SortOption.newest,
                  ),
                  
                  _buildSortOption(
                    context, 
                    ref,
                    option: SortOption.oldest,
                    label: 'Oldest First',
                    icon: Icons.history,
                    isSelected: selectedOption == SortOption.oldest,
                  ),
                  
                  _buildSortOption(
                    context, 
                    ref,
                    option: SortOption.titleAsc,
                    label: 'Title A-Z',
                    icon: Icons.sort_by_alpha,
                    isSelected: selectedOption == SortOption.titleAsc,
                  ),
                  
                  _buildSortOption(
                    context, 
                    ref,
                    option: SortOption.titleDesc,
                    label: 'Title Z-A',
                    icon: Icons.sort_by_alpha,
                    isSelected: selectedOption == SortOption.titleDesc,
                  ),
                  
                  _buildSortOption(
                    context, 
                    ref,
                    option: SortOption.durationAsc,
                    label: 'Shortest First',
                    icon: Icons.timelapse,
                    isSelected: selectedOption == SortOption.durationAsc,
                  ),
                  
                  _buildSortOption(
                    context, 
                    ref,
                    option: SortOption.durationDesc,
                    label: 'Longest First',
                    icon: Icons.timelapse,
                    isSelected: selectedOption == SortOption.durationDesc,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a sort option item
  Widget _buildSortOption(
    BuildContext context, 
    WidgetRef ref, {
    required SortOption option,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(sortOptionProvider.notifier).state = option;
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
} 