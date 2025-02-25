# Atomx

A state management library for Flutter that focuses on value-centric state management, built on top of Flutter's native `ValueNotifier`.

## Why Atomx?

- 🎯 **Value-Centric**: State belongs to values, not pages
- 🔄 **Reactive**: UI automatically updates when values or their states change
- 🎨 **Composable**: Combine multiple value states in a single builder
- 🎮 **Control**: Fine-grained control over what triggers updates
- 🪶 **Lightweight**: Built on Flutter's native `ValueNotifier`, no external dependencies
- 🔌 **Native**: Seamlessly integrates with Flutter's widget lifecycle

## Core Concept

Instead of managing state at the page/widget level, Atomx encourages you to:
1. Attach state directly to values
2. React to value state changes
3. Compose multiple value states in a single builder

```dart
// Define a value with its state
final counter = AtomxState<int, CounterState>(0, CounterState.initial);

// React to both value and state changes
AtomxBuilder(
  builder: (context) {
    return Text('Count: ${counter.value} (${counter.state})');
  },
);

// React to multiple values in a single builder
AtomxBuilder(
  builder: (context) {
    return Column(
      children: [
        Text('Count: ${counter.value}'),
        Text('Email: ${email.value}'),
        if (email.state == EmailState.loading)
          CircularProgressIndicator(),
      ],
    );
  },
);
```

## Quick Start

1. Create a value with state:
```dart
final counter = AtomxState<int, CounterState>(
  0,  // initial value
  CounterState.initial,  // initial state
);
```

2. Update value and/or state:
```dart
counter.update(
  value: counter.value + 1,  // update value
  state: CounterState.counting,  // update state
);

// Or update just the state
counter.update(state: CounterState.paused);
```

3. React to changes:
```dart
AtomxBuilder(
  builder: (context) {
    final value = counter.value;
    final state = counter.state;
    
    return switch (state) {
      CounterState.initial => Text('Ready: $value'),
      CounterState.counting => Text('Counting: $value'),
      CounterState.paused => Text('Paused at: $value'),
    };
  },
);
```

## Collections

Atomx also provides state-aware collections, all built on top of `ValueNotifier`:

```dart
// List with state
final todos = AtomxListState<Todo, LoadingState>(
  [],  // initial list
  LoadingState.initial,  // initial state
);

// Map with state
final users = AtomxMapState<String, User, LoadingState>(
  {},  // initial map
  LoadingState.initial,  // initial state
);
```

## Under the Hood

Atomx extends Flutter's `ValueNotifier` to provide state management capabilities:

```dart
// Basic value without state
final counter = Atomx<int>(0);  // Extends ValueNotifier<int>

// Value with state
final counter = AtomxState<int, CounterState>(0, CounterState.initial);  // Extends ValueNotifier

// Collections
final list = AtomxList<int>([1, 2, 3]);  // Extends ValueNotifier<List<int>>
final map = AtomxMap<String, int>({'a': 1});  // Extends ValueNotifier<Map<String, int>>
```

This means you get all the benefits of Flutter's native change notification system with the added power of state management.

See the example app for a complete implementation. 