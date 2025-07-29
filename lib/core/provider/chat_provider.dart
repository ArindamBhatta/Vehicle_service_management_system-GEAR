// Provides a list of vehicle makes for dropdowns
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/provider/auth_provider.dart';
import 'package:learn_riverpod/core/provider/restoration_provider.dart';
import 'package:learn_riverpod/core/service/chat_service.dart';

final chatServiceProviderApi = Provider<BaseChatService>((ref) {
  // Get API key from environment
  final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  // Create chat service
  final chatService = GroqChatService(
    apiKey: apiKey,
    auditService: ref.watch(auditServiceProvider),
  );

  // Set the restoration service if available
  final restorationService = ref.watch(restorationServiceProvider);
  if (restorationService != null) {
    chatService.setRestorationService(restorationService);
  }

  return chatService;
});

// Chat state provider to manage the chat state
final chatHistoryProvider = StateProvider<List<ChatMessage>>((ref) => []);

/// Provider for the chat service
final chatServiceProvider = Provider<BaseChatService>((ref) {
  // Default to Groq, but could be changed based on configuration
  return ChatServiceFactory.create('groq');
});
