import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui_pokemon/provider/ai_client_provider.dart';
import 'package:genui_pokemon/provider/catalog_provider.dart';
import 'package:genui_pokemon/transport/pokemon_transport.dart';

/// Conversation-scoped transport backed by the current [AiClient].
final pokemonTransportProvider = Provider<PokemonTransport>((ref) {
  final aiClient = ref.watch(aiClientProvider);
  final catalog = ref.watch(catalogProvider);
  final transport = PokemonTransport(aiClient, catalog);
  ref.onDispose(transport.dispose);
  return transport;
});
