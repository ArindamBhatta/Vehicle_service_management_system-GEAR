import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:learn_riverpod/core/service/audit_service.dart';
import 'package:learn_riverpod/core/service/restoration_service.dart';
import 'package:learn_riverpod/core/utils/logger.dart';

class ChatMessage {
  final String id;
  final String content;
  final String role; // 'user', 'assistant', or 'system'
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });
}

/// A configurable service for chat functionality
abstract class BaseChatService {
  /// Send a message to the chat service and get a response
  Future<ChatMessage> sendMessage(String message, List<ChatMessage> history);

  /// Clear the chat history
  void clearHistory();

  /// Get initial system messages that define the chat context
  List<ChatMessage> getInitialSystemMessages();

  /// Set the restoration service for project queries
  void setRestorationService(RestorationService? service);

  /// Check if the message is a project query
  bool isProjectQuery(String message);

  /// Handle project-related queries
  Future<ChatMessage?> handleProjectQuery(String message);
}

/// Implementation of Groq API for chat
class GroqChatService implements BaseChatService {
  final String apiKey;
  final String model;
  final String apiEndpoint;
  RestorationService? _restorationService;
  AuditService? _auditService;

  // Rate limiting - store user queries with timestamps
  final LinkedHashMap<String, DateTime> _queryRateLimit = LinkedHashMap();
  final int _maxQueriesPerMinute = 10; // Maximum queries per minute
  final Duration _rateLimitWindow = const Duration(minutes: 1);

  GroqChatService({
    required this.apiKey,
    this.model = 'llama3-70b-8192',
    this.apiEndpoint = 'https://api.groq.com/openai/v1/chat/completions',
    AuditService? auditService,
  }) {
    _auditService = auditService;
  }

  // Setter for audit service
  set auditService(AuditService? service) {
    _auditService = service;
  }

  @override
  void setRestorationService(RestorationService? service) {
    _restorationService = service;
  }

  @override
  List<ChatMessage> getInitialSystemMessages() {
    return [
      ChatMessage(
        id: 'system-1',
        content:
            '''You are Maveriq, RestoMag's AI assistant, specializing exclusively in vehicle restoration and garage management for the RestoMag application.

IMPORTANT: You should ONLY answer questions related to:
1. The RestoMag garage application and its features
2. Vehicle restoration and management topics
3. Automotive repair, maintenance, and restoration
4. Garage or shop management for vehicle restoration businesses
5. The user's restoration projects

If a user asks about anything unrelated to RestoMag or vehicle restoration, politely explain that you can only assist with RestoMag and vehicle restoration topics.

Your knowledge is specific to the RestoMag platform, which helps manage vehicle restoration projects, track service history, and coordinate between car owners and restoration shops.

You can also help users query their restoration projects. If they ask about their projects, you'll receive information about their projects and can provide them with details.
''',
        role: 'system',
        timestamp: DateTime.now(),
      ),
    ];
  }

  @override
  bool isProjectQuery(String message) {
    // Keywords that indicate a project query
    final projectKeywords = [
      'my project',
      'my projects',
      'my restoration',
      'my restorations',
      'restoration project',
      'restoration projects',
      'show me my projects',
      'what projects',
      'view projects',
      'list projects',
      'projects status',
    ];

    final lowerMessage = message.toLowerCase();

    return projectKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  @override
  Future<ChatMessage?> handleProjectQuery(String message) async {
    // Audit logging for project queries
    final timestamp = DateTime.now();
    final userId = _restorationService?.userId ?? 'unknown';
    int? resultCount;
    String? errorMessage;
    bool processingComplete = false;

    try {
      // Log to console for debugging
      AppLogger.logger.i(
        'Project query requested',
        error: {
          'userId': userId,
          'timestamp': timestamp.toIso8601String(),
          'query': message,
        },
      );

      // Check rate limiting
      if (_isRateLimited(userId)) {
        AppLogger.logger.w(
          'Rate limit exceeded for user',
          error: {'userId': userId, 'timestamp': timestamp.toIso8601String()},
        );

        // Log rate limit to audit service
        if (_auditService != null) {
          await _auditService!.logRateLimit(
            userId: userId,
            resourceType: 'chat',
            requestCount: _getQueryCount(userId),
            limit: _maxQueriesPerMinute,
            window: '${_rateLimitWindow.inMinutes} minutes',
          );
        }

        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              "I'm processing too many requests right now. Please try again in a minute.",
          role: 'assistant',
          timestamp: DateTime.now(),
        );
      }

      // Record this query for rate limiting
      _recordQuery(userId);

      if (_restorationService == null) {
        errorMessage = 'Restoration service unavailable';

        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              "I can't access your projects right now. Please try again later.",
          role: 'assistant',
          timestamp: DateTime.now(),
        );
      }

      // Get raw project data as List<Map> instead of using the RestorationProject model
      final response = await _restorationService!.client
          .from('restoration_projects')
          .select('*, vehicles(*)')
          .eq('owner_id', _restorationService!.userId)
          .order('created_at', ascending: false);

      final projects = response as List<dynamic>;
      resultCount = projects.length;
      processingComplete = true;

      if (projects.isEmpty) {
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              "You don't have any restoration projects yet. Would you like to know how to create one?",
          role: 'assistant',
          timestamp: DateTime.now(),
        );
      }

