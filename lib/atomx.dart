library atomx;

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

final _context = _Context();

class _Context {
  bool isTracking = false;
  final List<Set<Listenable>> _listOfListenable = [];

  void track() {
    isTracking = true;
    _listOfListenable.add({});
  }

  Set<Listenable> untrack() {
    isTracking = false;
    final listenables = _listOfListenable.last;
    _listOfListenable.removeLast();
    return listenables;
  }

  void reportRead(Listenable listenable) {
    if (!isTracking) return;
    _listOfListenable.last.add(listenable);
  }
}

class Atomx<T> extends ChangeNotifier {
  Atomx(T initialValue) : _value = initialValue;

  T _value;
  T get value {
    _context.reportRead(this);
    return _value;
  }

  void update(T? value) {
    if (value != null) {
      _value = value;
    }

    notifyListeners();
  }
}

class AtomxState<T, S> extends ChangeNotifier {
  AtomxState(T initialValue, S initialState)
      : _value = initialValue,
        _state = initialState;

  T _value;
  S _state;

  T get value {
    _context.reportRead(this);
    return _value;
  }

  S get state {
    _context.reportRead(this);
    return _state;
  }

  void update({T? value, S? state}) {
    if (value != null) {
      _value = value;
    }

    if (state != null) {
      _state = state;
    }

    notifyListeners();
  }
}

class AtomxBuilder extends StatefulWidget {
  const AtomxBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  State<AtomxBuilder> createState() => _AtomxBuilderState();
}

class _AtomxBuilderState extends State<AtomxBuilder> {
  Set<Listenable>? _trackedListenables;

  Widget _trackDependencies() {
    // Remove old listeners
    if (_trackedListenables != null) {
      for (final listenable in _trackedListenables!) {
        listenable.removeListener(_onDependencyChanged);
      }
    }

    // Track new dependencies
    _context.track();
    final result = widget.builder(context);
    _trackedListenables = _context.untrack();

    // Add new listeners
    for (final listenable in _trackedListenables!) {
      listenable.addListener(_onDependencyChanged);
    }
    return result;
  }

  void _onDependencyChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    if (_trackedListenables != null) {
      for (final listenable in _trackedListenables!) {
        listenable.removeListener(_onDependencyChanged);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _trackDependencies();
  }
}

class _ListenableObserver {
  _ListenableObserver({
    required this.onAccess,
    required this.onBuild,
  });

  final void Function(Listenable listenable) onAccess;
  final void Function() onBuild;
}

class _ListenableScope extends InheritedWidget {
  const _ListenableScope({
    required super.child,
    required this.observer,
  });

  final _ListenableObserver observer;

  static _ListenableObserver? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ListenableScope>()
        ?.observer;
  }

  @override
  bool updateShouldNotify(_ListenableScope oldWidget) => false;
}

extension AutoNotifierExtension on Listenable {
  T observe<T>(T Function() callback) {
    final context = Zone.current[#buildContext] as BuildContext?;
    if (context == null) return callback();

    final observer = _ListenableScope.of(context);
    if (observer == null) return callback();

    observer.onAccess(this);
    return callback();
  }
}

class AtomxList<T> extends ChangeNotifier implements List<T> {
  AtomxList(List<T> initialValue) : _value = List<T>.from(initialValue);

  final List<T> _value;

  // Return an unmodifiable view of the list
  List<T> get value {
    _context.reportRead(this);
    return List.unmodifiable(_value);
  }

  // List interface implementation
  @override
  T operator [](int index) {
    _context.reportRead(this);
    return _value[index];
  }

  @override
  void operator []=(int index, T value) {
    _value[index] = value;
    notifyListeners();
  }

  @override
  int get length {
    _context.reportRead(this);
    return _value.length;
  }

  @override
  set length(int newLength) {
    _value.length = newLength;
    notifyListeners();
  }

  @override
  bool get isEmpty {
    _context.reportRead(this);
    return _value.isEmpty;
  }

  @override
  bool get isNotEmpty {
    _context.reportRead(this);
    return _value.isNotEmpty;
  }

  @override
  T get first {
    _context.reportRead(this);
    return _value.first;
  }

  @override
  set first(T value) {
    _value.first = value;
    notifyListeners();
  }

  @override
  T get last {
    _context.reportRead(this);
    return _value.last;
  }

  @override
  set last(T value) {
    _value.last = value;
    notifyListeners();
  }

  @override
  Iterator<T> get iterator {
    _context.reportRead(this);
    return _value.iterator;
  }

  @override
  Iterable<T> get reversed {
    _context.reportRead(this);
    return _value.reversed;
  }

