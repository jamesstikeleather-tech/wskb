import '../models/maker.dart';
import 'maker_repository.dart';

class MemoryMakerRepository implements MakerRepository {
  final Map<String, Maker> _byKey = {}; // key = lowercased name

  String _slug(String s) {
    final cleaned = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return cleaned.isEmpty ? 'maker' : cleaned;
  }

  @override
  Future<String> ensureByName(String name) async {
    final key = name.trim().toLowerCase();
    if (key.isEmpty) {
      throw ArgumentError('Maker name is empty');
    }
    final found = _byKey[key];
    if (found != null) return found.id;

    final id = 'maker_${_slug(name)}';
    _byKey[key] = Maker(id: id, name: name);
    return id;
  }

  @override
  List<Maker> all() => _byKey.values.toList(growable: false);
}
