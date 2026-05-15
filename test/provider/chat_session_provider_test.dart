import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_pokemon/ai/ai_client.dart';
import 'package:genui_pokemon/provider/ai_client_provider.dart';
import 'package:genui_pokemon/provider/chat_session_provider.dart';

/// A minimal [AiClient] whose stream can be controlled from tests.
class _MockAiClient implements AiClient {
  final StreamController<String> _controller = StreamController<String>();

  void emit(String chunk) => _controller.add(chunk);
  void close() => _controller.close();

  @override
  Stream<String> sendStream(
    String prompt, {
    required List<AiMessage> history,
  }) => _controller.stream;
}

ProviderContainer _makeContainer(AiClient client) {
  return ProviderContainer(
    overrides: [aiClientProvider.overrideWithValue(client)],
  );
}

void main() {
  group('ConversationNotifier', () {
    late _MockAiClient mockClient;
    late ProviderContainer container;

    setUp(() {
      mockClient = _MockAiClient();
      container = _makeContainer(mockClient);
    });

    tearDown(() {
      mockClient.close();
      container.dispose();
    });

    test('initial state has no messages and is not processing', () {
      final state = container.read(conversationProvider);
      expect(state.messages, isEmpty);
      expect(state.isProcessing, isFalse);
    });

    test('sendMessage adds a user message immediately', () async {
      final future = container
          .read(conversationProvider.notifier)
          .sendMessage('Hello Pokémon!');

      // One event-loop cycle lets the user message be appended.
      await Future<void>.delayed(Duration.zero);

      final messages = container.read(conversationProvider).messages;
      expect(messages, hasLength(1));
      expect(messages.first.isUser, isTrue);
      expect(messages.first.text, 'Hello Pokémon!');

      // Let sendMessage complete cleanly.
      mockClient.close();
      await future;
    });

    test('isProcessing is true while waiting for AI response', () async {
      final future = container
          .read(conversationProvider.notifier)
          .sendMessage('Give me a team');
      await Future<void>.delayed(Duration.zero);

      expect(container.read(conversationProvider).isProcessing, isTrue);

      mockClient.close();
      await future;
    });

    test('AI text chunks accumulate in a single AI message bubble', () async {
      final sendFuture = container
          .read(conversationProvider.notifier)
          .sendMessage('Kanto team');

      mockClient.emit('Bulba');
      mockClient.emit('saur');
      mockClient.close();
      await sendFuture;
      // Pump the event loop so A2uiTransportAdapter text events propagate.
      await Future<void>.delayed(Duration.zero);

      final messages = container.read(conversationProvider).messages;
      // user msg + 1 AI text bubble
      expect(messages, hasLength(2));
      expect(messages[1].isUser, isFalse);
      expect(messages[1].text, 'Bulbasaur');
    });

    test('isProcessing returns to false after response completes', () async {
      final sendFuture = container
          .read(conversationProvider.notifier)
          .sendMessage('Team?');

      await Future<void>.microtask(() {});
      mockClient.emit('Done');
      mockClient.close();
      await sendFuture;

      expect(container.read(conversationProvider).isProcessing, isFalse);
    });

    test('empty messages are ignored', () async {
      await container.read(conversationProvider.notifier).sendMessage('  ');
      expect(container.read(conversationProvider).messages, isEmpty);
    });
  });
}
