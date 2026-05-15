import 'package:google_generative_ai/google_generative_ai.dart';

/// A single message in the AI conversation history.
typedef AiMessage = ({String role, String text});

/// Abstraction over a streaming generative-AI backend.
/// Injecting this interface makes the session layer testable.
abstract interface class AiClient {
  /// Streams response text chunks for [prompt] given the previous [history].
  Stream<String> sendStream(String prompt, {required List<AiMessage> history});
}

/// Google Gemini implementation of [AiClient].
///
/// The [GenerativeModel] is built lazily on the first call to [sendStream],
/// picking up the system instruction from the first `role: 'system'` entry
/// in [history] (added by [PokemonTransport.setSystemInstruction]).
final class GeminiAiClient implements AiClient {
  GeminiAiClient({required String apiKey, String model = 'gemini-2.5-flash'})
    : _apiKey = apiKey,
      _modelName = model;

  final String _apiKey;
  final String _modelName;
  GenerativeModel? _geminiModel;

  @override
  Stream<String> sendStream(
    String prompt, {
    required List<AiMessage> history,
  }) async* {
    // Build the model once, capturing the system instruction from history.
    _geminiModel ??= _buildModel(history);

    final contents = [
      for (final msg in history.where((m) => m.role != 'system'))
        msg.role == 'user'
            ? Content.text(msg.text)
            : Content.model([TextPart(msg.text)]),
      Content.text(prompt),
    ];

    final stream = _geminiModel!.generateContentStream(contents);
    await for (final chunk in stream) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) yield text;
    }
  }

  GenerativeModel _buildModel(List<AiMessage> history) {
    final systemMsg = history
        .where((m) => m.role == 'system')
        .firstOrNull
        ?.text;
    return GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: systemMsg != null ? Content.system(systemMsg) : null,
    );
  }
}
