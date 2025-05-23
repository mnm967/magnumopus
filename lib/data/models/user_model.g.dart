// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      tier: $enumDecodeNullable(_$SubscriptionTierEnumMap, json['tier']) ??
          SubscriptionTier.free,
      subscriptionExpiry: json['subscriptionExpiry'] == null
          ? null
          : DateTime.parse(json['subscriptionExpiry'] as String),
      isAdmin: json['isAdmin'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'tier': _$SubscriptionTierEnumMap[instance.tier]!,
      'subscriptionExpiry': instance.subscriptionExpiry?.toIso8601String(),
      'isAdmin': instance.isAdmin,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastSeen': instance.lastSeen?.toIso8601String(),
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.advanced: 'advanced',
  SubscriptionTier.elite: 'elite',
};
