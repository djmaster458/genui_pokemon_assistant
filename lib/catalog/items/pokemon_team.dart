import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_pokemon/utils.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final _pokemonTeamMemberSchema = S.object(
  properties: {
    'name': S.string(description: 'Pokémon name, e.g. Charizard'),
    'type1': S.string(description: 'Primary type, e.g. fire'),
    'type2': S.string(description: 'Secondary type if any, e.g. flying'),
    'imageUrl': S.string(description: 'URL to the Pokémon sprite image'),
  },
  required: ['name', 'type1', 'imageUrl'],
);

final _pokemonTeamSchema = S.object(
  properties: {
    'pokemon1': _pokemonTeamMemberSchema,
    'pokemon2': _pokemonTeamMemberSchema,
    'pokemon3': _pokemonTeamMemberSchema,
    'pokemon4': _pokemonTeamMemberSchema,
    'pokemon5': _pokemonTeamMemberSchema,
    'pokemon6': _pokemonTeamMemberSchema,
  },
  required: [
    'pokemon1',
    'pokemon2',
    'pokemon3',
    'pokemon4',
    'pokemon5',
    'pokemon6',
  ],
);

extension type _PokemonTeamMemberData.fromMap(JsonMap _json) {
  factory _PokemonTeamMemberData({
    required String name,
    required String type1,
    String? type2,
    required String imageUrl,
  }) => _PokemonTeamMemberData.fromMap({
    'name': name,
    'type1': type1,
    'type2': type2,
    'imageUrl': imageUrl,
  });

  String get name => _json['name'] as String;
  String get type1 => _json['type1'] as String;
  String? get type2 => _json['type2'] as String?;
  String get imageUrl => _json['imageUrl'] as String;
}

extension type _PokemonTeamData.fromMap(JsonMap _json) {
  factory _PokemonTeamData({
    required _PokemonTeamMemberData pokemon1,
    required _PokemonTeamMemberData pokemon2,
    required _PokemonTeamMemberData pokemon3,
    required _PokemonTeamMemberData pokemon4,
    required _PokemonTeamMemberData pokemon5,
    required _PokemonTeamMemberData pokemon6,
  }) => _PokemonTeamData.fromMap({
    'pokemon1': pokemon1,
    'pokemon2': pokemon2,
    'pokemon3': pokemon3,
    'pokemon4': pokemon4,
    'pokemon5': pokemon5,
    'pokemon6': pokemon6,
  });

  _PokemonTeamMemberData get pokemon1 =>
      _PokemonTeamMemberData.fromMap(_json['pokemon1'] as JsonMap);
  _PokemonTeamMemberData get pokemon2 =>
      _PokemonTeamMemberData.fromMap(_json['pokemon2'] as JsonMap);
  _PokemonTeamMemberData get pokemon3 =>
      _PokemonTeamMemberData.fromMap(_json['pokemon3'] as JsonMap);
  _PokemonTeamMemberData get pokemon4 =>
      _PokemonTeamMemberData.fromMap(_json['pokemon4'] as JsonMap);
  _PokemonTeamMemberData get pokemon5 =>
      _PokemonTeamMemberData.fromMap(_json['pokemon5'] as JsonMap);
  _PokemonTeamMemberData get pokemon6 =>
      _PokemonTeamMemberData.fromMap(_json['pokemon6'] as JsonMap);
}

/// A compact GenUI catalog item that renders a six-Pokémon team in a fixed 2x3 grid.
final CatalogItem pokemonTeam = CatalogItem(
  name: 'PokemonTeam',
  dataSchema: _pokemonTeamSchema,
  widgetBuilder: (context) {
    final data = context.data as JsonMap;
    final teamData = _PokemonTeamData.fromMap(data);
    return _PokemonTeamWidget(
      teamData: teamData,
      dataContext: context.dataContext,
    );
  },
);

class _PokemonTeamWidget extends StatelessWidget {
  const _PokemonTeamWidget({required this.teamData, required this.dataContext});

  final _PokemonTeamData teamData;
  final DataContext dataContext;

  @override
  Widget build(BuildContext context) {
    final pokemon = [
      teamData.pokemon1,
      teamData.pokemon2,
      teamData.pokemon3,
      teamData.pokemon4,
      teamData.pokemon5,
      teamData.pokemon6,
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 320, height: 232),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (var rowIndex = 0; rowIndex < 3; rowIndex++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: rowIndex == 2 ? 0 : 4),
                      child: Row(
                        children: [
                          for (
                            var columnIndex = 0;
                            columnIndex < 2;
                            columnIndex++
                          )
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: columnIndex == 1 ? 0 : 4,
                                ),
                                child: _PokemonTeamTile(
                                  dataContext: dataContext,
                                  pokemon: pokemon[rowIndex * 2 + columnIndex],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PokemonTeamTile extends StatelessWidget {
  const _PokemonTeamTile({required this.dataContext, required this.pokemon});

  final DataContext dataContext;
  final _PokemonTeamMemberData pokemon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BoundString(
      dataContext: dataContext,
      value: pokemon.type1,
      builder: (ctx, type1) {
        final backgroundColor = typeColor(type1 ?? '').withValues(alpha: 0.14);
        final borderColor = typeColor(type1 ?? '').withValues(alpha: 0.35);

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BoundString(
                dataContext: dataContext,
                value: pokemon.name,
                builder: (ctx, name) => Text(
                  name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: BoundString(
                  dataContext: dataContext,
                  value: pokemon.imageUrl,
                  builder: (ctx, url) => url != null && url.isNotEmpty
                      ? Image.network(
                          url,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, error, stack) => const SizedBox(),
                          filterQuality: FilterQuality.low,
                        )
                      : const SizedBox(),
                ),
              ),
              const SizedBox(height: 1),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 2,
                runSpacing: 2,
                children: [
                  BoundString(
                    dataContext: dataContext,
                    value: pokemon.type1,
                    builder: (ctx, type) => type != null && type.isNotEmpty
                        ? _TypeBadge(type)
                        : const SizedBox.shrink(),
                  ),
                  if (pokemon.type2 != null)
                    BoundString(
                      dataContext: dataContext,
                      value: pokemon.type2,
                      builder: (ctx, type) => type != null && type.isNotEmpty
                          ? _TypeBadge(type)
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge(this.type);

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: typeColor(type),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
