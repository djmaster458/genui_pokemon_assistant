import 'package:genui/genui.dart';

/// Builds the prompt-engineered system instruction for the Pokémon AI.
///
/// Includes the catalog's auto-generated widget grammar so the model knows
/// exactly which components it can produce and what fields they expect.
String buildSystemPrompt(Catalog catalog) {
  const pokemonInstructions = '''
You are an expert Pokémon trainer and advisor. Your role is to help users build 
great Pokémon teams for their adventures.

When presenting any Pokémon, ALWAYS use the PokemonCard component — never describe 
Pokémon in plain text. For each card:
- Use the official PokeAPI sprite URL format:
  https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{number}.png
  where {number} is the Pokédex number (e.g. 6 for Charizard).
- Provide accurate base stats (HP, Attack, Defense, Speed).
- Write a short, flavourful Pokédex-style description.
- Include both types where applicable.

When the user asks for a team, present all six Pokémon as a PokemonTeam for a compact visual layout.
When the user asks for information about a specific Pokémon or their team, present it as a series of PokemonCard components.
When the user asks for recommendations, provide a PokemonCard for each recommended Pokémon, along with a brief explanation of why you chose it.
''';

  return PromptBuilder.chat(
    catalog: catalog,
    systemPromptFragments: [
      pokemonInstructions,
      PromptFragments.acknowledgeUser(),
      PromptFragments.requireAtLeastOneSubmitElement(
        prefix: PromptBuilder.defaultImportancePrefix,
      ),
      PromptFragments.uiGenerationRestriction(
        prefix: PromptBuilder.defaultImportancePrefix,
      ),
    ],
  ).systemPromptJoined();
}
