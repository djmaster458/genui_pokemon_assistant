import 'package:genui/genui.dart';
import 'package:genui_pokemon/ai/ai_client.dart';
import 'package:genui_pokemon/prompts/system_prompt.dart';

/// GenUI's A2UI transport backed by [AiClient].
///
/// The base adapter owns chunk parsing and exposes both text and A2UI message
/// streams. This class only bridges requests to the selected AI backend and
/// keeps the backend conversation history.
class PokemonTransport extends A2uiTransportAdapter {
  PokemonTransport(this._aiClient, Catalog catalog)
    : _history = [(role: 'system', text: buildSystemPrompt(catalog))],
      super();

  final AiClient _aiClient;
  final List<AiMessage> _history;

  @override
  Future<void> sendRequest(ChatMessage message) async {
    final promptParts = <String>[];
    for (final part in message.parts) {
      if (part is TextPart) {
        promptParts.add(part.text);
      }

      final interaction = part.asUiInteractionPart;
      if (interaction != null) {
        promptParts.add(
          'Generated UI interaction:\n${interaction.interaction}',
        );
      }
    }
    final prompt = promptParts.where((part) => part.isNotEmpty).join('\n\n');
    if (prompt.isEmpty) return;

    _history.add((role: 'user', text: prompt));
    final responseBuffer = StringBuffer();

    await for (final chunk in _aiClient.sendStream(prompt, history: _history)) {
      responseBuffer.write(chunk);
      addChunk(chunk);
    }

    _history.add((role: 'model', text: responseBuffer.toString()));
  }
}
