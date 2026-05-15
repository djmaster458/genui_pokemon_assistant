import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/catalog/items/pokemon_team.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

Map<String, Object?> _teamData() => {
  'pokemon1': {
    'name': 'Pikachu',
    'type1': 'electric',
    'type2': null,
    'imageUrl': 'https://example.com/pikachu.png',
  },
  'pokemon2': {
    'name': 'Charizard',
    'type1': 'fire',
    'type2': 'flying',
    'imageUrl': 'https://example.com/charizard.png',
  },
  'pokemon3': {
    'name': 'Blastoise',
    'type1': 'water',
    'type2': null,
    'imageUrl': 'https://example.com/blastoise.png',
  },
  'pokemon4': {
    'name': 'Venusaur',
    'type1': 'grass',
    'type2': 'poison',
    'imageUrl': 'https://example.com/venusaur.png',
  },
  'pokemon5': {
    'name': 'Gengar',
    'type1': 'ghost',
    'type2': 'poison',
    'imageUrl': 'https://example.com/gengar.png',
  },
  'pokemon6': {
    'name': 'Dragonite',
    'type1': 'dragon',
    'type2': 'flying',
    'imageUrl': 'https://example.com/dragonite.png',
  },
};

CatalogItemContext _buildItemContext(BuildContext buildContext) {
  return CatalogItemContext(
    data: _teamData(),
    id: 'root',
    type: pokemonTeam.name,
    buildChild: (_, [_]) => const SizedBox.shrink(),
    dispatchEvent: (_) {},
    buildContext: buildContext,
    dataContext: DataContext(InMemoryDataModel(), DataPath.root),
    getComponent: (_) => null,
    getCatalogItem: (_) => null,
    surfaceId: 'test-surface',
    reportError: (_, _) {},
  );
}

void main() {
  group('pokemonTeam CatalogItem', () {
    test('has the correct name', () {
      expect(pokemonTeam.name, 'PokemonTeam');
    });

    test('schema requires six pokemon entries', () {
      final required = pokemonTeam.dataSchema.required ?? const [];

      for (final field in [
        'component',
        'pokemon1',
        'pokemon2',
        'pokemon3',
        'pokemon4',
        'pokemon5',
        'pokemon6',
      ]) {
        expect(required, contains(field), reason: '$field must be required');
      }

      final properties = pokemonTeam.dataSchema.properties;
      expect(properties, isNotNull);

      for (final field in [
        'pokemon1',
        'pokemon2',
        'pokemon3',
        'pokemon4',
        'pokemon5',
        'pokemon6',
      ]) {
        final memberSchema = properties![field];
        expect(memberSchema, isA<ObjectSchema>());

        final memberRequired = (memberSchema as ObjectSchema).required ?? [];
        expect(memberRequired, containsAll(['name', 'type1', 'imageUrl']));
        expect(memberRequired, isNot(contains('type2')));
      }
    });

    testWidgets('builds a compact 2x3 layout with six tiles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (buildContext) {
              return pokemonTeam.widgetBuilder(_buildItemContext(buildContext));
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(Row), findsNWidgets(3));
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(6));
      expect(tester.getSize(find.byType(Card)), const Size(320, 232));

      for (final name in [
        'Pikachu',
        'Charizard',
        'Blastoise',
        'Venusaur',
        'Gengar',
        'Dragonite',
      ]) {
        expect(find.text(name), findsOneWidget);
      }

      for (final type in [
        'ELECTRIC',
        'FIRE',
        'WATER',
        'GRASS',
        'GHOST',
        'DRAGON',
      ]) {
        expect(find.text(type), findsWidgets);
      }
    });
  });
}
