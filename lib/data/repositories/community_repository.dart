import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:magnumopus/core/services/firebase_service.dart';
import 'package:magnumopus/core/utils/logger.dart';
import 'package:magnumopus/data/models/community_model.dart';
import 'package:magnumopus/data/models/user_model.dart';

/// Provider for the community repository
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return CommunityRepository(firebaseService);
});

/// Repository for handling community-related operations
class CommunityRepository {
  final FirebaseService _firebaseService;
  
  CommunityRepository(this._firebaseService);
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  
  /// Get all available channels
  Stream<List<Channel>> getChannels() {
    try {
      return _firestore
          .collection('channels')
          .orderBy('order')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              // Simulate Freezed model conversion
              final data = doc.data();
              return Channel(
                id: doc.id,
                name: data['name'] as String? ?? 'Unknown',
                topic: data['topic'] as String?,
                courseId: data['courseId'] as String?,
                isPrivate: data['isPrivate'] as bool? ?? false,
                allowedTier: _parseTier(data['allowedTier']),
                order: data['order'] as int? ?? 0,
                messageCount: data['messageCount'] as int? ?? 0,
                lastMessageAt: _parseTimestamp(data['lastMessageAt']),
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching channels', e, stack);
      rethrow;
    }
  }
  
  /// Get a specific channel by ID
  Future<Channel?> getChannel(String channelId) async {
    try {
      final docSnapshot = await _firestore
          .collection('channels')
          .doc(channelId)
          .get();
      
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }
      
      final data = docSnapshot.data()!;
      return Channel(
        id: docSnapshot.id,
        name: data['name'] as String? ?? 'Unknown',
        topic: data['topic'] as String?,
        courseId: data['courseId'] as String?,
        isPrivate: data['isPrivate'] as bool? ?? false,
        allowedTier: _parseTier(data['allowedTier']),
        order: data['order'] as int? ?? 0,
        messageCount: data['messageCount'] as int? ?? 0,
        lastMessageAt: _parseTimestamp(data['lastMessageAt']),
      );
    } catch (e, stack) {
      AppLogger.error('Error fetching channel', e, stack);
      return null;
    }
  }
  
