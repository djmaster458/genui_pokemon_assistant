import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/catalog/pokemon_catalog.dart';

/// A provider that supplies a catalog of items, including both basic gen UI items and Pokémon cards.
final catalogProvider = Provider<Catalog>((ref) {
  return BasicCatalogItems.asCatalog().copyWith(newItems: [
    PokemonCatalog.pokemonCard,
  ]);
});
