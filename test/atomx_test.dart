import 'package:atomx/atomx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Atomx Tests', () {
    test('should create with initial value', () {
      final rx = Atomx(10);
      expect(rx.value, 10);
    });

    test('should update value and notify listeners', () {
      final rx = Atomx(10);
      var notified = false;
      rx.addListener(() => notified = true);

      rx.update(20);
      expect(rx.value, 20);
      expect(notified, true);
    });
  });

  group('AtomxState Tests', () {
    test('should create with initial value and state', () {
      final rx = AtomxState(10, 'initial');
      expect(rx.value, 10);
      expect(rx.state, 'initial');
    });

    test('should update value and state and notify listeners', () {
      final rx = AtomxState(10, 'initial');
      var notified = false;
      rx.addListener(() => notified = true);

      rx.update(value: 20, state: 'updated');
      expect(rx.value, 20);
      expect(rx.state, 'updated');
      expect(notified, true);
    });

    test('should update only value', () {
      final rx = AtomxState(10, 'initial');
      rx.update(value: 20);
      expect(rx.value, 20);
      expect(rx.state, 'initial');
    });

    test('should update only state', () {
      final rx = AtomxState(10, 'initial');
      rx.update(state: 'updated');
      expect(rx.value, 10);
      expect(rx.state, 'updated');
    });
  });

  group('AtomxList Tests', () {
    test('should create with initial values', () {
      final rx = AtomxList([1, 2, 3]);
      expect(rx.value, [1, 2, 3]);
      expect(rx.length, 3);
    });

    test('should add value and notify', () {
      final rx = AtomxList([1, 2]);
      var notified = false;
      rx.addListener(() => notified = true);

      rx.add(3);
      expect(rx.value, [1, 2, 3]);
      expect(notified, true);
    });

    test('should remove value and notify', () {
      final rx = AtomxList([1, 2, 3]);
      rx.remove(2);
      expect(rx.value, [1, 3]);
    });

    test('should update entire list', () {
      final rx = AtomxList([1, 2, 3]);
      rx.update([4, 5, 6]);
      expect(rx.value, [4, 5, 6]);
    });

    test('should support list operations', () {
      final rx = AtomxList([1, 2, 3]);

      rx.sort((a, b) => b.compareTo(a));
      expect(rx.value, [3, 2, 1]);

      rx.removeWhere((e) => e > 2);
      expect(rx.value, [2, 1]);

      rx.addAll([4, 5]);
      expect(rx.value, [2, 1, 4, 5]);
    });
  });

  group('AtomxListState Tests', () {
    test('should create with initial values and state', () {
      final rx = AtomxListState([1, 2, 3], 'initial');
      expect(rx.value, [1, 2, 3]);
      expect(rx.state, 'initial');
    });

    test('should update list and state', () {
      final rx = AtomxListState([1, 2], 'initial');
      rx.updateAll(value: [3, 4], state: 'updated');
      expect(rx.value, [3, 4]);
      expect(rx.state, 'updated');
    });

    test('should update only state', () {
      final rx = AtomxListState([1, 2], 'initial');
      rx.updateState('updated');
      expect(rx.value, [1, 2]);
      expect(rx.state, 'updated');
    });
  });

  group('AtomxMap Tests', () {
    test('should create with initial values', () {
      final rx = AtomxMap({'a': 1, 'b': 2});
      expect(rx.value, {'a': 1, 'b': 2});
      expect(rx.length, 2);
    });

    test('should update value and notify', () {
      final rx = AtomxMap({'a': 1});
      var notified = false;
      rx.addListener(() => notified = true);

      rx['b'] = 2;
      expect(rx.value, {'a': 1, 'b': 2});
      expect(notified, true);
    });

    test('should remove value and notify', () {
      final rx = AtomxMap({'a': 1, 'b': 2});
      rx.remove('a');
      expect(rx.value, {'b': 2});
    });

    test('should support map operations', () {
      final rx = AtomxMap({'a': 1, 'b': 2});

      rx.addAll({'c': 3, 'd': 4});
      expect(rx.value, {'a': 1, 'b': 2, 'c': 3, 'd': 4});

      rx.removeWhere((key, value) => value > 2);
      expect(rx.value, {'a': 1, 'b': 2});

      rx.updateAll((key, value) => value * 2);
      expect(rx.value, {'a': 2, 'b': 4});
    });
  });

  group('AtomxMapState Tests', () {
    test('should create with initial values and state', () {
      final rx = AtomxMapState({'a': 1}, 'initial');
      expect(rx.value, {'a': 1});
      expect(rx.state, 'initial');
    });

    test('should update map and state', () {
      final rx = AtomxMapState({'a': 1}, 'initial');
      rx.updateMapAndState(value: {'b': 2}, state: 'updated');
      expect(rx.value, {'b': 2});
      expect(rx.state, 'updated');
    });

    test('should update only state', () {
      final rx = AtomxMapState({'a': 1}, 'initial');
      rx.updateState('updated');
      expect(rx.value, {'a': 1});
      expect(rx.state, 'updated');
    });
  });

  group('AtomxBuilder Tests with Atomx', () {
    testWidgets('should rebuild when value changes', (tester) async {
      final counter = Atomx(0);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AtomxBuilder(
            builder: (context) {
              buildCount++;
              return Text('Count: ${counter.value}');
            },
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
      expect(buildCount, 1);

      counter.update(1);
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);
      expect(buildCount, 2);

      counter.update(1);
      await tester.pump();
      expect(buildCount, 3);
    });

    testWidgets('should rebuild only widgets that use the value',
        (tester) async {
      final counter1 = Atomx(0);
      final counter2 = Atomx(0);
      var builds1 = 0;
      var builds2 = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              AtomxBuilder(
                builder: (context) {
                  builds1++;
                  return Text('Counter1: ${counter1.value}');
                },
              ),
              AtomxBuilder(
                builder: (context) {
                  builds2++;
                  return Text('Counter2: ${counter2.value}');
                },
              ),
            ],
          ),
        ),
      );

      expect(builds1, 1);
      expect(builds2, 1);

      counter1.update(1);
      await tester.pump();
      expect(builds1, 2);
      expect(builds2, 1);
    });
  });

  group('AtomxBuilder Tests with AtomxState', () {
    testWidgets('should rebuild when value or state changes', (tester) async {
      final counter = AtomxState(0, 'idle');
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AtomxBuilder(
            builder: (context) {
              buildCount++;
              return Text('Count: ${counter.value}, State: ${counter.state}');
            },
          ),
        ),
      );

      expect(find.text('Count: 0, State: idle'), findsOneWidget);
      expect(buildCount, 1);

      counter.update(value: 1);
      await tester.pump();
      expect(find.text('Count: 1, State: idle'), findsOneWidget);
      expect(buildCount, 2);

      counter.update(state: 'loading');
      await tester.pump();
      expect(find.text('Count: 1, State: loading'), findsOneWidget);
      expect(buildCount, 3);

      counter.update(value: 2, state: 'done');
      await tester.pump();
      expect(find.text('Count: 2, State: done'), findsOneWidget);
      expect(buildCount, 4);
    });

    testWidgets('should rebuild only when accessed values change',
        (tester) async {
      final counter = AtomxState(0, 'idle');
      var valueBuilds = 0;
      var stateBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              AtomxBuilder(
                builder: (context) {
                  valueBuilds++;
                  return Text('Value: ${counter.value}');
                },
              ),
              AtomxBuilder(
                builder: (context) {
                  stateBuilds++;
                  return Text('State: ${counter.state}');
                },
              ),
            ],
          ),
        ),
      );

      expect(valueBuilds, 1);
      expect(stateBuilds, 1);

      counter.update(value: 1);
      await tester.pump();
      expect(valueBuilds, 2);
      expect(stateBuilds, 2);

      counter.update(state: 'loading');
      await tester.pump();
      expect(valueBuilds, 3);
      expect(stateBuilds, 3);
    });
  });

  group('AtomxBuilder Tests with AtomxList', () {
    testWidgets('should rebuild when list changes', (tester) async {
      final list = AtomxList(['A', 'B']);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AtomxBuilder(
            builder: (context) {
              buildCount++;
              return Column(
                children: list.map((e) => Text(e)).toList(),
              );
            },
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(buildCount, 1);

      list.add('C');
      await tester.pump();
      expect(find.text('C'), findsOneWidget);
      expect(buildCount, 2);

      list.removeAt(0);
      await tester.pump();
      expect(find.text('A'), findsNothing);
      expect(buildCount, 3);

      list.update(['X', 'Y']);
      await tester.pump();
      expect(find.text('B'), findsNothing);
      expect(find.text('C'), findsNothing);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
      expect(buildCount, 4);
    });

    testWidgets('should rebuild when accessing different list properties',
        (tester) async {
      final list = AtomxList(['A', 'B']);
      var lengthBuilds = 0;
      var contentBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              AtomxBuilder(
                builder: (context) {
                  lengthBuilds++;
                  return Text('Length: ${list.length}');
                },
              ),
              AtomxBuilder(
                builder: (context) {
                  contentBuilds++;
                  return Column(
                    children: list.map((e) => Text(e)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      );

      expect(lengthBuilds, 1);
      expect(contentBuilds, 1);

      list[0] = 'X';
      await tester.pump();
      expect(lengthBuilds, 2);
      expect(contentBuilds, 2);

      list.add('C');
      await tester.pump();
      expect(lengthBuilds, 3);
      expect(contentBuilds, 3);
    });
  });

  group('AtomxBuilder Tests with AtomxListState', () {
    testWidgets('should rebuild when list or state changes', (tester) async {
      final list = AtomxListState(['A', 'B'], 'idle');
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AtomxBuilder(
            builder: (context) {
              buildCount++;
              return Column(
                children: [
                  Text('State: ${list.state}'),
                  ...list.map((e) => Text(e)),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('State: idle'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(buildCount, 1);

      list.updateState('loading');
      await tester.pump();
      expect(find.text('State: loading'), findsOneWidget);
      expect(buildCount, 2);

      list.add('C');
      await tester.pump();
      expect(find.text('C'), findsOneWidget);
      expect(buildCount, 3);

      list.updateAll(value: ['X'], state: 'done');
      await tester.pump();
      expect(find.text('State: done'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsNothing);
      expect(find.text('C'), findsNothing);
      expect(buildCount, 4);
    });
  });

  group('AtomxBuilder Tests with AtomxMap', () {
    testWidgets('should rebuild when map changes', (tester) async {
      final map = AtomxMap({'a': 1, 'b': 2});
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AtomxBuilder(
            builder: (context) {
              buildCount++;
              return Column(
                children: map.entries
                    .map((e) => Text('${e.key}: ${e.value}'))
                    .toList(),
              );
            },
          ),
        ),
      );

      expect(find.text('a: 1'), findsOneWidget);
      expect(find.text('b: 2'), findsOneWidget);
      expect(buildCount, 1);

      map['c'] = 3;
      await tester.pump();
      expect(find.text('c: 3'), findsOneWidget);
      expect(buildCount, 2);

      map.remove('a');
      await tester.pump();
      expect(find.text('a: 1'), findsNothing);
      expect(buildCount, 3);

      map.updateMap({'x': 10, 'y': 20});
      await tester.pump();
      expect(find.text('x: 10'), findsOneWidget);
      expect(find.text('y: 20'), findsOneWidget);
      expect(find.text('b: 2'), findsNothing);
      expect(find.text('c: 3'), findsNothing);
      expect(buildCount, 4);
    });

    testWidgets('should rebuild when accessing different map properties',
        (tester) async {
      final map = AtomxMap({'a': 1, 'b': 2});
      var keysBuilds = 0;
      var valuesBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              AtomxBuilder(
                builder: (context) {
                  keysBuilds++;
                  return Text('Keys: ${map.keys.join(", ")}');
                },
              ),
              AtomxBuilder(
                builder: (context) {
                  valuesBuilds++;
                  return Text('Values: ${map.values.join(", ")}');
                },
              ),
            ],
          ),
        ),
      );

      expect(keysBuilds, 1);
      expect(valuesBuilds, 1);

      map['a'] = 10;
      await tester.pump();
      expect(keysBuilds, 2);
      expect(valuesBuilds, 2);

      map['c'] = 3;
      await tester.pump();
      expect(keysBuilds, 3);
      expect(valuesBuilds, 3);
    });
  });

  group('AtomxBuilder Tests with AtomxMapState', () {
    testWidgets('should rebuild when map or state changes', (tester) async {
      final map = AtomxMapState({'a': 1, 'b': 2}, 'idle');
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AtomxBuilder(
            builder: (context) {
              buildCount++;
              return Column(
                children: [
                  Text('State: ${map.state}'),
                  ...map.entries.map((e) => Text('${e.key}: ${e.value}')),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('State: idle'), findsOneWidget);
      expect(find.text('a: 1'), findsOneWidget);
      expect(find.text('b: 2'), findsOneWidget);
      expect(buildCount, 1);

      map.updateState('loading');
      await tester.pump();
      expect(find.text('State: loading'), findsOneWidget);
      expect(buildCount, 2);

      map['c'] = 3;
      await tester.pump();
      expect(find.text('c: 3'), findsOneWidget);
      expect(buildCount, 3);

      map.updateMapAndState(value: {'x': 10}, state: 'done');
      await tester.pump();
      expect(find.text('State: done'), findsOneWidget);
      expect(find.text('x: 10'), findsOneWidget);
      expect(find.text('a: 1'), findsNothing);
      expect(find.text('b: 2'), findsNothing);
      expect(find.text('c: 3'), findsNothing);
      expect(buildCount, 4);
    });
  });
}
