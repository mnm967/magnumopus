import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Subscription tiers available in the app
enum SubscriptionTier {
  @JsonValue('free')
  free,
  
  @JsonValue('advanced')
  advanced,
  
  @JsonValue('elite')
  elite,
}

/// Model representing a user in the application
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    @Default(SubscriptionTier.free) SubscriptionTier tier,
    DateTime? subscriptionExpiry,
    @Default(false) bool isAdmin,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  /// Create an empty user with default values
  factory User.empty() => const User(
    id: '',
    email: '',
    name: '',
    tier: SubscriptionTier.free,
    isAdmin: false,
  );

  const User._();
  
  /// Check if the user is subscribed to any paid tier
  bool get isPaidUser => tier != SubscriptionTier.free;
  
  /// Check if the user's subscription is active (not expired)
  bool get hasActiveSubscription {
    if (tier == SubscriptionTier.free) return false;
    if (subscriptionExpiry == null) return true; // No expiry date means indefinite
    return subscriptionExpiry!.isAfter(DateTime.now());
  }
  
  /// Check if user has access to a specific tier content
  bool canAccessTier(SubscriptionTier contentTier) {
    if (isAdmin) return true; // Admins can access all content
    
    if (!hasActiveSubscription) {
      return contentTier == SubscriptionTier.free;
    }
    
    // Check if user's tier is high enough
    switch (tier) {
      case SubscriptionTier.elite:
        return true; // Elite can access all tiers
      case SubscriptionTier.advanced:
        return contentTier != SubscriptionTier.elite; // Advanced can access free and advanced
      case SubscriptionTier.free:
        return contentTier == SubscriptionTier.free;
    }
  }
} 