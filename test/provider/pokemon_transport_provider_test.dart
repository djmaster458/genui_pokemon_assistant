import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/ai/ai_client.dart';
import 'package:genui_pokemon/provider/ai_client_provider.dart';
import 'package:genui_pokemon/provider/pokemon_transport_provider.dart';

class _AiCall {
  _AiCall({required this.prompt, required this.history});

  final String prompt;
  final List<AiMessage> history;
}

class _CapturingAiClient implements AiClient {
  final Queue<List<String>> queuedResponses = Queue<List<String>>();
  final List<_AiCall> calls = [];

  @override
  Stream<String> sendStream(String prompt, {required List<AiMessage> history}) {
    calls.add(_AiCall(prompt: prompt, history: List<AiMessage>.from(history)));
    final chunks = queuedResponses.isEmpty
        ? const <String>[]
        : queuedResponses.removeFirst();
    return Stream<String>.fromIterable(chunks);
  }
}

ProviderContainer _makeContainer(AiClient client) {
  return ProviderContainer(
    overrides: [aiClientProvider.overrideWithValue(client)],
  );
}

void main() {
  group('pokemonTransportProvider', () {
    test('creates one instance per container until invalidated', () {
      final container = _makeContainer(_CapturingAiClient());
      addTearDown(container.dispose);

      final first = container.read(pokemonTransportProvider);
      final second = container.read(pokemonTransportProvider);
      expect(identical(first, second), isTrue);

      container.invalidate(pokemonTransportProvider);
      final third = container.read(pokemonTransportProvider);
      expect(identical(first, third), isFalse);
    });

    test('seeds system history and forwards streamed text chunks', () async {
      final client = _CapturingAiClient()
        ..queuedResponses.add(['Bulba', 'saur']);
      final container = _makeContainer(client);
      addTearDown(container.dispose);

      final transport = container.read(pokemonTransportProvider);
      final textChunks = <String>[];
      final sub = transport.incomingText.listen(textChunks.add);
      addTearDown(sub.cancel);

      await transport.sendRequest(ChatMessage.user('Kanto starters'));
      await Future<void>.delayed(Duration.zero);

      expect(client.calls, hasLength(1));
      expect(client.calls.first.prompt, 'Kanto starters');
      expect(client.calls.first.history.first.role, 'system');
      expect(client.calls.first.history.last, (
        role: 'user',
        text: 'Kanto starters',
      ));
      expect(textChunks.join(), 'Bulbasaur');
    });
  });
}
