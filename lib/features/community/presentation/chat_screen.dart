import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

/// Provider for the message input
final messageInputProvider = StateProvider<String>((ref) => '');

/// Provider for the message sending state
final messageSendingStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Provider for file attachment
final attachmentProvider = StateProvider<File?>((ref) => null);

/// Provider for attachment upload progress
final attachmentUploadProgressProvider = StateProvider<double?>((ref) => null);

/// Provider for channel messages
final channelMessagesProvider = StreamProvider.family<List<Message>, String>((ref, channelId) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  return communityRepository.getMessages(channelId);
});

/// Simple chat screen for a community channel
class ChatScreen extends HookConsumerWidget {
  final Channel? channel;
  
  const ChatScreen({
    super.key,
    this.channel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Since we don't have the full Channel implementation yet, let's create a placeholder
    // Once we have the proper model, we can replace this
    final channelName = channel?.name ?? 'Community Chat';
    final channelId = channel?.id ?? 'general';
    final channelTopic = channel?.topic ?? 'General discussion';
    
    final messageInput = ref.watch(messageInputProvider);
    final messageSendingState = ref.watch(messageSendingStateProvider);
    final userAsyncValue = ref.watch(currentUserProvider);
    final messagesAsyncValue = ref.watch(channelMessagesProvider(channelId));
    final attachment = ref.watch(attachmentProvider);
    final uploadProgress = ref.watch(attachmentUploadProgressProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(channelName),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Discussion banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discussion Topic',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  channelTopic,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                if (channel?.isPrivate == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Private discussion',
                          style: TextStyle(
                            color: AppTheme.primaryColor.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          
          // Messages area
          Expanded(
            child: userAsyncValue.when(
              data: (user) {
                if (user == null) {
                  return const Center(
                    child: Text(
                      'Please log in to view messages',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                
                return messagesAsyncValue.when(
                  data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to send a message!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                        final message = messages[index];
                    return _buildMessageItem(context, message, user.id);
                  },
                    );
                  },
                  loading: () => const Center(
                    child: AppLoadingIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading messages: $error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: AppLoadingIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading user: $error',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
          
          // Attachment preview (if any)
          if (attachment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.cardColor.withOpacity(0.7),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: _getAttachmentPreview(attachment),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          path.basename(attachment.path),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (uploadProgress != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(
                              value: uploadProgress,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      ref.read(attachmentProvider.notifier).state = null;
                      ref.read(attachmentUploadProgressProvider.notifier).state = null;
                    },
                  ),
                ],
            ),
          ),
          
          // Message input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    onPressed: () => _selectAttachment(context, ref),
                  ),
                  
                  // Message input field
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) {
                        ref.read(messageInputProvider.notifier).state = value;
                      },
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Send button
                  messageSendingState is AsyncLoading
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: AppLoadingIndicator(size: 20),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.send,
                            color: messageInput.trim().isEmpty && attachment == null
                                ? Colors.white.withOpacity(0.3)
                                : AppTheme.primaryColor,
                          ),
                          onPressed: messageInput.trim().isEmpty && attachment == null
                              ? null
                              : () => _sendMessage(
                                  context,
                                  ref,
                                  channelId,
                                  messageInput,
                                ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a message item in the chat
  Widget _buildMessageItem(BuildContext context, Message message, String currentUserId) {
    final isCurrentUser = message.userId == currentUserId;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar (only for other users)
          if (!isCurrentUser) 
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildAvatar(message.userAvatarUrl, message.userName),
            ),
          
          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Username (only for other users)
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.userName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                
                // Message bubble
                Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppTheme.primaryColor.withOpacity(0.8)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isCurrentUser ? const Radius.circular(0) : null,
            bottomLeft: !isCurrentUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      // Text message (if any)
                      if (message.text.isNotEmpty)
            Text(
              message.text,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
                      
                      // Image attachment (if any)
                      if (message.imageUrl != null) ...[
                        if (message.text.isNotEmpty) const SizedBox(height: 8),
                        _buildAttachmentPreview(context, message.imageUrl!),
                      ],
                      
                      // Timestamp
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: (isCurrentUser ? Colors.white : Colors.white).withOpacity(0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // User avatar (only for current user)
          if (isCurrentUser) 
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildAvatar(message.userAvatarUrl, message.userName),
            ),
        ],
      ),
    );
  }
  
  /// Build avatar widget
  Widget _buildAvatar(String? avatarUrl, String userName) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppTheme.cardColor,
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildAvatarFallback(userName),
        ),
      );
    } else {
      return _buildAvatarFallback(userName);
    }
  }
  
  /// Build fallback avatar with initials
  Widget _buildAvatarFallback(String userName) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  /// Build attachment preview widget
  Widget _buildAttachmentPreview(BuildContext context, String url) {
    final extension = path.extension(url).toLowerCase();
    
    // Check if the attachment is an image
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
      return GestureDetector(
        onTap: () => _openUrl(url),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            height: 200,
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.black12,
              child: const Center(child: AppLoadingIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 100,
              color: Colors.black12,
              child: const Center(
                child: Icon(Icons.error, color: Colors.white54),
              ),
            ),
          ),
        ),
      );
    }
    
    // For video
    if (['.mp4', '.mov', '.wmv', '.avi'].contains(extension)) {
      return _buildFileAttachmentView(
        context, url, 'Video File', Icons.video_file, Colors.redAccent);
    }
    
    // For documents
    if (['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx'].contains(extension)) {
      return _buildFileAttachmentView(
        context, url, 'Document', Icons.insert_drive_file, Colors.blueAccent);
    }
    
    // For other files
    return _buildFileAttachmentView(
      context, url, 'File Attachment', Icons.attach_file, Colors.purpleAccent);
  }
  
  /// Build file attachment view
  Widget _buildFileAttachmentView(
    BuildContext context, 
    String url, 
    String label,
    IconData icon,
    Color iconColor,
  ) {
    final fileName = path.basename(url).split('?').first;
    
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get attachment preview for selected file
  Widget _getAttachmentPreview(File file) {
    final extension = path.extension(file.path).toLowerCase();
    
    // For images
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic'].contains(extension)) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.image,
          size: 30,
          color: Colors.white.withOpacity(0.7),
        ),
      );
    }
    
    // For videos
    if (['.mp4', '.mov', '.wmv', '.avi', '.flv'].contains(extension)) {
      return Icon(
        Icons.video_file,
        size: 30,
        color: Colors.red.withOpacity(0.8),
      );
    }
    
    // For documents
    if (['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx'].contains(extension)) {
      return Icon(
        Icons.insert_drive_file,
        size: 30,
        color: Colors.blue.withOpacity(0.8),
      );
    }
    
    // For any other file type
    return Icon(
      Icons.attach_file,
      size: 30,
      color: Colors.purple.withOpacity(0.8),
    );
  }
  
  /// Open URL helper method
  Future<void> _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
  
  /// Select an attachment from device storage
  Future<void> _selectAttachment(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      final file = File(result.files.first.path!);
      ref.read(attachmentProvider.notifier).state = file;
    }
  }
  
  /// Send a message to the channel
  Future<void> _sendMessage(
    BuildContext context,
    WidgetRef ref,
    String channelId,
    String text,
  ) async {
    // Get current attachment (if any)
    final attachment = ref.read(attachmentProvider);
    
    // Early return if both message and attachment are empty
    if (text.trim().isEmpty && attachment == null) return;
    
    // Clear the input field
    ref.read(messageInputProvider.notifier).state = '';
    
    // Set the sending state to loading
    ref.read(messageSendingStateProvider.notifier).state = const AsyncValue.loading();
    
    String? fileUrl;
    
    try {
      // Get the current user
      final userAsyncValue = ref.read(currentUserProvider);
      
      final user = userAsyncValue.value;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Handle file upload if there's an attachment
      if (attachment != null) {
        fileUrl = await _uploadFile(attachment, channelId, user.id, ref);
      }
      
      // Send the message using the repository
      final communityRepository = ref.read(communityRepositoryProvider);
      await communityRepository.sendMessage(
        channelId: channelId,
        userId: user.id,
        userName: user.name,
        userAvatarUrl: user.avatarUrl,
        text: text.trim(),
        imageUrl: fileUrl,
      );
      
      // Reset attachment
      ref.read(attachmentProvider.notifier).state = null;
      ref.read(attachmentUploadProgressProvider.notifier).state = null;
      
      // Reset the sending state
      if (context.mounted) {
        ref.read(messageSendingStateProvider.notifier).state = const AsyncValue.data(null);
      }
    } catch (e) {
      // Handle errors
      ref.read(messageSendingStateProvider.notifier).state = AsyncValue.error(e, StackTrace.current);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  /// Upload a file to Firebase Storage
  Future<String> _uploadFile(File file, String channelId, String userId, WidgetRef ref) async {
    // Create a unique filename using UUID
    final uuid = const Uuid().v4();
    final extension = path.extension(file.path);
    final fileName = '$uuid$extension';
    
    // Create storage reference
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child('chat_attachments/$channelId/$userId/$fileName');
    
    // Upload the file with progress tracking
    final uploadTask = fileRef.putFile(file);
    
    // Monitor upload progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      ref.read(attachmentUploadProgressProvider.notifier).state = progress;
    });
    
    // Wait for upload to complete
    await uploadTask;
    
    // Get download URL
    final downloadUrl = await fileRef.getDownloadURL();
    return downloadUrl;
  }
  
  /// Format the timestamp for display
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 