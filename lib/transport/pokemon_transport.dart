// ---------------------------------------------------------------------------
// Transport — bridges AiClient ↔ A2uiTransportAdapter
// ---------------------------------------------------------------------------

import 'package:genui/genui.dart';
import 'package:genui_pokemon/ai/ai_client.dart';
import 'package:genui_pokemon/prompts/system_prompt.dart';

/// Implements [Transport] by routing through [AiClient] while managing
/// the conversation history locally.
class PokemonTransport implements Transport {
  PokemonTransport(this._aiClient, Catalog catalog)
    : _history = [(role: 'system', text: buildSystemPrompt(catalog))];

  final AiClient _aiClient;
  final A2uiTransportAdapter _adapter = A2uiTransportAdapter();
  final List<AiMessage> _history;

  @override
  Stream<A2uiMessage> get incomingMessages => _adapter.incomingMessages;

  @override
  Stream<String> get incomingText => _adapter.incomingText;

  @override
  Future<void> sendRequest(ChatMessage message) async {
    // Extract text from all parts of the genui ChatMessage.
    final buffer = StringBuffer();
    for (final part in message.parts) {
      if (part is TextPart) {
        buffer.write(part.text);
      }
    }
    final prompt = buffer.toString();
    if (prompt.isEmpty) return;

    _history.add((role: 'user', text: prompt));
    final responseBuffer = StringBuffer();

    await for (final chunk in _aiClient.sendStream(prompt, history: _history)) {
      responseBuffer.write(chunk);
      _adapter.addChunk(chunk);
    }

    _history.add((role: 'model', text: responseBuffer.toString()));
  }

  @override
  void dispose() => _adapter.dispose();
}
