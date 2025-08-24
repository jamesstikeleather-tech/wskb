// lib/features/memos/data/memory_personal_memo_repository.dart
import 'dart:async';
import '../models/personal_memo_entry.dart';
import '../../memos/models/catalog_update_request.dart' show CurEntityType;
import 'personal_memo_repository.dart';

class MemoryPersonalMemoRepository implements PersonalMemoRepository {
  final _controller = StreamController<List<PersonalMemoEntry>>.broadcast();
  final List<PersonalMemoEntry> _items = [];

  void _emit(String ownerUserId) {
    final view = _items.where((m) => m.ownerUserId == ownerUserId).toList(growable: false);
    _controller.add(view);
  }

  @override
  Stream<List<PersonalMemoEntry>> watchAll({required String ownerUserId}) {
    // Immediately emit current snapshot for convenience.
    Future.microtask(() => _emit(ownerUserId));
    return _controller.stream;
  }

  @override
  Future<void> add(PersonalMemoEntry memo) async {
    _items.removeWhere((m) => m.id == memo.id && m.ownerUserId == memo.ownerUserId);
    _items.add(memo);
    _emit(memo.ownerUserId);
  }

  @override
  Future<void> update(PersonalMemoEntry memo) => add(memo);

  @override
  Future<void> remove(String id, {required String ownerUserId}) async {
    _items.removeWhere((m) => m.id == id && m.ownerUserId == ownerUserId);
    _emit(ownerUserId);
  }

  @override
  Future<void> linkToCanonical({
    required String id,
    required String ownerUserId,
    required String canonicalEntityId,
  }) async {
    final idx = _items.indexWhere((m) => m.id == id && m.ownerUserId == ownerUserId);
    if (idx != -1) {
      final now = DateTime.now();
      _items[idx] = _items[idx].copyWith(
        canonicalEntityId: canonicalEntityId,
        status: PersonalMemoStatus.linked,
        updatedAt: now,
      );
      _emit(ownerUserId);
    }
  }

  @override
  Future<PersonalMemoEntry?> findActiveByName({
    required String ownerUserId,
    required CurEntityType entityType,
    required String name,
  }) async {
    try {
      return _items.firstWhere((m) =>
          m.ownerUserId == ownerUserId &&
          m.entityType == entityType &&
          m.name.toLowerCase().trim() == name.toLowerCase().trim() &&
          m.status == PersonalMemoStatus.active);
    } catch (_) {
      return null;
    }
  }
}