  @override
  void add(T value) {
    _value.add(value);
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _value.addAll(iterable);
    notifyListeners();
  }

  @override
  void clear() {
    _value.clear();
    notifyListeners();
  }

  @override
  void insert(int index, T element) {
    _value.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _value.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  bool remove(Object? value) {
    final result = _value.remove(value);
    if (result) {
      notifyListeners();
    }
    return result;
  }

  @override
  T removeAt(int index) {
    final result = _value.removeAt(index);
    notifyListeners();
    return result;
  }

  @override
  void removeWhere(bool Function(T element) test) {
    final lengthBefore = _value.length;
    _value.removeWhere(test);
    if (_value.length != lengthBefore) {
      notifyListeners();
    }
  }

  @override
  void retainWhere(bool Function(T element) test) {
    final lengthBefore = _value.length;
    _value.retainWhere(test);
    if (_value.length != lengthBefore) {
      notifyListeners();
    }
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    _value.sort(compare);
    notifyListeners();
  }

  @override
  void shuffle([Random? random]) {
    _value.shuffle(random);
    notifyListeners();
  }

  // Read operations that should track
  @override
  bool any(bool Function(T) test) {
    _context.reportRead(this);
    return _value.any(test);
  }

  @override
  bool every(bool Function(T) test) {
    _context.reportRead(this);
    return _value.every(test);
  }

  @override
  bool contains(Object? element) {
    _context.reportRead(this);
    return _value.contains(element);
  }

  @override
  T elementAt(int index) {
    _context.reportRead(this);
    return _value.elementAt(index);
  }

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T) f) {
    _context.reportRead(this);
    return _value.expand(f);
  }

  @override
  T firstWhere(bool Function(T) test, {T Function()? orElse}) {
    _context.reportRead(this);
    return _value.firstWhere(test, orElse: orElse);
  }

  @override
  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) {
    _context.reportRead(this);
    return _value.fold(initialValue, combine);
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    _context.reportRead(this);
    return _value.followedBy(other);
  }

  @override
  String join([String separator = ""]) {
    _context.reportRead(this);
    return _value.join(separator);
  }

  @override
  T lastWhere(bool Function(T) test, {T Function()? orElse}) {
    _context.reportRead(this);
    return _value.lastWhere(test, orElse: orElse);
  }

  @override
  Iterable<E> map<E>(E Function(T) f) {
    _context.reportRead(this);
    return _value.map(f);
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    _context.reportRead(this);
    return _value.reduce(combine);
  }

  @override
  T get single {
    _context.reportRead(this);
    return _value.single;
  }

  @override
  T singleWhere(bool Function(T) test, {T Function()? orElse}) {
    _context.reportRead(this);
    return _value.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<T> skip(int count) {
    _context.reportRead(this);
    return _value.skip(count);
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    _context.reportRead(this);
    return _value.skipWhile(test);
  }

  @override
  Iterable<T> take(int count) {
    _context.reportRead(this);
    return _value.take(count);
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    _context.reportRead(this);
    return _value.takeWhile(test);
  }

  @override
  List<T> toList({bool growable = true}) {
    _context.reportRead(this);
    return _value.toList(growable: growable);
  }

  @override
  Set<T> toSet() {
    _context.reportRead(this);
    return _value.toSet();
  }

  @override
  Iterable<T> where(bool Function(T) test) {
    _context.reportRead(this);
    return _value.where(test);
  }

  @override
  Iterable<E> whereType<E>() {
    _context.reportRead(this);
    return _value.whereType<E>();
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    _value.setAll(index, iterable);
    notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _value.setRange(start, end, iterable, skipCount);
    notifyListeners();
  }

  @override
  void removeRange(int start, int end) {
    _value.removeRange(start, end);
    notifyListeners();
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    _value.fillRange(start, end, fillValue);
    notifyListeners();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) {
    _value.replaceRange(start, end, replacements);
    notifyListeners();
  }

  @override
  Map<int, T> asMap() {
    _context.reportRead(this);
    return _value.asMap();
  }

  @override
  List<T> sublist(int start, [int? end]) {
    _context.reportRead(this);
    return _value.sublist(start, end);
  }

  @override
  Iterable<T> getRange(int start, int end) {
    _context.reportRead(this);
    return _value.getRange(start, end);
  }

  @override
  int indexOf(T element, [int start = 0]) {
    _context.reportRead(this);
    return _value.indexOf(element, start);
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    _context.reportRead(this);
    return _value.lastIndexOf(element, start);
  }

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    _context.reportRead(this);
    return _value.indexWhere(test, start);
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    _context.reportRead(this);
    return _value.lastIndexWhere(test, start);
  }

  @override
  T removeLast() {
    final result = _value.removeLast();
    notifyListeners();
    return result;
  }

  @override
  List<R> cast<R>() {
    _context.reportRead(this);
    return _value.cast<R>();
  }

  @override
  String toString() {
    _context.reportRead(this);
    return _value.toString();
  }

  @override
  void forEach(void Function(T) f) {
    _context.reportRead(this);
    _value.forEach(f);
  }

  @override
  List<T> operator +(List<T> other) {
    _context.reportRead(this);
    final newList = List<T>.from(_value)..addAll(other);
    return newList;
  }

  // Add batch update method for multiple operations
  void update(List<T> newValue) {
    _value.clear();
    _value.addAll(newValue);
    notifyListeners();
  }
}

