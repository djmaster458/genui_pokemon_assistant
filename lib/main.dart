import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui_pokemon/provider/ai_client_provider.dart';
import 'package:logging/logging.dart';

import 'ai/ai_client.dart';
import 'screens/chat_screen.dart';

const _aiBackend = String.fromEnvironment('AI_BACKEND', defaultValue: 'gemini');
const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
const _geminiModel = String.fromEnvironment(
  'GEMINI_MODEL',
  defaultValue: 'gemini-2.5-flash',
);
const _openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
const _openAiModel = String.fromEnvironment(
  'OPENAI_MODEL',
  defaultValue: 'gpt-4o-mini',
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.loggerName}: ${record.message}');
  });

  final aiClient = _buildAiClient();

  runApp(
    ProviderScope(
      overrides: [aiClientProvider.overrideWithValue(aiClient)],
      child: const PokemonApp(),
    ),
  );
}

AiClient _buildAiClient() {
  switch (_aiBackend.toLowerCase()) {
    case 'gemini':
      assert(
        _geminiApiKey.isNotEmpty,
        'GEMINI_API_KEY must be set when AI_BACKEND=gemini.',
      );
      return GeminiAiClient(apiKey: _geminiApiKey, model: _geminiModel);
    case 'openai':
      assert(
        _openAiApiKey.isNotEmpty,
        'OPENAI_API_KEY must be set when AI_BACKEND=openai.',
      );
      return OpenAiClient(apiKey: _openAiApiKey, model: _openAiModel);
    default:
      throw ArgumentError(
        'Unsupported AI_BACKEND "$_aiBackend". Use "gemini" or "openai".',
      );
  }
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.red);
    return MaterialApp(
      title: 'Pokémon Team Builder',
      theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      darkTheme: ThemeData(
        colorScheme: colorScheme.copyWith(brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
