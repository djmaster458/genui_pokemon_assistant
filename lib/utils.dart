import 'package:flutter/material.dart';

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
