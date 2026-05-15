import 'package:flutter_test/flutter_test.dart';
import 'package:genui_pokemon/catalog/items/pokemon_card.dart';

void main() {
  group('pokemonCard CatalogItem', () {
    test('has the correct name', () {
      expect(pokemonCard.name, 'PokemonCard');
    });

    test('schema has all required fields', () {
      final required = pokemonCard.dataSchema.required ?? [];
      for (final field in [
        'name',
        'number',
        'type1',
        'imageUrl',
        'description',
        'hp',
        'attack',
        'defense',
        'speed',
      ]) {
        expect(required, contains(field), reason: '$field must be required');
      }
    });

    test('schema declares type2 as optional', () {
      final required = pokemonCard.dataSchema.required ?? [];
      expect(required, isNot(contains('type2')));

      final props = pokemonCard.dataSchema.properties;
      expect(props, isNotNull);
      expect(props!.containsKey('type2'), isTrue);
    });
  });
}
