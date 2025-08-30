import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/personal_process.dart';

class PersonalProcessRepo {
  final _uuid = const Uuid();
  final _items = <String, PersonalProcess>{};
  final _controller = StreamController<List<PersonalProcess>>.broadcast();

  Stream<List<PersonalProcess>> watchAll() => _controller.stream;

  List<PersonalProcess> getAll() =>
      _items.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  PersonalProcess? getById(String id) => _items[id];

  void _emit() => _controller.add(getAll());

  PersonalProcess upsert(PersonalProcess p0) {
    // normalize tags/useCases
    final normTags = (p0.tags).map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
    final normUses = (p0.useCases).map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
    final p1 = p0.copyWith(tags: normTags, useCases: normUses);

    final id = p1.id.isEmpty ? _uuid.v4() : p1.id;
    final withId = p1.copyWith(id: id);
    _items[id] = withId;
    _emit();
    return withId;
  }

  void delete(String id) {
    _items.remove(id);
    _emit();
  }

  void seed(Iterable<PersonalProcess> sample) {
    for (final p in sample) {
      final id = p.id.isEmpty ? _uuid.v4() : p.id;
      _items[id] = p.copyWith(id: id);
    }
    _emit();
  }

  void dispose() => _controller.close();
}
