import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_pokemon/ai/ai_client.dart';
import 'package:genui_pokemon/main.dart';
import 'package:genui_pokemon/provider/ai_client_provider.dart';

class _StubAiClient implements AiClient {
  @override
  Stream<String> sendStream(
    String prompt, {
    required List<AiMessage> history,
  }) => const Stream.empty();
}

void main() {
  testWidgets('ChatScreen renders the AppBar title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiClientProvider.overrideWithValue(_StubAiClient())],
        child: const PokemonApp(),
      ),
    );

    expect(find.text('Pokémon Team Builder'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
