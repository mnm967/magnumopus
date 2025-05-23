import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:magnumopus/core/theme/app_theme.dart';
import 'package:magnumopus/core/widgets/app_button.dart';
import 'package:magnumopus/core/widgets/app_loading_indicator.dart';
import 'package:magnumopus/data/models/community_model.dart';
import 'package:magnumopus/data/models/user_model.dart';
import 'package:magnumopus/data/repositories/auth_repository.dart';
import 'package:magnumopus/data/repositories/community_repository.dart';
import 'package:magnumopus/services/openai_service.dart';
import 'package:magnumopus/services/stock_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Global key for navigator state access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Simplified ChatState to handle chat loading states
class ChatState {
  final bool isLoading;
  final String? error;
  
  const ChatState({
    this.isLoading = false,
    this.error,
  });
  
  ChatState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
  
  // Reset to non-loading state
  ChatState reset() {
    return const ChatState(isLoading: false, error: null);
  }
}

/// StateNotifier to manage loading state
class ChatStateNotifier extends StateNotifier<ChatState> {
  ChatStateNotifier() : super(const ChatState());
  
  void startLoading() {
    state = state.copyWith(isLoading: true, error: null);
  }
  
  void setError(String error) {
    state = state.copyWith(isLoading: false, error: error);
    
    // Auto-reset error state after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.reset();
      }
    });
  }
  
  void reset() {
    state = state.reset();
  }
}

/// Global provider for chat state
final chatStateProvider = StateNotifierProvider<ChatStateNotifier, ChatState>((ref) {
  return ChatStateNotifier();
});

/// Provider for the current AI conversation
final currentAIConversationProvider = StateProvider<AIConversation?>((ref) => null);

/// Provider for messages in the current AI conversation
final aiMessagesProvider = StreamProvider.family<List<AIMessage>, String>((ref, conversationId) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  return communityRepository.getAIMessages(conversationId);
});

/// Provider to get user's AI conversations
final userAIConversationsProvider = StreamProvider<List<AIConversation>>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  
  // First get the current user to determine user ID
  return authRepository.currentUser
    .where((user) => user != null) // Filter out null users
    .take(1) // Only take the first non-null user
    .asyncExpand((user) {
      // Now subscribe to the conversations stream with this user ID
      return communityRepository.getAIConversations(user!.id);
    });
});

/// Provider for managing the user's input message
final userMessageProvider = StateProvider<String>((ref) => '');

/// Provider for market data context
final marketDataProvider = FutureProvider<String>((ref) {
  final stockService = ref.watch(stockServiceProvider);
  return stockService.getFormattedMarketContext();
});

/// Provider to control whether market data is visible
final showMarketDataProvider = StateProvider<bool>((ref) => false);

/// Global function to reset loading state
void resetLoadingState(WidgetRef ref) {
  try {
    debugPrint('Attempting to reset loading state via global function');
    ref.read(chatStateProvider.notifier).state.reset();
  } catch (e) {
    debugPrint('Error in global resetLoadingState: $e');
  }
}

/// Widget for example prompt item
class ExamplePromptItem extends HookConsumerWidget {
  final String prompt;
  final void Function(BuildContext, WidgetRef, String) onTap;
  
