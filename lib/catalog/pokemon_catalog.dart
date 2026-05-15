import 'package:genui_pokemon/catalog/items/pokemon_card.dart'
    as pokemon_card_item;
import 'package:genui_pokemon/catalog/items/pokemon_team.dart'
    as pokemon_team_item;

abstract final class PokemonCatalog {
  PokemonCatalog._();

  /// A catalog item representing a Pokémon card, which displays key information about a Pokémon in a visually appealing format.
  static final pokemonCard = pokemon_card_item.pokemonCard;

  /// A compact catalog item that renders a six-Pokémon team in a 2x3 grid.
  static final pokemonTeam = pokemon_team_item.pokemonTeam;
}
