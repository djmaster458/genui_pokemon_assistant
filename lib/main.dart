import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui_pokemon/provider/ai_client_provider.dart';
import 'package:logging/logging.dart';

import 'ai/ai_client.dart';
import 'screens/chat_screen.dart';

const _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.loggerName}: ${record.message}');
  });

  assert(
    _geminiApiKey.isNotEmpty,
    'GEMINI_API_KEY must be set as an environment variable to run the app.',
  );

  runApp(
    ProviderScope(
      overrides: [
        aiClientProvider.overrideWithValue(
          GeminiAiClient(apiKey: _geminiApiKey),
        ),
      ],
      child: const PokemonApp(),
    ),
  );
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
