import 'package:atomx/atomx.dart';

enum CounterState { initial, counting, paused }

enum EmailState { initial, loading, loaded, error }

class CounterController {
  final counter = AtomxState<int, CounterState>(
    0,
    CounterState.initial,
  );

  final email = AtomxState<String, EmailState>(
    '',
    EmailState.initial,
  );

  void increment() {
    counter.update(
      value: counter.value + 1,
      state: CounterState.counting,
    );
  }

  void reset() {
    counter.update(
      value: 0,
      state: CounterState.initial,
    );
  }

  void pause() {
    counter.update(state: CounterState.paused);
  }
}
