import 'dart:async';

/// Run by the generated tests around each scenario of this folder. The
/// login scenarios leave no timers behind, so there is nothing to clean.
abstract class Hooks {
  const Hooks._();

  static FutureOr<void> beforeEach(String title, [List<String>? tags]) {}

  static FutureOr<void> beforeAll() {}

  static FutureOr<void> afterEach(
    String title,
    bool success, [
    List<String>? tags,
  ]) {}

  static FutureOr<void> afterAll() {}
}