  const ExamplePromptItem({
    required this.prompt,
    required this.onTap,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handlePromptTap(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  prompt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: -20,
      end: 0,
      duration: 300.ms,
    );
  }
  
  void _handlePromptTap(BuildContext context, WidgetRef ref) {
    // Get the repositories and conversation state
    final authRepo = ref.read(authRepositoryProvider);
    final communityRepo = ref.read(communityRepositoryProvider);
    final conversation = ref.read(currentAIConversationProvider);
    final chatNotifier = ref.read(chatStateProvider.notifier);
    final openAIService = ref.read(openAIServiceProvider);
    final isChatNotifierMounted = chatNotifier.mounted;
    
    // Start the process
    chatNotifier.startLoading();
    
    // Get current user and create conversation
    authRepo.currentUser.first.then((user) {
      if (user == null) {
        if (isChatNotifierMounted) {
          chatNotifier.setError('User not logged in');
        }
        return;
      }
      
      // Title for the conversation
      final title = prompt.length > 30 ? '${prompt.substring(0, 30)}...' : prompt;
      
      // Use existing conversation or create new one
      final futureConversation = conversation != null 
          ? Future.value(conversation)
          : communityRepo.createAIConversation(userId: user.id, title: title);
          
      futureConversation.then((convo) {
        // Check if still mounted
        if (!isChatNotifierMounted) return;
        
        // Set as current conversation if new
        if (conversation == null && ref.read(currentAIConversationProvider.notifier).mounted) {
          ref.read(currentAIConversationProvider.notifier).state = convo;
        }
        
        // Send the message
        communityRepo.sendAIMessage(
          conversationId: convo.id,
          userMessage: prompt,
        ).then((_) {
          // Check if still mounted
          if (!isChatNotifierMounted) return;
          
          // Get previous messages for context
          communityRepo.getAIMessages(convo.id).first.then((messages) {
            // Check if still mounted
            if (!isChatNotifierMounted) return;
            
            // Format messages for OpenAI
            final previousMessages = messages
              .take(10)
              .toList()
              .reversed
              .map((msg) => {
                'role': msg.isUserMessage ? 'user' : 'assistant',
                'content': msg.content,
              })
              .toList();
              
            // Get AI response
            openAIService.getChatResponse(
              userMessage: prompt,
              previousMessages: previousMessages,
              stockData: null,
            ).then((response) {
              // Check if still mounted
              if (!isChatNotifierMounted) return;
              
              // Save the AI response
              FirebaseFirestore.instance
                .collection('ai_conversations')
                .doc(convo.id)
                .collection('messages')
                .add({
                  'isUserMessage': false,
                  'content': response,
                  'timestamp': FieldValue.serverTimestamp(),
                })
                .then((_) {
                  // Reset loading state if still mounted
                  if (isChatNotifierMounted) {
                    chatNotifier.reset();
                  }
                })
                .catchError((e) {
                  debugPrint('Error adding AI response: $e');
                  if (isChatNotifierMounted) {
                    chatNotifier.setError('Error saving AI response');
                  }
                });
            }).catchError((e) {
              debugPrint('Error getting AI response: $e');
              if (isChatNotifierMounted) {
                chatNotifier.setError('Error getting AI response');
              }
            });
          }).catchError((e) {
            debugPrint('Error getting messages: $e');
            if (isChatNotifierMounted) {
              chatNotifier.setError('Error getting messages');
            }
          });
        }).catchError((e) {
          debugPrint('Error sending message: $e');
          if (isChatNotifierMounted) {
            chatNotifier.setError('Error sending message');
          }
        });
      }).catchError((e) {
        debugPrint('Error creating conversation: $e');
        if (isChatNotifierMounted) {
          chatNotifier.setError('Error creating conversation');
        }
      });
    }).catchError((e) {
      debugPrint('Error getting user: $e');
      if (isChatNotifierMounted) {
        chatNotifier.setError('Error getting user');
      }
    });
  }
}

/// Screen for interacting with the AI assistant
class AIAssistantScreen extends HookConsumerWidget {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use useTextEditingController from flutter_hooks to create a persistent controller
    final TextEditingController messageController = useTextEditingController();
    final userMessage = ref.watch(userMessageProvider);
    final currentConversation = ref.watch(currentAIConversationProvider);
    final conversations = ref.watch(userAIConversationsProvider);
    final chatState = ref.watch(chatStateProvider);
    final showMarketData = ref.watch(showMarketDataProvider);
    
    // Use useEffect to sync controller text with provider state
    useEffect(() {
      final listener = () {
        final text = messageController.text;
        if (text != userMessage) {
          ref.read(userMessageProvider.notifier).state = text;
        }
      };
      messageController.addListener(listener);
      return () => messageController.removeListener(listener);
    }, [messageController]);
    
