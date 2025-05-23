import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:magnumopus/data/models/user_model.dart';

part 'community_model.freezed.dart';
part 'community_model.g.dart';

/// Model representing a chat channel in the community
@freezed
abstract class Channel with _$Channel {
  const factory Channel({
    required String id,
    required String name,
    String? topic,
    String? courseId, // If the channel is tied to a specific course
    @Default(false) bool isPrivate,
    @Default(SubscriptionTier.free) SubscriptionTier allowedTier,
    @Default(0) int order,
    @Default(0) int messageCount,
    DateTime? lastMessageAt,
  }) = _Channel;
  
  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}

/// Message types in the chat
enum MessageType {
  @JsonValue('user')
  user,
  
  @JsonValue('bot')
  bot,
  
  @JsonValue('system')
  system,
}

/// Model representing a message in a chat channel
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String channelId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String text,
    String? imageUrl, // If the message contains an image
    String? fileType, // Type of the file (image, pdf, doc, etc.)
    String? fileName, // Name of the uploaded file
    @Default(MessageType.user) MessageType type,
    String? replyToMessageId, // If it's a reply to another message
    required DateTime timestamp,
  }) = _Message;
  
  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  
  /// Create a system message (for announcements, etc.)
  factory Message.system({
    required String channelId,
    required String text,
    String? id,
  }) => Message(
    id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    channelId: channelId,
    userId: 'system',
    userName: 'System',
    text: text,
    type: MessageType.system,
    timestamp: DateTime.now(),
  );
  
  /// Create a bot message (AI assistant)
  factory Message.bot({
    required String channelId,
    required String text,
    String? id,
  }) => Message(
    id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    channelId: channelId,
    userId: 'bot',
    userName: 'MagnumAI',
    text: text,
    type: MessageType.bot,
    timestamp: DateTime.now(),
  );
}

/// Model representing an AI conversation entry (for private AI coaching)
@freezed
abstract class AIConversation with _$AIConversation {
  const factory AIConversation({
    required String id,
    required String userId,
    required String title,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) = _AIConversation;
  
  factory AIConversation.fromJson(Map<String, dynamic> json) => _$AIConversationFromJson(json);
}

/// Model representing an AI message in a private conversation
@freezed
abstract class AIMessage with _$AIMessage {
  const factory AIMessage({
    required String id,
    required String conversationId,
    required bool isUserMessage, // true if sent by user, false if AI response
    required String content,
    String? imageUrl, // For image uploads by user
    String? fileType, // Type of the file (image, pdf, doc, etc.)
    String? fileName, // Name of the uploaded file
    required DateTime timestamp,
  }) = _AIMessage;
  
  factory AIMessage.fromJson(Map<String, dynamic> json) => _$AIMessageFromJson(json);
} 