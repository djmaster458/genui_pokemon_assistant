import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

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

/// OpenAI Chat Completions implementation of [AiClient].
///
/// Uses server-sent event streaming to emit text deltas as they arrive.
final class OpenAiClient implements AiClient {
  OpenAiClient({
    required String apiKey,
    String model = 'gpt-4o-mini',
    Uri? baseUri,
    http.Client? httpClient,
  }) : _apiKey = apiKey,
       _modelName = model,
       _baseUri = baseUri ?? Uri.parse('https://api.openai.com/v1/'),
       _httpClient = httpClient ?? http.Client();

  final String _apiKey;
  final String _modelName;
  final Uri _baseUri;
  final http.Client _httpClient;

  @override
  Stream<String> sendStream(
    String prompt, {
    required List<AiMessage> history,
  }) async* {
    final messages = <Map<String, String>>[
      for (final msg in history)
        {'role': _mapRole(msg.role), 'content': msg.text},
      {'role': 'user', 'content': prompt},
    ];

    final request = http.Request('POST', _baseUri.resolve('chat/completions'))
      ..headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      })
      ..body = jsonEncode({
        'model': _modelName,
        'messages': messages,
        'stream': true,
      });

    final response = await _httpClient.send(request);
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw StateError('OpenAI request failed (${response.statusCode}): $body');
    }

    await for (final line
        in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (!line.startsWith('data: ')) continue;

      final payload = line.substring('data: '.length).trim();
      if (payload == '[DONE]') break;

      final json = jsonDecode(payload) as Map<String, dynamic>;
      final choices = json['choices'];
      if (choices is! List || choices.isEmpty) continue;

      final firstChoice = choices.first;
      if (firstChoice is! Map<String, dynamic>) continue;

      final delta = firstChoice['delta'];
      if (delta is! Map<String, dynamic>) continue;

      final content = delta['content'];
      if (content is String && content.isNotEmpty) {
        yield content;
      }
    }
  }

  String _mapRole(String role) {
    if (role == 'model') return 'assistant';
    if (role == 'system') return 'system';
    return 'user';
  }
}
