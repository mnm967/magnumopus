// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChannelImpl _$$ChannelImplFromJson(Map<String, dynamic> json) =>
    _$ChannelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      topic: json['topic'] as String?,
      courseId: json['courseId'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      allowedTier:
          $enumDecodeNullable(_$SubscriptionTierEnumMap, json['allowedTier']) ??
              SubscriptionTier.free,
      order: (json['order'] as num?)?.toInt() ?? 0,
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
    );

Map<String, dynamic> _$$ChannelImplToJson(_$ChannelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'topic': instance.topic,
      'courseId': instance.courseId,
      'isPrivate': instance.isPrivate,
      'allowedTier': _$SubscriptionTierEnumMap[instance.allowedTier]!,
      'order': instance.order,
      'messageCount': instance.messageCount,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.advanced: 'advanced',
  SubscriptionTier.elite: 'elite',
};

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      fileType: json['fileType'] as String?,
      fileName: json['fileName'] as String?,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.user,
      replyToMessageId: json['replyToMessageId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatarUrl': instance.userAvatarUrl,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'fileType': instance.fileType,
      'fileName': instance.fileName,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'replyToMessageId': instance.replyToMessageId,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.user: 'user',
  MessageType.bot: 'bot',
  MessageType.system: 'system',
};

_$AIConversationImpl _$$AIConversationImplFromJson(Map<String, dynamic> json) =>
    _$AIConversationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : DateTime.parse(json['lastUpdatedAt'] as String),
    );

Map<String, dynamic> _$$AIConversationImplToJson(
        _$AIConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastUpdatedAt': instance.lastUpdatedAt?.toIso8601String(),
    };

_$AIMessageImpl _$$AIMessageImplFromJson(Map<String, dynamic> json) =>
    _$AIMessageImpl(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      isUserMessage: json['isUserMessage'] as bool,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      fileType: json['fileType'] as String?,
      fileName: json['fileName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$AIMessageImplToJson(_$AIMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'isUserMessage': instance.isUserMessage,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'fileType': instance.fileType,
      'fileName': instance.fileName,
      'timestamp': instance.timestamp.toIso8601String(),
    };
