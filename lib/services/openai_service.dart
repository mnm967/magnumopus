import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the OpenAI service
final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

/// Service to handle interactions with OpenAI API
class OpenAIService {
  /// Initialize the OpenAI service with API key
  static void initialize(String apiKey) {
    OpenAI.apiKey = apiKey;
    OpenAI.showResponsesLogs = false; // Set to true for debugging
    OpenAI.showLogs = false; // Set to true for debugging
  }
  
  /// Send a message to ChatGPT and get a response
  Future<String> getChatResponse({
    required String userMessage,
    List<Map<String, String>> previousMessages = const [],
    String? stockData,
    String? newsContext,
  }) async {
    try {
      // Build conversation history
      List<OpenAIChatCompletionChoiceMessageModel> messages = [];
      
      // Add system prompt with instructions
      String systemPrompt = 'You are a knowledgeable trading assistant. Provide helpful, accurate information about trading, investments, and financial markets.';
      
      // Add context if available
      if (stockData != null) {
        systemPrompt += '\n\nCurrent stock data: $stockData';
      }
      
      if (newsContext != null) {
        systemPrompt += '\n\nRecent market news: $newsContext';
      }
      
      // Add system message
      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              systemPrompt,
            ),
          ],
        ),
      );
      
      // Add previous conversation messages
      for (final message in previousMessages) {
        messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            role: message['role'] == 'user' 
                ? OpenAIChatMessageRole.user 
                : OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                message['content'] ?? '',
              ),
            ],
          ),
        );
      }
      
      // Add current user message
      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              userMessage,
            ),
          ],
        ),
      );
      
      // Make API call
      final completion = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: messages,
        maxTokens: 700,
        temperature: 0.7,
      );
      
      if (completion.choices.isEmpty) {
        return "I couldn't generate a response. Please try again.";
      }
      
      final responseContent = completion.choices.first.message.content;
      if (responseContent == null || responseContent.isEmpty) {
        return "I received an empty response. Please try again.";
      }
      
      // Extract text from the response content
      final textContents = responseContent
          .whereType<OpenAIChatCompletionChoiceMessageContentItemModel>()
          .map((item) => item.text ?? "")
          .join(" ");
      
      return textContents.isNotEmpty 
          ? textContents 
          : "I couldn't generate a proper text response. Please try again.";
    } catch (e) {
      debugPrint('Error getting chat response: $e');
      return 'Sorry, I encountered an issue processing your request. Please try again later.';
    }
  }
  
  /// Stream chat responses for a more interactive experience
  Stream<String> streamChatResponse({
    required String userMessage,
    List<Map<String, String>> previousMessages = const [],
    String? stockData,
    String? newsContext,
  }) async* {
    try {
      // Build conversation history
      List<OpenAIChatCompletionChoiceMessageModel> messages = [];
      
      // Add system prompt with instructions
      String systemPrompt = 'You are a knowledgeable trading assistant. Provide helpful, accurate information about trading, investments, and financial markets.';
      
      // Add context if available
      if (stockData != null) {
        systemPrompt += '\n\nCurrent stock data: $stockData';
      }
      
      if (newsContext != null) {
        systemPrompt += '\n\nRecent market news: $newsContext';
      }
      
      // Add system message
      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              systemPrompt,
            ),
          ],
        ),
      );
      
      // Add previous conversation messages
      for (final message in previousMessages) {
        messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            role: message['role'] == 'user' 
                ? OpenAIChatMessageRole.user 
                : OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                message['content'] ?? '',
              ),
            ],
          ),
        );
      }
      
      // Add current user message
      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              userMessage,
            ),
          ],
        ),
      );
      
      // Make streaming API call
      final stream = await OpenAI.instance.chat.createStream(
        model: 'gpt-3.5-turbo',
        messages: messages,
        maxTokens: 700,
        temperature: 0.7,
      );
      
      String responseText = '';
      
      await for (final streamResponse in stream) {
        if (streamResponse.choices.isNotEmpty && 
            streamResponse.choices.first.delta.content != null &&
            streamResponse.choices.first.delta.content!.isNotEmpty) {
          final content = streamResponse.choices.first.delta.content!;
          for (var item in content) {
            final text = item?.text;
            if (text != null) {
              responseText += text;
              yield responseText;
            }
          }
        }
      }
      
      if (responseText.isEmpty) {
        yield "I couldn't generate a proper response. Please try again.";
      }
    } catch (e) {
      debugPrint('Error streaming chat response: $e');
      yield 'Sorry, I encountered an issue processing your request. Please try again later.';
    }
  }
} 