      // Format the projects into a readable response
      final formatter = DateFormat('MMM d, yyyy');
      final sb = StringBuffer();

      sb.writeln("Here are your restoration projects:");
      sb.writeln();

      for (int i = 0; i < projects.length; i++) {
        // Format projects safely
        try {
          // Use the raw Map directly
          final Map<String, dynamic> projectData = projects[i];

          sb.writeln(
            "📋 Project #${i + 1}: ${projectData['name'] ?? 'Unnamed Project'}",
          );
          sb.writeln("Status: ${_formatStatus(projectData['status'])}");

          if (projectData.containsKey('start_date') &&
              projectData['start_date'] != null) {
            final startDate = DateTime.parse(
              projectData['start_date'].toString(),
            );
            sb.writeln("Started: ${formatter.format(startDate)}");
          }

          if (projectData.containsKey('estimated_completion_date') &&
              projectData['estimated_completion_date'] != null) {
            final estDate = DateTime.parse(
              projectData['estimated_completion_date'].toString(),
            );
            sb.writeln("Estimated completion: ${formatter.format(estDate)}");
          }

          if (projectData.containsKey('description') &&
              projectData['description'] != null &&
              projectData['description'].toString().isNotEmpty) {
            sb.writeln("Description: ${projectData['description']}");
          }

          if (projectData.containsKey('budget') &&
              projectData['budget'] != null) {
            final budget =
                double.tryParse(projectData['budget'].toString()) ?? 0.0;
            sb.writeln("Budget: \$${budget.toStringAsFixed(2)}");
          }

          sb.writeln(); // Add a blank line between projects
        } catch (e) {
          AppLogger.logger.e('Error formatting project', error: e);
          sb.writeln("📋 Project #${i + 1}: [Details unavailable]");
          sb.writeln();
        }
      }

