import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/catalog/pokemon_catalog.dart';
import 'package:genui_pokemon/provider/catalog_provider.dart';

void main() {
  group('CatalogProvider', () {
    test('provides basic gen UI and pokemon catalog items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final catalog = container.read(catalogProvider);
      expect(catalog.items, contains(PokemonCatalog.pokemonCard));
      expect(catalog.items, contains(PokemonCatalog.pokemonTeam));
      expect(catalog.items, containsAll(BasicCatalogItems.asCatalog().items));
    });
  });
}
