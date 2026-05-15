import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_pokemon/utils.dart';

void main() {
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
