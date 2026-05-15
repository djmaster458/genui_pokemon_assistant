# Gen UI Pokemon Assistant

Build a team of Pokemon using Flutter GenUI and Gemini.
Actively working to add richer Catalog Items such as condensed teams, move info, and trainer personality tuners to allow you to build the ultimate pokemon team.

## Getting Started

### Get an API key

Obtain a Google Cloud API key with access
to the Generative Language API from the
[Google AI Studio](https://aistudio.google.com/app/apikey).

## Set up the API key

* Option 1: Using the VS Code based IDE UI

1. Open the example in the IDE.
2. Pass the API key as a Dart define when running the app:

   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
   ```