    // Use useEffect to sync provider state with controller
    useEffect(() {
      if (messageController.text != userMessage) {
        messageController.text = userMessage;
      }
      return null;
    }, [userMessage]);
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          // Toggle market data button
          IconButton(
            icon: Icon(
              showMarketData ? Icons.analytics : Icons.analytics_outlined,
              color: showMarketData ? AppTheme.primaryColor : null,
            ),
            onPressed: () {
              ref.read(showMarketDataProvider.notifier).state = !showMarketData;
            },
            tooltip: 'Toggle Market Data',
          ),
          
          // New conversation button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewConversation(context, ref),
          ),
          
          // Conversation history button
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showConversationHistory(context, ref, conversations),
          ),
        ],
      ),
      body: GestureDetector(
        // Dismiss keyboard when tapping outside of any text field
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            // Assistant introduction or selected conversation title
            _buildHeader(context, currentConversation),
            
            // Market data panel (conditionally visible)
            if (showMarketData)
              _buildMarketDataPanel(context, ref),
            
            // Messages area
            Expanded(
              child: currentConversation != null
                  ? _buildConversationMessages(context, ref, currentConversation.id)
                  : _buildWelcomeScreen(context),
            ),
            
            // Input area
            _buildMessageInput(
              context,
              ref,
              messageController,
              userMessage,
              currentConversation,
              chatState,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the market data panel
  Widget _buildMarketDataPanel(BuildContext context, WidgetRef ref) {
    final marketDataAsync = ref.watch(marketDataProvider);
    
    return Container(
      height: 160,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: marketDataAsync.when(
        data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 18,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Market Data',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.refresh(marketDataProvider);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Refresh',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      data,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(size: 24),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading market data',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
      begin: -1.0,
      end: 0.0,
      duration: 300.ms,
      curve: Curves.easeOutQuad,
    );
  }
  
  /// Build the header section of the screen
  Widget _buildHeader(BuildContext context, AIConversation? conversation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          
          // AI Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trading Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build the welcome screen when no conversation is selected
  Widget _buildWelcomeScreen(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AI Icon
              Icon(
                Icons.auto_awesome,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.8),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 1.seconds,
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: 24),
              
              // Welcome text
              Text(
                'Hello, I\'m your Trading Assistant',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'I can help you with trading concepts, analyze charts, summarize course content, and more.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Example questions
              ..._buildExamplePrompts(context),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build example prompts for the AI
  List<Widget> _buildExamplePrompts(BuildContext context) {
    final examples = [
      'What is a candlestick pattern and how do I read it?',
      'Explain the concept of support and resistance in trading.',
      'What strategies can I use for risk management?',
      'Help me understand the difference between technical and fundamental analysis.',
    ];
    
    return examples.map((example) => ExamplePromptItem(
      prompt: example,
      onTap: (_, __, ___) {}, // We don't need this anymore as the item handles it internally
    )).toList();
  }
  
  /// Build the messages in a conversation
  Widget _buildConversationMessages(BuildContext context, WidgetRef ref, String conversationId) {
    final messagesAsync = ref.watch(aiMessagesProvider(conversationId));
    // Create a ScrollController to detect scrolling
    final scrollController = useScrollController();
    
    // Add a listener to dismiss keyboard when scrolling
    useEffect(() {
      void dismissKeyboardOnScroll() {
        // If any scroll occurs, dismiss the keyboard
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
      }
      
      scrollController.addListener(dismissKeyboardOnScroll);
      
      // Clean up when widget is disposed
      return () {
        scrollController.removeListener(dismissKeyboardOnScroll);
      };
    }, [scrollController]);
    
    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'Start chatting with the AI assistant',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          );
        }
        
        return GestureDetector(
          // Dismiss keyboard when tapping anywhere in the list
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: messages.length,
            reverse: true,
            itemBuilder: (context, index) {
              final message = messages[messages.length - 1 - index]; // Reverse order
              return _buildMessageBubble(context, message);
            },
          ),
        );
      },
      loading: () => const Center(
        child: AppLoadingIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading conversation: $error',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
  
  /// Build a message bubble for the conversation
  Widget _buildMessageBubble(BuildContext context, AIMessage message) {
    final isUserMessage = message.isUserMessage;
    
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUserMessage
              ? AppTheme.primaryColor.withOpacity(0.8)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUserMessage ? const Radius.circular(0) : null,
            bottomLeft: !isUserMessage ? const Radius.circular(0) : null,
          ),
          border: !isUserMessage
              ? Border.all(color: Colors.white.withOpacity(0.05))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message content
            Text(
              message.content,
              style: TextStyle(
                color: isUserMessage ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
            
            // If there's an image, display it
            if (message.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildAttachmentWidget(context, message),
              ),
            
            // Timestamp
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: (isUserMessage ? Colors.white : Colors.white).withOpacity(0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 300.ms,
      ),
    );
  }
  
  /// Build an attachment widget based on its type
  Widget _buildAttachmentWidget(BuildContext context, AIMessage message) {
    final fileUrl = message.imageUrl;
    if (fileUrl == null) return const SizedBox.shrink();
    
    // Try to determine file type
    String fileType = '';
    String? fileName;
    
    try {
      // Try to access additional metadata using dynamic approach
      // This accesses Firestore document data that may not be in the AIMessage model
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
            if (data is Map && data.containsKey('fileName')) {
              fileName = data['fileName'] as String?;
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
    
    // Based on file type, render appropriate widget
    if (fileType == 'image') {
      // For images, try to display them
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: FileImage(File(fileUrl)),
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
                fileName ?? path.basename(fileUrl),
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
  
  /// Build the message input area
  Widget _buildMessageInput(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
    String message,
    AIConversation? conversation,
    ChatState chatState,
  ) {
    final isLoading = chatState.isLoading;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attach button (for image upload)
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: Colors.white.withOpacity(0.6),
            ),
            onPressed: () => _handleAttach(context, ref, conversation),
          ),
          
          // Text input field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              autofocus: false,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              minLines: 1,
              enabled: !isLoading && conversation != null,
              onTap: () {
                if (controller.text != ref.read(userMessageProvider)) {
                  controller.text = ref.read(userMessageProvider);
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
              },
              // Add callback to hide keyboard when done is pressed
              onEditingComplete: () => FocusScope.of(context).unfocus(),
              // Handle submission with the keyboard's enter/done button
              onSubmitted: conversation != null && !isLoading && message.isNotEmpty 
                  ? (_) => _sendMessageSafely(context, ref, controller, conversation)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          
          // Send button
          if (isLoading)
            GestureDetector(
              onLongPress: () {
                // Reset loading state if it gets stuck
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resetting loading state...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                ref.read(chatStateProvider.notifier).reset();
              },
              onTap: () {
                // Show a message about long-pressing to reset
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Long-press to reset if loading gets stuck'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Tooltip(
                message: 'Long-press to reset if loading gets stuck',
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const AppLoadingIndicator(size: 24),
                ),
              ),
            )
          else
            CircleAvatar(
              backgroundColor: message.isNotEmpty && conversation != null
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withOpacity(0.3),
              radius: 24,
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: message.isEmpty || conversation == null
                    ? null
                    : () => _sendMessageSafely(context, ref, controller, conversation),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Create a new conversation
  Future<void> _createNewConversation(BuildContext context, WidgetRef ref) async {
    final authRepository = ref.read(authRepositoryProvider);
    
    // Get current user
    final user = await authRepository.currentUser.first;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to use the AI Assistant'),
        ),
      );
      return;
    }
    
    try {
      // Show a dialog to enter conversation title
      final title = await showDialog<String>(
        context: context,
        builder: (context) => _buildNewConversationDialog(context),
      );
      
      if (title != null && title.isNotEmpty) {
        // Create a new conversation in the repository
        final communityRepository = ref.read(communityRepositoryProvider);
        final conversation = await communityRepository.createAIConversation(
          userId: user.id,
          title: title,
        );
        
        // Set the new conversation as current
        ref.read(currentAIConversationProvider.notifier).state = conversation;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating conversation: $e'),
        ),
      );
    }
  }
  
  /// Build a dialog for creating a new conversation
  Widget _buildNewConversationDialog(BuildContext context) {
    final titleController = TextEditingController();
    
    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: const Text(
        'New Conversation',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Enter a title for your conversation',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
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
        TextButton(
          onPressed: () {
            Navigator.pop(context, titleController.text);
          },
          child: Text(
            'Create',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
  
  /// Show the conversation history
  void _showConversationHistory(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AIConversation>> conversationsAsync,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Conversation History',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.1)),
              Expanded(
                child: conversationsAsync.when(
                  data: (conversations) {
                    if (conversations.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No conversations yet',
                            style: TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ListTile(
                          title: Text(
                            conversation.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            _formatDate(conversation.createdAt ?? DateTime.now()),
                            style: TextStyle(color: Colors.white.withOpacity(0.6)),
                          ),
                          leading: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppTheme.primaryColor,
                          ),
                          onTap: () {
                            // Set selected conversation and close sheet
                            ref.read(currentAIConversationProvider.notifier).state = conversation;
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: AppLoadingIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading conversations: $error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Send a message safely without relying on context that might be disposed
  void _sendMessageSafely(
    BuildContext context, 
    WidgetRef ref,
    TextEditingController controller, 
    AIConversation conversation
  ) {
    // Capture message immediately
    final message = controller.text.trim();
    if (message.isEmpty) return;
    
    // Clear the input field via controller directly
    controller.clear();
    
    // Update state if possible
    try {
      if (ref.read(userMessageProvider.notifier).mounted) {
        ref.read(userMessageProvider.notifier).state = '';
      }
      if (ref.read(chatStateProvider.notifier).mounted) {
        ref.read(chatStateProvider.notifier).startLoading();
      }
      
      // Start the message sending process without awaiting
      _actualSendMessage(ref, message, conversation).catchError((e) {
        debugPrint('Error in message sending process: $e');
      });
    } catch (e) {
      debugPrint('Error preparing to send message: $e');
    }
  }
  
  /// Actual message sending without UI updates that might use context
  Future<void> _actualSendMessage(
    WidgetRef ref,
    String message,
    AIConversation conversation,
  ) async {
    // Capture all needed references and values at the beginning to avoid ref access after widget disposal
    final communityRepository = ref.read(communityRepositoryProvider);
    final openAIService = ref.read(openAIServiceProvider);
    final shouldIncludeMarketData = ref.read(showMarketDataProvider);
    final stockService = shouldIncludeMarketData ? ref.read(stockServiceProvider) : null;
    final chatStateNotifier = ref.read(chatStateProvider.notifier);
    final isChatStateNotifierMounted = chatStateNotifier.mounted;
    
    try {
      // Get market data for context if enabled
      String? marketContext;
      if (shouldIncludeMarketData && stockService != null) {
        try {
          marketContext = await stockService.getFormattedMarketContext();
        } catch (e) {
          debugPrint('Error getting market data: $e');
        }
      }
      
      // Get previous messages to build conversation history
      final previousMessages = <Map<String, String>>[];
      
      try {
        final messages = await communityRepository.getAIMessages(conversation.id).first;
        
        // Build conversation history (limited to last 10 messages)
        final recentMessages = messages.take(10).toList().reversed;
        for (final msg in recentMessages) {
          previousMessages.add({
            'role': msg.isUserMessage ? 'user' : 'assistant',
            'content': msg.content,
          });
        }
      } catch (e) {
        debugPrint('Error getting previous messages: $e');
        // Continue with empty message history
      }
      
      // Send the user message to the repository (for display)
      await communityRepository.sendAIMessage(
        conversationId: conversation.id,
        userMessage: message,
      );
      
      // Get AI response using OpenAI service
      final response = await openAIService.getChatResponse(
        userMessage: message,
        previousMessages: previousMessages,
        stockData: marketContext,
        newsContext: null,
      );
      
      // Add AI response to the conversation
      await _addAIResponse(communityRepository, conversation.id, response);
      
      // Reset state after sending if still mounted
      if (isChatStateNotifierMounted) {
        chatStateNotifier.reset();
      }
    } catch (e) {
      debugPrint('Error in message sending process: $e');
      if (isChatStateNotifierMounted) {
        chatStateNotifier.setError('Error sending message');
      }
    }
  }
  
  /// Add AI response to the conversation
  Future<void> _addAIResponse(
    CommunityRepository repository,
    String conversationId,
    String aiResponse,
  ) async {
    try {
      // Since the repository has a private _addAIResponse method,
      // we'll need to implement a similar functionality here
      await FirebaseFirestore.instance
        .collection('ai_conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
          'isUserMessage': false,
          'content': aiResponse,
          'timestamp': FieldValue.serverTimestamp(),
        });
    } catch (e) {
      debugPrint('Error adding AI response: $e');
      rethrow;
    }
  }
  
  /// Format a timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
  
  /// Format a date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
  
  /// Handle file attachment (images and documents)
  void _handleAttach(BuildContext context, WidgetRef ref, AIConversation? conversation) async {
    if (conversation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start a conversation first')),
      );
      return;
    }

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
    String? fileName;
    
    // Start loading
    ref.read(chatStateProvider.notifier).startLoading();
    
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
            fileName = path.basename(pickedFile.path);
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
            fileName = result.files.single.name;
          }
          break;
      }
      
      if (file == null) {
        ref.read(chatStateProvider.notifier).reset();
        return;
      }
      
      // Generate a unique ID for this file
      final uuid = const Uuid().v4();
      
      // For images, save the file to app documents directory
      final fileBytes = await file.readAsBytes();
      String localFilePath = '';
      
      try {
        // Use the application's temp directory for storing files (works on both mobile and web)
        final tempDir = Directory.systemTemp;
        if (!await tempDir.exists()) {
          await tempDir.create(recursive: true);
        }
        
        // Create a local copy of the file
        localFilePath = '${tempDir.path}/${uuid}_$fileName';
        final localFile = File(localFilePath);
        await localFile.writeAsBytes(fileBytes);
        
      } catch (e) {
        debugPrint('Error saving file locally: $e');
        // Continue with the original file if local save fails
        localFilePath = file.path;
      }
      
      // Create a message prompt
      String userMessage = attachType == 'image'
          ? 'Image for analysis:'
          : 'Document for analysis:';
          
      String fileType = attachType == 'image' 
          ? 'image' 
          : path.extension(fileName ?? 'file').replaceAll('.', '');
          
      // Add the file message to the chat
      await FirebaseFirestore.instance
          .collection('ai_conversations')
          .doc(conversation.id)
          .collection('messages')
          .add({
            'isUserMessage': true,
            'content': userMessage,
            'imageUrl': localFilePath,
            'fileType': fileType,
            'fileName': fileName,
            'timestamp': FieldValue.serverTimestamp(),
          });
      
      // Get AI response for the file
      final openAIService = ref.read(openAIServiceProvider);
      String aiResponse;
      
      if (attachType == 'image') {
        // Process the image directly with the OpenAI API
        aiResponse = await openAIService.processImageWithChatGPT(
          prompt: "Please analyze this image and tell me what you see, especially anything related to trading, charts, or financial information.",
          imageFile: file,
        );
      } else {
        // Process the document with the OpenAI API
        aiResponse = await openAIService.processDocumentWithChatGPT(
          prompt: "Please analyze this document and extract any relevant trading information, patterns, or insights. If there are any charts, data, or trading strategies, please explain them in detail.",
          documentFile: file,
        );
      }
      
      // Add AI response directly to Firestore
      await FirebaseFirestore.instance
        .collection('ai_conversations')
        .doc(conversation.id)
        .collection('messages')
        .add({
          'isUserMessage': false,
          'content': aiResponse,
          'timestamp': FieldValue.serverTimestamp(),
        });
      
      // Update conversation last updated time
      await FirebaseFirestore.instance
          .collection('ai_conversations')
          .doc(conversation.id)
          .update({
            'lastUpdatedAt': FieldValue.serverTimestamp(),
          });
      
      // Reset loading state
      ref.read(chatStateProvider.notifier).reset();
    } catch (e) {
      debugPrint('Error handling attachment: $e');
      ref.read(chatStateProvider.notifier).setError('Error processing attachment');
    }
  }
} 