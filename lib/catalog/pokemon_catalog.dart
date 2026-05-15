import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Maps a Pokémon type name to its representative Material color.
Color typeColor(String type) => switch (type.toLowerCase()) {
  'fire' => Colors.red,
  'water' => Colors.blue,
  'grass' => Colors.green,
  'electric' => Colors.amber,
  'psychic' => Colors.pink,
  'ice' => Colors.lightBlue,
  'dragon' => Colors.indigo,
  'dark' => Colors.brown,
  'fairy' => Colors.pinkAccent,
  'normal' => Colors.grey,
  'fighting' => Colors.deepOrange,
  'flying' => Colors.lightBlue,
  'poison' => Colors.purple,
  'ground' => Colors.brown.shade300,
  'rock' => Colors.grey.shade600,
  'bug' => Colors.lightGreen,
  'ghost' => Colors.deepPurple,
  'steel' => Colors.blueGrey,
  _ => Colors.grey,
};

final _pokemonCardSchema = S.object(
  properties: {
    'name': S.string(description: 'Pokémon name, e.g. Charizard'),
    'number': S.integer(description: 'Pokédex number, e.g. 6'),
    'type1': S.string(description: 'Primary type, e.g. fire'),
    'type2': S.string(description: 'Secondary type if any, e.g. flying'),
    'imageUrl': S.string(description: 'URL to the Pokémon sprite image'),
    'description': S.string(description: 'Short Pokédex-style description'),
    'hp': S.integer(description: 'HP base stat'),
    'attack': S.integer(description: 'Attack base stat'),
    'defense': S.integer(description: 'Defense base stat'),
    'speed': S.integer(description: 'Speed base stat'),
  },
  required: [
    'name',
    'number',
    'type1',
    'imageUrl',
    'description',
    'hp',
    'attack',
    'defense',
    'speed',
  ],
);

/// A GenUI catalog item that renders a styled Pokémon card.
///
/// Uses [BoundString] and [BoundNumber] to reactively display values that the
/// AI streams in — each field is resolved through the [DataContext] so literal
/// values and data-model paths are both handled transparently.
final CatalogItem pokemonCard = CatalogItem(
  name: 'PokemonCard',
  dataSchema: _pokemonCardSchema,
  widgetBuilder: (context) {
    final data = context.data as Map<String, Object?>;
    return _PokemonCardWidget(
      name: data['name'],
      number: data['number'],
      type1: data['type1'],
      type2: data['type2'],
      imageUrl: data['imageUrl'],
      description: data['description'],
      hp: data['hp'],
      attack: data['attack'],
      defense: data['defense'],
      speed: data['speed'],
      dataContext: context.dataContext,
    );
  },
);

class _PokemonCardWidget extends StatelessWidget {
  const _PokemonCardWidget({
    required this.name,
    required this.number,
    required this.type1,
    this.type2,
    required this.imageUrl,
    required this.description,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.dataContext,
  });

  final Object? name;
  final Object? number;
  final Object? type1;
  final Object? type2;
  final Object? imageUrl;
  final Object? description;
  final Object? hp;
  final Object? attack;
  final Object? defense;
  final Object? speed;
  final DataContext dataContext;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Coloured header banner derived from the primary type.
          BoundString(
            dataContext: dataContext,
            value: type1,
            builder: (ctx, t1) => Container(
              color: typeColor(t1 ?? '').withValues(alpha: 0.85),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  BoundString(
                    dataContext: dataContext,
                    value: name,
                    builder: (ctx, n) => Text(
                      n ?? '',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  BoundNumber(
                    dataContext: dataContext,
                    value: number,
                    builder: (ctx, n) => Text(
                      '#${(n?.toInt() ?? 0).toString().padLeft(3, '0')}',
                      style: Theme.of(
                        ctx,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sprite image.
          BoundString(
            dataContext: dataContext,
            value: imageUrl,
            builder: (ctx, url) => Center(
              child: url != null && url.isNotEmpty
                  ? Image.network(
                      url,
                      height: 96,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, error, stack) =>
                          const SizedBox(height: 96),
                    )
                  : const SizedBox(height: 96),
            ),
          ),
          // Type badges.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                BoundString(
                  dataContext: dataContext,
                  value: type1,
                  builder: (ctx, t) =>
                      t != null ? _TypeBadge(t) : const SizedBox.shrink(),
                ),
                const SizedBox(width: 6),
                if (type2 != null)
                  BoundString(
                    dataContext: dataContext,
                    value: type2,
                    builder: (ctx, t) => t != null && t.isNotEmpty
                        ? _TypeBadge(t)
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
          // Pokédex description.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: BoundString(
              dataContext: dataContext,
              value: description,
              builder: (ctx, desc) =>
                  Text(desc ?? '', style: Theme.of(ctx).textTheme.bodySmall),
            ),
          ),
          // Base stats.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                _BoundStatBar(
                  dataContext: dataContext,
                  label: 'HP',
                  value: hp,
                  color: Colors.green,
                ),
                _BoundStatBar(
                  dataContext: dataContext,
                  label: 'ATK',
                  value: attack,
                  color: Colors.orange,
                ),
                _BoundStatBar(
                  dataContext: dataContext,
                  label: 'DEF',
                  value: defense,
                  color: Colors.blue,
                ),
                _BoundStatBar(
                  dataContext: dataContext,
                  label: 'SPD',
                  value: speed,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge(this.type);
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: typeColor(type),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _BoundStatBar extends StatelessWidget {
  const _BoundStatBar({
    required this.dataContext,
    required this.label,
    required this.value,
    required this.color,
  });

  final DataContext dataContext;
  final String label;
  final Object? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BoundNumber(
      dataContext: dataContext,
      value: value,
      builder: (ctx, n) {
        final v = n?.toInt() ?? 0;
        final fraction = (v / 255).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  label,
                  style: Theme.of(
                    ctx,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 28,
                child: Text('$v', style: Theme.of(ctx).textTheme.bodySmall),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.2),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
