import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genui_pokemon/ai/ai_client.dart';
import 'package:http/http.dart' as http;

typedef _SendHandler = Future<http.StreamedResponse> Function(http.Request);

class _FakeStreamingClient extends http.BaseClient {
  _FakeStreamingClient(this._handler);

  final _SendHandler _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _handler(request as http.Request);
  }
}

void main() {
  group('OpenAiClient', () {
    test('streams content chunks from SSE responses', () async {
      final mockClient = _FakeStreamingClient((request) async {
        expect(request.url.path, '/v1/chat/completions');
        expect(request.method, 'POST');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'gpt-4o-mini');
        expect(body['stream'], isTrue);

        final stream = Stream<String>.fromIterable([
          'data: {"choices":[{"delta":{"content":"Bulba"}}]}\n',
          'data: {"choices":[{"delta":{"content":"saur"}}]}\n',
          'data: [DONE]\n',
        ]).transform(utf8.encoder);

        return http.StreamedResponse(stream, 200);
      });

      final client = OpenAiClient(apiKey: 'test-key', httpClient: mockClient);

      final chunks = await client
          .sendStream('Kanto starters', history: [])
          .toList();
      expect(chunks, ['Bulba', 'saur']);
    });

    test('preserves whitespace-only content chunks from SSE', () async {
      final mockClient = _FakeStreamingClient((_) async {
        final stream = Stream<String>.fromIterable([
          'data: {"choices":[{"delta":{"content":"Hello"}}]}\n',
          'data: {"choices":[{"delta":{"content":" "}}]}\n',
          'data: {"choices":[{"delta":{"content":"world"}}]}\n',
          'data: [DONE]\n',
        ]).transform(utf8.encoder);

        return http.StreamedResponse(stream, 200);
      });

      final client = OpenAiClient(apiKey: 'test-key', httpClient: mockClient);

      final chunks = await client
          .sendStream('hello', history: const [])
          .toList();
      expect(chunks, ['Hello', ' ', 'world']);
      expect(chunks.join(), 'Hello world');
    });

    test('maps model role to assistant role in request history', () async {
      final completer = Completer<void>();

      final mockClient = _FakeStreamingClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final messages = body['messages'] as List<dynamic>;

        expect(messages[0]['role'], 'system');
        expect(messages[1]['role'], 'assistant');
        expect(messages[2]['role'], 'user');
        completer.complete();

        final stream = Stream<String>.fromIterable([
          'data: [DONE]\n',
        ]).transform(utf8.encoder);

        return http.StreamedResponse(stream, 200);
      });

      final client = OpenAiClient(apiKey: 'test-key', httpClient: mockClient);

      await client
          .sendStream(
            'final prompt',
            history: const [
              (role: 'system', text: 'system instructions'),
              (role: 'model', text: 'prior model output'),
            ],
          )
          .drain<void>();

      await completer.future;
    });

    test('throws when OpenAI responds with non-200', () async {
      final mockClient = _FakeStreamingClient((_) async {
        final stream = Stream<String>.fromIterable([
          '{"error":{"message":"Bad auth"}}',
        ]).transform(utf8.encoder);
        return http.StreamedResponse(stream, 401);
      });

      final client = OpenAiClient(apiKey: 'bad-key', httpClient: mockClient);

      expect(
        () => client.sendStream('hello', history: const []).drain<void>(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
