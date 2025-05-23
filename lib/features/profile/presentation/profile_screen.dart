import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_card.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/core/providers/user_provider.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/features/auth/presentation/login_screen.dart';
import 'package:magnumopus/features/downloads/presentation/downloads_screen.dart';

/// Provider to handle the logout state
final logoutStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Screen that displays user profile and settings
class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(currentUserProvider);
    final logoutState = ref.watch(logoutStateProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return _buildNotLoggedInView(context);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(authRepositoryProvider);
            },
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info header
                  _buildUserInfoHeader(context, user),
                  const SizedBox(height: 24),
                  
                  // Subscription info
                  _buildSubscriptionCard(context, user),
                  const SizedBox(height: 24),
                  
                  // Profile sections
                  _buildProfileSections(context, user),
                  const SizedBox(height: 24),
                  
                  // Logout button
                  Center(
                    child: AppButton(
                      label: 'Log Out',
                      style: AppButtonStyle.outline,
                      isLoading: logoutState is AsyncLoading,
                      onPressed: logoutState is AsyncLoading
                          ? null
                          : () => _logout(context, ref),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading profile: $error',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
  
  /// Build the view for users who aren't logged in
  Widget _buildNotLoggedInView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 800.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 24),
            Text(
              'Not Signed In',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to access your profile, track your progress, and manage your subscription.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Sign In',
              style: AppButtonStyle.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the user info header with avatar and basic info
  Widget _buildUserInfoHeader(BuildContext context, User user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User avatar
        Hero(
          tag: 'user-avatar',
          child: CircleAvatar(
            radius: 40,
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
                      fontSize: 36,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 24),
        
        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              // User stats in chips
              Wrap(
                spacing: 8,
                children: [
                  _buildStatChip('Member since', _formatDate(user.createdAt ?? DateTime.now())),
                  _buildStatChip('Last active', _getLastActiveText(user.lastSeen)),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0, duration: 600.ms);
  }
  
  /// Build a subscription info card
  Widget _buildSubscriptionCard(BuildContext context, User user) {
    // Set colors based on subscription tier
    Color tierColor;
    String tierName;
    IconData tierIcon;
    
    switch (user.tier) {
      case SubscriptionTier.free:
        tierColor = AppTheme.primaryColor;
        tierName = 'Free Plan';
        tierIcon = Icons.public;
        break;
      case SubscriptionTier.advanced:
        tierColor = AppTheme.accentColor;
        tierName = 'Advanced Plan';
        tierIcon = Icons.star;
        break;
      case SubscriptionTier.elite:
        tierColor = AppTheme.secondaryColor;
        tierName = 'Elite Plan';
        tierIcon = Icons.workspace_premium;
        break;
    }
    
    return AppCard(
      animate: true,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscription title
          Row(
            children: [
              Icon(
                tierIcon,
                color: tierColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                tierName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              if (user.tier != SubscriptionTier.elite)
                TextButton(
                  onPressed: () {
                    // Navigate to upgrade page
                  },
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Subscription details
          ...buildSubscriptionDetails(user.tier),
          
          // Expiry info if applicable
          if (user.subscriptionExpiry != null && user.tier != SubscriptionTier.free)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Renews on ${_formatDate(user.subscriptionExpiry!)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  /// Build subscription details based on tier
  List<Widget> buildSubscriptionDetails(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return [
          _buildFeatureItem('Access to free trading courses'),
          _buildFeatureItem('Limited community channel access'),
          _buildFeatureItem('Basic AI assistant features'),
          _buildFeatureItem('No ads', enabled: false),
          _buildFeatureItem('Advanced course content', enabled: false),
          _buildFeatureItem('Private chat access', enabled: false),
        ];
      case SubscriptionTier.advanced:
        return [
          _buildFeatureItem('Access to free and advanced trading courses'),
          _buildFeatureItem('Full community channel access'),
          _buildFeatureItem('Enhanced AI assistant features'),
          _buildFeatureItem('No ads'),
          _buildFeatureItem('Elite course content', enabled: false),
          _buildFeatureItem('One-on-one mentoring', enabled: false),
        ];
      case SubscriptionTier.elite:
        return [
          _buildFeatureItem('Full access to all trading courses'),
          _buildFeatureItem('All community channels and private groups'),
          _buildFeatureItem('Unlimited AI assistant functionality'),
          _buildFeatureItem('No ads'),
          _buildFeatureItem('Priority support'),
          _buildFeatureItem('One-on-one mentoring sessions'),
        ];
    }
  }
  
  /// Build a list of other profile sections
  Widget _buildProfileSections(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildProfileMenuItem(
                context,
                title: 'Edit Profile',
                icon: Icons.edit,
                onTap: () {
                  // Navigate to edit profile
                },
              ),
              _buildProfileMenuItem(
                context,
                title: 'My Downloads',
                icon: Icons.download_for_offline_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DownloadsScreen()),
                  );
                },
              ),
              _buildProfileMenuItem(
                context,
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              _buildProfileMenuItem(
                context,
                title: 'Payment Methods',
                icon: Icons.payment_outlined,
                onTap: () {
                  // Navigate to payment methods
                },
              ),
              _buildProfileMenuItem(
                context,
                title: 'Privacy Settings',
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  // Navigate to privacy settings
                },
                showDivider: false,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildProfileMenuItem(
                context,
                title: 'Help Center',
                icon: Icons.help_outline,
                onTap: () {
                  // Navigate to help center
                },
              ),
              _buildProfileMenuItem(
                context,
                title: 'Contact Support',
                icon: Icons.support_agent_outlined,
                onTap: () {
                  // Navigate to contact support
                },
              ),
              _buildProfileMenuItem(
                context,
                title: 'About',
                icon: Icons.info_outline,
                onTap: () {
                  // Navigate to about page
                },
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).moveY(begin: 20, end: 0, duration: 600.ms);
  }
  
  /// Build a statistic chip
  Widget _buildStatChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a feature item for the subscription card
  Widget _buildFeatureItem(String text, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size: 16,
            color: enabled ? AppTheme.successColor : Colors.white.withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a profile menu item
  Widget _buildProfileMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: Colors.white.withOpacity(0.05),
            height: 1,
            indent: 56,
          ),
      ],
    );
  }
  
  /// Handle user logout
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    ref.read(logoutStateProvider.notifier).state = const AsyncValue.loading();
    
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.logout();
      
      if (context.mounted) {
        ref.read(logoutStateProvider.notifier).state = const AsyncValue.data(null);
        
        // Navigate back to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      ref.read(logoutStateProvider.notifier).state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  /// Format a date in a readable format
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  /// Get a human-readable last active text
  String _getLastActiveText(DateTime? lastSeen) {
    if (lastSeen == null) {
      return 'Unknown';
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 5) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return _formatDate(lastSeen);
    }
  }
} 