      sb.writeln(
        "You can ask me for more details about any specific project by its name or number.",
      );

      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: sb.toString(),
        role: 'assistant',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Enhanced error logging for audit
      errorMessage = e.toString();
      AppLogger.logger.e(
        'Error handling project query',
        error: e,
        stackTrace: StackTrace.current,
      );

      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            "I encountered an error while trying to fetch your projects. Please try again later.",
        role: 'assistant',
        timestamp: DateTime.now(),
      );
    } finally {
      // Only log to audit service here, not in the initial call
      if (_auditService != null && processingComplete) {
        try {
          await _auditService!.logProjectQuery(
            userId: userId,
            queryText: message,
            queryType: 'project',
            resultCount: resultCount,
            errorMessage: errorMessage,
          );
        } catch (e) {
          AppLogger.logger.e(
            'Failed to log project query to audit service',
            error: e,
          );
        }
      }
    }
  }

  String _formatStatus(dynamic status) {
    if (status == null) return 'Pending';

    final statusStr = status.toString().split('.').last;
    // Convert camelCase to Title Case with spaces
    final formattedStatus = statusStr.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return formattedStatus.substring(0, 1).toUpperCase() +
        formattedStatus.substring(1);
  }

  @override
  Future<ChatMessage> sendMessage(
    String message,
    List<ChatMessage> history,
  ) async {
    final userId = _restorationService?.userId ?? 'anonymous';
    ChatMessage? response;
    bool success = false;
    String? errorMessage;

    try {
      // First check if this is a project query
      if (isProjectQuery(message)) {
        final projectResponse = await handleProjectQuery(message);
        if (projectResponse != null) {
          // Log successful project query in handleProjectQuery method already
          return projectResponse;
        }
      }

      // No need to log here, we'll log once after processing with the result
      // Remove the first audit log call

      // Prepare the messages for the API
      final messages = <Map<String, dynamic>>[];

      // Add initial system messages that define the bot's behavior
      for (var systemMessage in getInitialSystemMessages()) {
        messages.add({
          'role': systemMessage.role,
          'content': systemMessage.content,
        });
      }

      // Add previous messages from history, up to 20 messages
      final recentHistory = history.length > 20
          ? history.sublist(history.length - 20)
          : history;

      for (var msg in recentHistory) {
        messages.add({'role': msg.role, 'content': msg.content});
      }

      // Add the current message
      messages.add({'role': 'user', 'content': message});

      // Prepare the request body
      final requestBody = {
        'model': model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1024,
      };

      AppLogger.logger.d('Sending chat request to Groq API');

      // Make the API request
      final apiResponse = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (apiResponse.statusCode == 200) {
        // Parse the response
        final jsonResponse = jsonDecode(apiResponse.body);
        final assistantMessage =
            jsonResponse['choices'][0]['message']['content'];

        response = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: assistantMessage,
          role: 'assistant',
          timestamp: DateTime.now(),
        );

        success = true;
        return response;
      } else {
        // Handle error
        errorMessage = 'API Error: ${apiResponse.statusCode}';
        AppLogger.logger.e(
          'Error from Groq API',
          error: {
            'statusCode': apiResponse.statusCode,
            'body': apiResponse.body,
          },
        );

        response = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              'I encountered a problem processing your message. Please try again later.',
          role: 'assistant',
          timestamp: DateTime.now(),
        );

        return response;
      }
    } catch (e) {
      // Handle unexpected errors
      errorMessage = 'Exception: ${e.toString()}';
      AppLogger.logger.e('Unexpected error in chat service', error: e);

      response = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'I encountered an unexpected error processing your message. Please try again later.',
        role: 'assistant',
        timestamp: DateTime.now(),
      );

      return response;
    } finally {
      // Single audit logging point - after processing is complete
      if (_auditService != null) {
        try {
          await _auditService!.logProjectQuery(
            userId: userId,
            queryText: message,
            queryType: 'chat',
            resultCount: success ? 1 : null,
            errorMessage: errorMessage,
          );
        } catch (e) {
          AppLogger.logger.e('Failed to log to audit service', error: e);
        }
      }
    }
  }

  @override
  void clearHistory() {
    // No persistent history to clear in this implementation
    // History is managed by the chat widget
  }

  /// Check if the user has exceeded the rate limit
  bool _isRateLimited(String userId) {
    // Remove old queries outside the rate limit window
    final now = DateTime.now();
    _queryRateLimit.removeWhere(
      (key, timestamp) =>
          now.difference(timestamp) > _rateLimitWindow ||
          key.split(':')[0] != userId,
    );

    // Count queries from this user in the window
    final userQueryCount = _queryRateLimit.entries
        .where((entry) => entry.key.startsWith('$userId:'))
        .length;

    return userQueryCount >= _maxQueriesPerMinute;
  }

  /// Record a query for rate limiting
  void _recordQuery(String userId) {
    final now = DateTime.now();
    final queryId = '$userId:${now.millisecondsSinceEpoch}';
    _queryRateLimit[queryId] = now;

    // Clean up old entries
    if (_queryRateLimit.length > 100) {
      // Keep only the most recent 50 entries
      final entriesToKeep = _queryRateLimit.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      _queryRateLimit.clear();
      for (var i = 0; i < 50 && i < entriesToKeep.length; i++) {
        _queryRateLimit[entriesToKeep[i].key] = entriesToKeep[i].value;
      }
    }
  }

  int _getQueryCount(String userId) {
    final now = DateTime.now();
    int count = 0;

    // Scan through queries and count those within the window
    _queryRateLimit.forEach((id, timestamp) {
      if (id.startsWith(userId) &&
          now.difference(timestamp) <= _rateLimitWindow) {
        count++;
      }
    });

    return count;
  }
}

/// Factory to create different chat service implementations
class ChatServiceFactory {
  static BaseChatService create(String serviceType) {
    switch (serviceType) {
      case 'groq':
        final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
        if (apiKey.isEmpty) {
          AppLogger.logger.e('GROQ_API_KEY not found in .env file');
          throw Exception('GROQ_API_KEY not found in .env file');
        }
        return GroqChatService(apiKey: apiKey);
      // Add more service implementations here
      default:
        throw Exception('Unknown chat service type: $serviceType');
    }
  }
}
