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
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

/// Provider for the message input
final messageInputProvider = StateProvider<String>((ref) => '');

/// Provider for the message sending state
final messageSendingStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Provider for file attachment
final attachmentProvider = StateProvider<File?>((ref) => null);

/// Provider for attachment type
final attachmentTypeProvider = StateProvider<String?>((ref) => null);

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
    final attachmentType = ref.watch(attachmentTypeProvider);
    
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
                        if (attachmentType != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              attachmentType,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
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
                      ref.read(attachmentTypeProvider.notifier).state = null;
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
                      
                      // Image or file attachment (if any)
                      if (message.imageUrl != null) ...[
                        if (message.text.isNotEmpty) const SizedBox(height: 8),
                        _buildLocalAttachmentPreview(context, message),
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
  
  /// Build attachment preview for selected file
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
    
    // For documents
    if (['.pdf', '.doc', '.docx', '.txt'].contains(extension)) {
      IconData iconData;
      if (extension == '.pdf') {
        iconData = Icons.picture_as_pdf;
      } else if (['.doc', '.docx'].contains(extension)) {
        iconData = Icons.description;
      } else {
        iconData = Icons.text_snippet;
      }
      
      return Icon(
        iconData,
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
  
  /// Build attachment preview based on local file path
  Widget _buildLocalAttachmentPreview(BuildContext context, Message message) {
    final fileUrl = message.imageUrl;
    if (fileUrl == null) return const SizedBox.shrink();
    
    // Try to determine file type
    String fileType = '';
    
    try {
      // Try to access additional metadata
      final dynamic messageData = message;
      if (messageData != null) {
        try {
          if (messageData.fileType != null) {
            fileType = messageData.fileType;
          } else if (messageData.toJson != null) {
            final data = messageData.toJson();
            if (data is Map && data.containsKey('fileType')) {
              fileType = data['fileType'] as String? ?? '';
            }
          }
        } catch (e) {
          // Ignore any errors trying to access these fields
          debugPrint('Error accessing message metadata: $e');
        }
      }
      
      // Fallback to extension if no explicit type
      if (fileType.isEmpty) {
        final ext = path.extension(fileUrl).toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) {
          fileType = 'image';
        } else if (ext == '.pdf') {
          fileType = 'pdf';
        } else if (['.doc', '.docx'].contains(ext)) {
          fileType = 'doc';
        } else if (ext == '.txt') {
          fileType = 'txt';
        }
      }
    } catch (e) {
      debugPrint('Error determining file type: $e');
    }
    
    // Check if the file exists locally
    final file = File(fileUrl);
    final fileExists = file.existsSync();
    
    // Based on file type, render appropriate widget
    if (fileType == 'image' && fileExists) {
      // For images, try to display them
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width * 0.6,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image: $error');
            return Container(
              height: 120,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Image could not be loaded',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // For documents, show an appropriate icon and file name
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(fileType),
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                path.basename(fileUrl),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }
  
  /// Get an appropriate icon for file type
  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  /// Open URL helper method
  Future<void> _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
  
  /// Select an attachment from device storage
  Future<void> _selectAttachment(BuildContext context, WidgetRef ref) async {
    // Show options dialog
    final attachType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Choose attachment type',
          style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: AppTheme.primaryColor),
              title: const Text('Image', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: AppTheme.primaryColor),
              title: const Text('Document', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'document'),
            ),
          ],
        ),
      ),
    );

    if (attachType == null) return;

    // Handle based on type
    File? file;
    
    try {
      switch (attachType) {
        case 'image':
          // Use image picker to select an image
          final picker = ImagePicker();
          final pickedFile = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,  // Compress the image a bit
          );
          
          if (pickedFile != null) {
            file = File(pickedFile.path);
            ref.read(attachmentTypeProvider.notifier).state = 'image';
          }
          break;
          
        case 'document':
          // Use file picker to select a document
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
          );
          
          if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
            file = File(result.files.single.path!);
            ref.read(attachmentTypeProvider.notifier).state = 'document';
          }
          break;
      }
      
      if (file != null) {
        ref.read(attachmentProvider.notifier).state = file;
      }
    } catch (e) {
      debugPrint('Error selecting attachment: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting attachment: $e')),
        );
      }
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
    final attachmentType = ref.read(attachmentTypeProvider);
    
    // Early return if both message and attachment are empty
    if (text.trim().isEmpty && attachment == null) return;
    
    // Clear the input field
    ref.read(messageInputProvider.notifier).state = '';
    
    // Set the sending state to loading
    ref.read(messageSendingStateProvider.notifier).state = const AsyncValue.loading();
    
    String? localFilePath;
    String? fileType;
    String? fileName;
    
    try {
      // Get the current user
      final userAsyncValue = ref.read(currentUserProvider);
      
      final user = userAsyncValue.value;
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Handle file locally if there's an attachment
      if (attachment != null) {
        // Generate a unique ID for this file
        final uuid = const Uuid().v4();
        fileName = path.basename(attachment.path);
        
        // For images, save the file to temp directory
        final fileBytes = await attachment.readAsBytes();
        
        try {
          // Use the system's temp directory for storing files
          final tempDir = Directory.systemTemp;
          if (!await tempDir.exists()) {
            await tempDir.create(recursive: true);
          }
          
          // Create a local copy of the file
          localFilePath = '${tempDir.path}/${uuid}_$fileName';
          final localFile = File(localFilePath);
          await localFile.writeAsBytes(fileBytes);
          
          // Determine file type
          fileType = attachmentType ?? 'document';
          
          // If it's not explicitly set, try to determine from extension
          if (fileType == null) {
            final ext = path.extension(fileName).toLowerCase();
            if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) {
              fileType = 'image';
            } else if (ext == '.pdf') {
              fileType = 'pdf';
            } else if (['.doc', '.docx'].contains(ext)) {
              fileType = 'doc';
            } else if (ext == '.txt') {
              fileType = 'txt';
            } else {
              fileType = 'document';
            }
          }
        } catch (e) {
          debugPrint('Error saving file locally: $e');
          // Continue with the original file if local save fails
          localFilePath = attachment.path;
        }
      }
      
      // Send the message using the repository
      final communityRepository = ref.read(communityRepositoryProvider);
      await communityRepository.sendMessage(
        channelId: channelId,
        userId: user.id,
        userName: user.name,
        userAvatarUrl: user.avatarUrl,
        text: text.trim(),
        imageUrl: localFilePath,
        fileType: fileType,
        fileName: fileName,
      );
      
      // Reset attachment
      ref.read(attachmentProvider.notifier).state = null;
      ref.read(attachmentTypeProvider.notifier).state = null;
      
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
  
  /// Format the timestamp for display
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 