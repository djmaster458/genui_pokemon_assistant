import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/provider/catalog_provider.dart';
import 'package:genui_pokemon/provider/pokemon_transport_provider.dart';

/// Owns the GenUI conversation lifecycle for the active chat session.
final genuiConversationProvider = Provider<Conversation>((ref) {
  final catalog = ref.watch(catalogProvider);
  final transport = ref.watch(pokemonTransportProvider);
  final controller = SurfaceController(catalogs: [catalog]);
  final conversation = Conversation(
    controller: controller,
    transport: transport,
  );

  ref.onDispose(() {
    conversation.dispose();
    controller.dispose();
  });

  return conversation;
});
