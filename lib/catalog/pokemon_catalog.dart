import 'package:genui_pokemon/catalog/items/pokemon_card.dart' as pokemon_card_item;

abstract final class PokemonCatalog {
  PokemonCatalog._();

  /// A catalog item representing a Pokémon card, which displays key information about a Pokémon in a visually appealing format.
  static final pokemonCard = pokemon_card_item.pokemonCard;
}
