import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../models/personal_process.dart';

class PersonalProcessRepository {
  final _uuid = const Uuid();
  final _items = <String, PersonalProcess>{};
  final _controller = StreamController<List<PersonalProcess>>.broadcast();

  Stream<List<PersonalProcess>> watchAll() async* {
  // Always give subscribers the current snapshot first
  yield getAll();
  // Then stream future changes
  yield* _controller.stream;
  }

  List<PersonalProcess> getAll() =>
      _items.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  PersonalProcess? getById(String id) => _items[id];

  void _emit() => _controller.add(getAll());

  PersonalProcess upsert(PersonalProcess p) {
    final id = p.id.isEmpty ? _uuid.v4() : p.id;
    final withId = p.copyWith(id: id);
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

  /// Drop-in sample so you can see the screens working immediately.
  void seedSample() {
    seed([
      PersonalProcess(
        id: '',
        schemaVersion: 1,
        ownerUserId: 'local-demo',
        name: 'Weekday Quick',
        description: '3-pass fast routine',
        isFavorite: true,
        passPlan: const [
          PassPlan(order: 1, direction: PassDirection.WTG),
          PassPlan(order: 2, direction: PassDirection.XTG),
          PassPlan(order: 3, direction: PassDirection.ATG),
        ],
      ),
    ]);
  }

  void dispose() => _controller.close();
}
