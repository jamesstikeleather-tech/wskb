// lib/features/memos/data/personal_memo_repository.dart
import 'dart:async';
import '../models/personal_memo_entry.dart';
import '../../memos/models/catalog_update_request.dart' show CurEntityType;

abstract class PersonalMemoRepository {
  /// Stream the current user's memos (scoped by ownerUserId).
  Stream<List<PersonalMemoEntry>> watchAll({required String ownerUserId});

  Future<void> add(PersonalMemoEntry memo);
  Future<void> update(PersonalMemoEntry memo);
  Future<void> remove(String id, {required String ownerUserId});

  /// When admin approves and provides a canonical id, link + update status.
  Future<void> linkToCanonical({
    required String id,
    required String ownerUserId,
    required String canonicalEntityId,
  });

  /// Convenience: find an active memo by type+name for quick lookups.
  Future<PersonalMemoEntry?> findActiveByName({
    required String ownerUserId,
    required CurEntityType entityType,
    required String name,
  });
}
