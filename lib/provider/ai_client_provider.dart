import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui_pokemon/ai/ai_client.dart';

/// Override this in [ProviderScope] (or in tests) to inject a custom client.
final aiClientProvider = Provider<AiClient>((ref) {
  throw UnimplementedError(
    'aiClientProvider must be overridden in ProviderScope.',
  );
});