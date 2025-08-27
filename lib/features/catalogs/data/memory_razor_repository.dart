import 'dart:async';
import '../models/razor.dart';
import 'razor_repository.dart';

class MemoryRazorRepository implements RazorRepository {
  // Singleton: every 'new MemoryRazorRepository()' returns this same instance.
  static final MemoryRazorRepository _instance = MemoryRazorRepository._();
  factory MemoryRazorRepository() => _instance;
  MemoryRazorRepository._()
 {
   _emit(); // emit current state to any new subscribers
  }

  final List<Razor> _items = [];
  final _ctrl = StreamController<List<Razor>>.broadcast();

  void _emit() => _ctrl.add(List.unmodifiable(_items));

  @override
  Future<void> add(Razor r) async {
    final i = _items.indexWhere((e) => e.id == r.id);
    if (i >= 0) {
      _items[i] = r;
    } else {
      _items.add(r);
    }
    _emit();
  }

  @override
  Future<void> update(Razor r) async {
    final i = _items.indexWhere((e) => e.id == r.id);
    if (i >= 0) {
      _items[i] = r;
    } else {
      _items.add(r);
    }
    _emit();
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    _emit();
  }

  @override
Stream<List<Razor>> watchAll({RazorType? typeFilter}) async* {
  // 1) yield current snapshot immediately
  final first = typeFilter == null
      ? List<Razor>.from(_items)
      : _items.where((r) => r.razorType == typeFilter).toList();
  yield List.unmodifiable(first);

  // 2) then yield updates
  yield* _ctrl.stream.map((list) {
    if (typeFilter == null) return list;
    return list.where((r) => r.razorType == typeFilter).toList(growable: false);
  });
}

@override
Stream<Razor?> watchOne(String id) async* {
  // 1) yield current item immediately (or null)
  Razor? current;
  for (final r in _items) {
    if (r.id == id) {
      current = r;
      break;
    }
  }
  yield current;

  // 2) then yield updates
  yield* _ctrl.stream.map((list) {
    for (final r in list) {
      if (r.id == id) return r;
    }
    return null;
  });
}


  // Optional helpers for testing
  void clear() {
    _items.clear();
    _emit();
  }

  List<Razor> snapshot() => List.unmodifiable(_items);
}
