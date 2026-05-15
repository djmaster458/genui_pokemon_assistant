import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_pokemon/catalog/items/pokemon_card.dart';
import 'package:genui_pokemon/utils.dart';

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

  group('typeColor', () {
    test('fire is red', () => expect(typeColor('fire'), Colors.red));
    test('water is blue', () => expect(typeColor('water'), Colors.blue));
    test('grass is green', () => expect(typeColor('grass'), Colors.green));
    test(
      'electric is amber',
      () => expect(typeColor('electric'), Colors.amber),
    );
    test('psychic is pink', () => expect(typeColor('psychic'), Colors.pink));
    test('ice is lightBlue', () => expect(typeColor('ice'), Colors.lightBlue));
    test(
      'ghost is deepPurple',
      () => expect(typeColor('ghost'), Colors.deepPurple),
    );
    test(
      'unknown type returns grey',
      () => expect(typeColor('???'), Colors.grey),
    );

    test('is case-insensitive', () {
      expect(typeColor('FIRE'), typeColor('fire'));
      expect(typeColor('Water'), typeColor('water'));
    });
  });
}