  /// Get messages for a channel
  Stream<List<Message>> getMessages(String channelId, {int limit = 50}) {
    try {
      return _firestore
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return Message(
                id: doc.id,
                channelId: channelId,
                userId: data['userId'] as String? ?? '',
                userName: data['userName'] as String? ?? 'Unknown',
                userAvatarUrl: data['userAvatarUrl'] as String?,
                text: data['text'] as String? ?? '',
                imageUrl: data['imageUrl'] as String?,
                fileType: data['fileType'] as String?,
                fileName: data['fileName'] as String?,
                type: _parseMessageType(data['type']),
                replyToMessageId: data['replyToMessageId'] as String?,
                timestamp: _parseTimestamp(data['timestamp']) ?? DateTime.now(),
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching messages', e, stack);
      rethrow;
    }
  }
  
  /// Send a message to a channel
  Future<void> sendMessage({
    required String channelId,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String text,
    String? imageUrl,
    String? fileType,
    String? fileName,
    String? replyToMessageId,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Create message document
      final messageRef = _firestore
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .doc();
      
      batch.set(messageRef, {
        'userId': userId,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'text': text,
        'imageUrl': imageUrl,
        'fileType': fileType,
        'fileName': fileName,
        'type': 'user',
        'replyToMessageId': replyToMessageId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update channel with last message timestamp and increment message count
      final channelRef = _firestore.collection('channels').doc(channelId);
      batch.update(channelRef, {
        'lastMessageAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      });
      
      await batch.commit();
    } catch (e, stack) {
      AppLogger.error('Error sending message', e, stack);
      rethrow;
    }
  }
  
  /// Send a system message
  Future<void> sendSystemMessage({
    required String channelId,
    required String text,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Create message document
      final messageRef = _firestore
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .doc();
      
      batch.set(messageRef, {
        'userId': 'system',
        'userName': 'System',
        'text': text,
        'type': 'system',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update channel with last message timestamp and increment message count
      final channelRef = _firestore.collection('channels').doc(channelId);
      batch.update(channelRef, {
        'lastMessageAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      });
      
      await batch.commit();
    } catch (e, stack) {
      AppLogger.error('Error sending system message', e, stack);
      rethrow;
    }
  }
  
  /// Delete a message
  Future<void> deleteMessage({
    required String channelId,
    required String messageId,
    required String userId,
    required bool isAdmin,
  }) async {
    try {
      // Check if user is admin or message owner
      if (!isAdmin) {
        final message = await _firestore
            .collection('channels')
            .doc(channelId)
            .collection('messages')
            .doc(messageId)
            .get();
        
        if (!message.exists || message.data() == null) {
          throw Exception('Message not found');
        }
        
        final messageUserId = message.data()!['userId'] as String?;
        if (messageUserId != userId) {
          throw Exception('You are not authorized to delete this message');
        }
      }
      
      // Delete the message
      await _firestore
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .doc(messageId)
          .delete();
      
      // Optional: Update message count in channel
      // This might not be necessary if you don't want to decrement the count for deleted messages
    } catch (e, stack) {
      AppLogger.error('Error deleting message', e, stack);
      rethrow;
    }
  }
  
  /// Create a new AI conversation
  Future<AIConversation> createAIConversation({
    required String userId,
    required String title,
  }) async {
    try {
      final docRef = await _firestore.collection('ai_conversations').add({
        'userId': userId,
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
      
      // Get the document we just created
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        throw Exception('Failed to create AI conversation');
      }
      
      final data = docSnapshot.data()!;
      return AIConversation(
        id: docSnapshot.id,
        userId: userId,
        title: title,
        createdAt: _parseTimestamp(data['createdAt']),
        lastUpdatedAt: _parseTimestamp(data['lastUpdatedAt']),
      );
    } catch (e, stack) {
      AppLogger.error('Error creating AI conversation', e, stack);
      rethrow;
    }
  }
  
  /// Get user's AI conversations
  Stream<List<AIConversation>> getAIConversations(String userId) {
    try {
      return _firestore
          .collection('ai_conversations')
          .where('userId', isEqualTo: userId)
          .orderBy('lastUpdatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return AIConversation(
                id: doc.id,
                userId: userId,
                title: data['title'] as String? ?? 'Untitled Conversation',
                createdAt: _parseTimestamp(data['createdAt']),
                lastUpdatedAt: _parseTimestamp(data['lastUpdatedAt']),
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching AI conversations', e, stack);
      rethrow;
    }
  }
  
  /// Get messages in an AI conversation
  Stream<List<AIMessage>> getAIMessages(String conversationId) {
    try {
      return _firestore
          .collection('ai_conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return AIMessage(
                id: doc.id,
                conversationId: conversationId,
                isUserMessage: data['isUserMessage'] as bool? ?? true,
                content: data['content'] as String? ?? '',
                imageUrl: data['imageUrl'] as String?,
                timestamp: _parseTimestamp(data['timestamp']) ?? DateTime.now(),
              );
            }).toList();
          });
    } catch (e, stack) {
      AppLogger.error('Error fetching AI messages', e, stack);
      rethrow;
    }
  }
  
  /// Send a user message to AI and receive AI response
  Future<void> sendAIMessage({
    required String conversationId,
    required String userMessage,
    String? imageUrl,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Add user message
      final userMsgRef = _firestore
          .collection('ai_conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();
      
      batch.set(userMsgRef, {
        'isUserMessage': true,
        'content': userMessage,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update conversation last updated
      final convRef = _firestore.collection('ai_conversations').doc(conversationId);
      batch.update(convRef, {
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
    } catch (e, stack) {
      AppLogger.error('Error sending AI message', e, stack);
      rethrow;
    }
  }
  
  /// Add AI response to conversation (in a real app, this would be called by a Cloud Function)
  Future<void> _addAIResponse(String conversationId, String aiResponse) async {
    try {
      await _firestore
          .collection('ai_conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
            'isUserMessage': false,
            'content': aiResponse,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e, stack) {
      AppLogger.error('Error adding AI response', e, stack);
      rethrow;
    }
  }
  
  /// Helper methods
  
  MessageType _parseMessageType(dynamic value) {
    if (value == null) return MessageType.user;
    
    switch (value.toString().toLowerCase()) {
      case 'bot':
        return MessageType.bot;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.user;
    }
  }
  
  /// Parse subscription tier from Firestore
  SubscriptionTier _parseTier(dynamic value) {
    if (value == null) return SubscriptionTier.free;
    
    switch (value.toString().toLowerCase()) {
      case 'advanced':
        return SubscriptionTier.advanced;
      case 'elite':
        return SubscriptionTier.elite;
      default:
        return SubscriptionTier.free;
    }
  }
  
  /// Parse Firestore timestamp to DateTime
  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    
    if (value is Timestamp) {
      return value.toDate();
    }
    
    return null;
  }
} 