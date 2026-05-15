# Making code changes

When making code changes, please follow these guidelines:
- Add new tests for any new functionality you add, and ensure all existing tests pass.
- If you are fixing a bug, add a test that reproduces the bug before fixing it, and then ensure that the test passes after your fix.
- If you are refactoring code, ensure that you do not change the external behavior of the code, and that all existing tests continue to pass.
  - If tests need modification due to the refactor, please ensure that the modifications are minimal and do not change the intent of the tests and their coverage.
- New catalog items should have example data and support widget previews for testing purposes.
- Run `flutter format .` to ensure that your code is properly formatted according to the Dart style guide.
- Run `flutter analyze` to check for any static analysis issues in your code.

# Code style
- Follow the existing code style and conventions used in the project.
- For Dart code, follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.
- For Flutter code, follow the [Flutter style guide](https://flutter.dev/docs/development/tools/formatting#style-guide).