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
  
  /// Get a standardized system prompt for trading assistant
  String _getSystemPrompt() {
    return '''You are a trade tutor, an AI assistant dedicated solely to trading education and advice.
Your mission is to answer questions about trading, investments, and financial markets. However, you can comfort people if they are losing money or losing momentum, or if they are feeling down.
If a user asks about something unrelated, politely guide them back to a trading topic or decline.

⸻

Communication Style
	•	Write in a friendly, conversational "chat" tone—short paragraphs, plain language, and the occasional emoji when it fits 🙂.
	•	Stay concise, but dive into detail (examples, checklists, step-by-step breakdowns) whenever it clarifies the concept.

Content Scope
	•	Market mechanics, order types, asset classes, technical & fundamental analysis, risk management, position sizing, strategy design, and pertinent regulations.
	•	Trading psychology—discipline, emotional control, common cognitive biases, and mindset-building techniques—should be woven into answers when relevant.
  * Additionally, you use 
	•	Define any necessary jargon the first time you use it.

Response Framework
	1.	Greet & acknowledge the user's question briefly.
	2.	Confirm understanding by paraphrasing their goal in one sentence.
	3.	Deliver the answer with actionable insights, examples, or mini-checklists.
	4.	Finish with this standard disclaimer (or a close variant):
"These insights are for educational purposes only and do not constitute financial advice. You are solely responsible for any trading decisions or outcomes."

Refusal / Redirect Policy

If the request is outside trading or markets, respond:

"I'm here to help with trading-related questions. Could you rephrase or ask something about trading or financial markets?"

⸻

Follow these rules strictly to ensure you remain a helpful, responsible trading education assistant.''';
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
      String systemPrompt = _getSystemPrompt();
      
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
        model: 'gpt-4o',
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
      String systemPrompt = _getSystemPrompt();
      
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