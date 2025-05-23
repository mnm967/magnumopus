import 'dart:io';
import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

/// Provider for the OpenAI service
final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

/// Service to handle interactions with OpenAI API
class OpenAIService {
  // Private field to store API key
  static String? _apiKey;
  
  /// Initialize the OpenAI service with API key
  static void initialize(String apiKey) {
    _apiKey = apiKey;
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
	•	Define any necessary jargon the first time you use it.

Response Framework
	1.	Greet & acknowledge the user's question briefly.
	2.	Confirm understanding by paraphrasing their goal in one sentence.
	3.	Deliver the answer with actionable insights, examples, or mini-checklists.
	4.	Finish with this standard disclaimer (or a close variant) if they are asking about a specific stock or trade:
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
  
  /// Generate an image using DALL-E 3
  /// Returns the URL of the generated image
  Future<String> generateImage({
    required String prompt,
    OpenAIImageSize size = OpenAIImageSize.size1024,
    OpenAIImageStyle style = OpenAIImageStyle.vivid,
  }) async {
    try {
      final response = await OpenAI.instance.image.create(
        model: 'dall-e-3',
        prompt: prompt,
        n: 1,
        size: size,
        style: style,
        responseFormat: OpenAIImageResponseFormat.url,
      );
      
      if (response.data.isEmpty) {
        throw Exception('No images were generated');
      }
      
      return response.data.first.url!;
    } catch (e) {
      debugPrint('Error generating image: $e');
      throw Exception('Failed to generate image: ${e.toString()}');
    }
  }
  
  /// Create a variation of an existing image
  /// Returns the URL of the generated variation
  Future<String> createImageVariation(File image) async {
    try {
      final response = await OpenAI.instance.image.variation(
        image: image,
        n: 1,
        responseFormat: OpenAIImageResponseFormat.url,
        size: OpenAIImageSize.size1024,
      );
      
      if (response.data.isEmpty) {
        throw Exception('No image variations were generated');
      }
      
      return response.data.first.url!;
    } catch (e) {
      debugPrint('Error creating image variation: $e');
      throw Exception('Failed to create image variation: ${e.toString()}');
    }
  }
  
  /// Process an image with ChatGPT to get image-based responses
  /// Uses direct HTTP request to handle images properly
  Future<String> processImageWithChatGPT({
    required String prompt,
    required File imageFile,
    List<Map<String, String>> previousMessages = const [],
  }) async {
    try {
      // Use the stored API key
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key is not set');
      }
      
      // Get file extension and encode image to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      
      // Construct the messages array
      final List<Map<String, dynamic>> messages = [];
      
      // Add system message
      messages.add({
        'role': 'system',
        'content': _getSystemPrompt(),
      });
      
      // Add previous messages if provided
      for (final message in previousMessages) {
        messages.add({
          'role': message['role'] ?? 'user',
          'content': message['content'] ?? '',
        });
      }
      
      // Add the current message with image
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': prompt},
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image'
            }
          }
        ]
      });
      
      // Make direct API call with http package
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': messages,
          'max_tokens': 700,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode != 200) {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return 'Error processing image: ${response.statusCode}';
      }
      
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['choices'] == null || 
          jsonResponse['choices'].isEmpty || 
          jsonResponse['choices'][0]['message'] == null ||
          jsonResponse['choices'][0]['message']['content'] == null) {
        return "I couldn't generate a response for this image.";
      }
      
      return jsonResponse['choices'][0]['message']['content'];
    } catch (e) {
      debugPrint('Error processing image with ChatGPT: $e');
      return 'Sorry, I encountered an issue analyzing this image. Please try again later.';
    }
  }
  
  /// Process a document with ChatGPT to get document-based responses
  /// Uses direct HTTP request to handle documents properly
  Future<String> processDocumentWithChatGPT({
    required String prompt,
    required File documentFile,
    List<Map<String, String>> previousMessages = const [],
  }) async {
    try {
      // Use the stored API key
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key is not set');
      }
      
      // Read the document content
      final documentContent = await documentFile.readAsString();
      
      // Construct the messages array
      final List<Map<String, dynamic>> messages = [];
      
      // Add system message with additional context for document analysis
      final systemPrompt = '''${_getSystemPrompt()}
      
Additional Context: You are now analyzing a document. Focus on extracting and explaining any trading-related information, patterns, or insights from the document. If the document contains financial data, charts, or trading strategies, pay special attention to those elements.''';
      
      messages.add({
        'role': 'system',
        'content': systemPrompt,
      });
      
      // Add previous messages if provided
      for (final message in previousMessages) {
        messages.add({
          'role': message['role'] ?? 'user',
          'content': message['content'] ?? '',
        });
      }
      
      // Add the current message with document content
      messages.add({
        'role': 'user',
        'content': '''$prompt

Document Content:
$documentContent'''
      });
      
      // Make direct API call with http package
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': messages,
          'max_tokens': 1000, // Increased for document analysis
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode != 200) {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return 'Error processing document: ${response.statusCode}';
      }
      
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['choices'] == null || 
          jsonResponse['choices'].isEmpty || 
          jsonResponse['choices'][0]['message'] == null ||
          jsonResponse['choices'][0]['message']['content'] == null) {
        return "I couldn't generate a response for this document.";
      }
      
      return jsonResponse['choices'][0]['message']['content'];
    } catch (e) {
      debugPrint('Error processing document with ChatGPT: $e');
      return 'Sorry, I encountered an issue analyzing this document. Please try again later.';
    }
  }
} 