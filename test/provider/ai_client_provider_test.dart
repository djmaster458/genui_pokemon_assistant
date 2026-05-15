import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui_pokemon/provider/ai_client_provider.dart';

void main() {
  group('Ai Client Provider', () {
    test('throws by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(() => container.read(aiClientProvider), throwsException);
    });
  });
}
