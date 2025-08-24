import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/personal_memo_entry.dart';
import '../../memos/models/catalog_update_request.dart' show CurEntityType;
import 'personal_memo_repository.dart';

class FirestorePersonalMemoRepository implements PersonalMemoRepository {
  final String ownerUserId;
  FirestorePersonalMemoRepository(this.ownerUserId);

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users')
        .doc(ownerUserId)
        .collection('personal_memos');

  @override
  Stream<List<PersonalMemoEntry>> watchAll({required String ownerUserId}) {
    // ignore ownerUserId param and use the instance’s owner — simple & explicit
    return _col.orderBy('updatedAt', descending: true).snapshots().map((qs) {
      return qs.docs.map((d) {
        final m = d.data();
        // Coerce Timestamps -> ISO strings expected by fromJson()
        String iso(DateTime dt) => dt.toIso8601String();
        final createdAt = (m['createdAt'] is Timestamp)
            ? iso((m['createdAt'] as Timestamp).toDate())
            : m['createdAt'] as String;
        final updatedAt = (m['updatedAt'] is Timestamp)
            ? iso((m['updatedAt'] as Timestamp).toDate())
            : m['updatedAt'] as String;
        return PersonalMemoEntry.fromJson({
          ...m,
          'id': m['id'] ?? d.id,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        });
      }).toList();
    });
  }

  @override
  Future<void> add(PersonalMemoEntry memo) async {
    final id = memo.id.isNotEmpty ? memo.id : _col.doc().id;
    final json = memo.toJson();
    json['id'] = id;
    // Store as Timestamp for good querying
    json['createdAt'] = Timestamp.fromDate(memo.createdAt);
    json['updatedAt'] = Timestamp.fromDate(memo.updatedAt);
    await _col.doc(id).set(json);
  }

  @override
  Future<void> update(PersonalMemoEntry memo) async {
    final json = memo.toJson();
    json['updatedAt'] = Timestamp.fromDate(memo.updatedAt);
    await _col.doc(memo.id).set(json, SetOptions(merge: true));
  }

  @override
  Future<void> remove(String id, {required String ownerUserId}) =>
      _col.doc(id).delete();

  @override
  Future<void> linkToCanonical({
    required String id,
    required String ownerUserId,
    required String canonicalEntityId,
  }) async {
    await _col.doc(id).set({
      'canonicalEntityId': canonicalEntityId,
      'status': PersonalMemoStatus.linked.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Simple, case-insensitive name match in Firestore
  String _norm(String s) => s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  @override
  Future<PersonalMemoEntry?> findActiveByName({
    required String ownerUserId,
    required CurEntityType entityType,
    required String name,
  }) async {
    final q = await _col
        .where('entityType', isEqualTo: entityType.name)
        .where('status', isEqualTo: PersonalMemoStatus.active.name)
        .get();
    final n = _norm(name);
    for (final d in q.docs) {
      final m = d.data();
      final hit = _norm(m['name'] as String);
      if (hit == n) {
        // map timestamps like in watchAll()
        String iso(DateTime dt) => dt.toIso8601String();
        final createdAt = (m['createdAt'] is Timestamp)
            ? iso((m['createdAt'] as Timestamp).toDate())
            : m['createdAt'] as String;
        final updatedAt = (m['updatedAt'] is Timestamp)
            ? iso((m['updatedAt'] as Timestamp).toDate())
            : m['updatedAt'] as String;
        return PersonalMemoEntry.fromJson({
          ...m,
          'id': m['id'] ?? d.id,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
        });
      }
    }
    return null;
  }
}
