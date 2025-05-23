import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/core/providers/user_provider.dart';
import 'package:magnumopus/data/models/community_model.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/data/repositories/community_repository.dart';
import 'package:magnumopus/features/community/presentation/chat_screen.dart';
import 'package:magnumopus/features/search/presentation/search_screen.dart';

/// Provider for all available channels
final channelsProvider = StreamProvider<List<Channel>>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  return communityRepository.getChannels();
});

/// Screen that displays community features like chat channels
class CommunityScreen extends HookConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);
    final channelsAsync = ref.watch(channelsProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User welcome section
          userAsyncValue.when(
            data: (user) {
              if (user == null) {
                return _buildLoginPrompt(context);
              }
              return _buildWelcomeHeader(context, user);
            },
            loading: () => const SizedBox(height: 80),
            error: (_, __) => _buildLoginPrompt(context),
          ),
          
          // Channel categories
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Channels',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Text(
                  'Join the discussion',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Channel list
          Expanded(
            child: channelsAsync.when(
              data: (channels) {
                if (channels.isEmpty) {
                  return Center(
                    child: Text(
                      'No channels available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  );
                }
                
                // Group channels by tier for better organization
                final Map<SubscriptionTier, List<Channel>> groupedChannels = {};
                for (final channel in channels) {
                  final tier = channel.allowedTier;
                  if (!groupedChannels.containsKey(tier)) {
                    groupedChannels[tier] = [];
                  }
                  groupedChannels[tier]!.add(channel);
                }
                
                // Sort the tiers with free first, then advanced, then elite
                final sortedTiers = groupedChannels.keys.toList()
                  ..sort((a, b) {
                    if (a == SubscriptionTier.free) return -1;
                    if (b == SubscriptionTier.free) return 1;
                    if (a == SubscriptionTier.advanced) return -1;
                    if (b == SubscriptionTier.advanced) return 1;
                    return 0;
                  });
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: sortedTiers.length,
                  itemBuilder: (context, tierIndex) {
                    final tier = sortedTiers[tierIndex];
                    final tierChannels = groupedChannels[tier]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tier header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTierColor(tier).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatTierName(tier),
                                  style: TextStyle(
                                    color: _getTierColor(tier),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Channels for this tier
                        ...tierChannels.map((channel) => _buildChannelItem(
                          context,
                          ref,
                          channel,
                          userAsyncValue,
                        )).toList(),
                        
                        // Spacing between tiers
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(
                child: AppLoadingIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading channels: $error',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build the login prompt for users who aren't logged in
  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Join the Trading Community',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log in to access community chat channels and connect with other traders',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }
  
  /// Build the welcome header for logged-in users
  Widget _buildWelcomeHeader(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Welcome text and subscription info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  user.tier == SubscriptionTier.free
                      ? 'Free Access'
                      : user.tier == SubscriptionTier.advanced
                          ? 'Advanced Member'
                          : 'Elite Member',
                  style: TextStyle(
                    color: _getTierColor(user.tier),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Activity status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Online',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).moveY(begin: -20, end: 0, duration: 600.ms);
  }
  
  /// Build a channel list item
  Widget _buildChannelItem(
    BuildContext context,
    WidgetRef ref,
    Channel channel,
    AsyncValue<User?> userAsyncValue,
  ) {
    // Check if the user has access to this channel
    final hasAccess = userAsyncValue.maybeWhen(
      data: (user) {
        if (user == null) return channel.allowedTier == SubscriptionTier.free;
        if (user.isAdmin) return true;
        return user.canAccessTier(channel.allowedTier);
      },
      orElse: () => channel.allowedTier == SubscriptionTier.free,
    );
    
    return InkWell(
      onTap: hasAccess
          ? () => _openChannel(context, ref, channel)
          : () => _showUpgradeDialog(context, channel.allowedTier),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasAccess ? AppTheme.surfaceColor : AppTheme.surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(hasAccess ? 0.05 : 0.02),
          ),
        ),
        child: Row(
          children: [
            // Channel icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasAccess
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                channel.isPrivate ? Icons.lock_outline : Icons.tag,
                color: hasAccess
                    ? AppTheme.primaryColor
                    : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Channel info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        channel.name,
                        style: TextStyle(
                          color: hasAccess ? Colors.white : Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (channel.isPrivate)
                        Icon(
                          Icons.lock,
                          size: 14,
                          color: hasAccess
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white.withOpacity(0.3),
                        ),
                    ],
                  ),
                  if (channel.topic != null && channel.topic!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        channel.topic!,
                        style: TextStyle(
                          color: hasAccess
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white.withOpacity(0.3),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            
            // Message count or lock icon
            hasAccess
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: channel.messageCount > 0
                          ? AppTheme.primaryColor.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: channel.messageCount > 0
                        ? Text(
                            '${channel.messageCount} msg',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          )
                        : const SizedBox.shrink(),
                  )
                : Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 16,
                      color: _getTierColor(channel.allowedTier),
                    ),
                  ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
    );
  }
  
  /// Open a channel chat screen
  void _openChannel(BuildContext context, WidgetRef ref, Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(channel: channel),
      ),
    );
  }
  
  /// Show a dialog prompting the user to upgrade their subscription
  void _showUpgradeDialog(BuildContext context, SubscriptionTier requiredTier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          'Upgrade to ${_formatTierName(requiredTier)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This channel requires a ${_formatTierName(requiredTier)} subscription. '
              'Upgrade to join the conversation.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to subscription upgrade page
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
  
  /// Get the color for a subscription tier
  Color _getTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return AppTheme.primaryColor;
      case SubscriptionTier.advanced:
        return AppTheme.accentColor;
      case SubscriptionTier.elite:
        return AppTheme.secondaryColor;
    }
  }
  
  /// Format a tier name for display
  String _formatTierName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.advanced:
        return 'Advanced';
      case SubscriptionTier.elite:
        return 'Elite';
    }
  }
} 