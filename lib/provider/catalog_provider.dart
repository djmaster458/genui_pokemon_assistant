import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/catalog/pokemon_catalog.dart';

final catalogProvider = Provider<Catalog>((ref) {
  return BasicCatalogItems.asCatalog().copyWith(newItems: [pokemonCard]);
});