class AtomxListState<T, S> extends AtomxList<T> {
  AtomxListState(super.initialValue, S initialState) : _state = initialState;

  S _state;
  S get state {
    _context.reportRead(this);
    return _state;
  }

  void updateState(S newState) {
    _state = newState;
    notifyListeners();
  }

  // Override update to allow state updates
  void updateAll({List<T>? value, S? state}) {
    if (value != null) {
      update(value);
    }

    if (state != null) {
      _state = state;
      notifyListeners();
    }
  }
}

class AtomxMap<K, V> extends ChangeNotifier implements Map<K, V> {
  AtomxMap(Map<K, V> initialValue) : _value = Map<K, V>.from(initialValue);

  final Map<K, V> _value;

  // Return an unmodifiable view of the map
  Map<K, V> get value {
    _context.reportRead(this);
    return Map.unmodifiable(_value);
  }

  @override
  V? operator [](Object? key) {
    _context.reportRead(this);
    return _value[key];
  }

  @override
  void operator []=(K key, V value) {
    _value[key] = value;
    notifyListeners();
  }

  @override
  void clear() {
    _value.clear();
    notifyListeners();
  }

  @override
  V? remove(Object? key) {
    final value = _value.remove(key);
    notifyListeners();
    return value;
  }

  @override
  void addAll(Map<K, V> other) {
    _value.addAll(other);
    notifyListeners();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    _value.addEntries(entries);
    notifyListeners();
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    final sizeBefore = _value.length;
    _value.removeWhere(test);
    if (_value.length != sizeBefore) {
      notifyListeners();
    }
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    final result = _value.update(key, update, ifAbsent: ifAbsent);
    notifyListeners();
    return result;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    _value.updateAll(update);
    notifyListeners();
  }

  @override
  void forEach(void Function(K key, V value) action) {
    _context.reportRead(this);
    _value.forEach(action);
  }

  // Read-only operations that need tracking
  @override
  bool containsKey(Object? key) {
    _context.reportRead(this);
    return _value.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    _context.reportRead(this);
    return _value.containsValue(value);
  }

  @override
  Iterable<MapEntry<K, V>> get entries {
    _context.reportRead(this);
    return _value.entries;
  }

  @override
  Map<K2, V2> cast<K2, V2>() {
    _context.reportRead(this);
    return _value.cast<K2, V2>();
  }

  @override
  bool get isEmpty {
    _context.reportRead(this);
    return _value.isEmpty;
  }

  @override
  bool get isNotEmpty {
    _context.reportRead(this);
    return _value.isNotEmpty;
  }

  @override
  Iterable<K> get keys {
    _context.reportRead(this);
    return _value.keys;
  }

  @override
  int get length {
    _context.reportRead(this);
    return _value.length;
  }

  @override
  Iterable<V> get values {
    _context.reportRead(this);
    return _value.values;
  }

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) {
    _context.reportRead(this);
    return _value.map(convert);
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    final sizeBefore = _value.length;
    final result = _value.putIfAbsent(key, ifAbsent);
    if (_value.length != sizeBefore) {
      notifyListeners();
    }
    return result;
  }

  @override
  String toString() {
    _context.reportRead(this);
    return _value.toString();
  }

  // Batch update method
  void updateMap(Map<K, V> newValue) {
    _value.clear();
    _value.addAll(newValue);
    notifyListeners();
  }
}

class AtomxMapState<K, V, S> extends AtomxMap<K, V> {
  AtomxMapState(super.initialValue, S initialState) : _state = initialState;

  S _state;
  S get state {
    _context.reportRead(this);
    return _state;
  }

  void updateState(S newState) {
    _state = newState;
    notifyListeners();
  }

  void updateMapAndState({Map<K, V>? value, S? state}) {
    if (value != null) {
      updateMap(value);
    }

    if (state != null) {
      _state = state;
      notifyListeners();
    }
  }
}
