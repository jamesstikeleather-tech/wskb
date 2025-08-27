import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/razor.dart';
import 'razor_repository.dart';

class FirestoreRazorRepository implements RazorRepository {
  final _col = FirebaseFirestore.instance.collection('razors');

  @override
  Future<void> add(Razor r) async {
    await _col.doc(r.id).set(
      r.copyWith(schemaVersion: Razor.currentSchema).toJson(),
    );
  }

  @override
  Future<void> update(Razor r) async {
    await _col.doc(r.id).set(
      r.copyWith(schemaVersion: Razor.currentSchema).toJson(),
      SetOptions(merge: true),
    );
  }

  // ✅ Your interface wants `remove` (not delete)
  @override
  Future<void> remove(String id) => _col.doc(id).delete();

  @override
  Stream<List<Razor>> watchAll({RazorType? typeFilter}) {
    Query<Map<String, dynamic>> q = _col;
    if (typeFilter != null) q = q.where('razorType', isEqualTo: typeFilter.name);

    return q.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        _migrateIfNeeded(doc.reference, data).ignore();
        return Razor.fromJson(data);
      }).toList();
    });
  }

  // If your interface is `Stream<Razor?> watchOne(String id)`:
  @override
  Stream<Razor?> watchOne(String id) {
    final ref = _col.doc(id);
    return ref.snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!..['id'] = snap.id;
      _migrateIfNeeded(ref, data).ignore();
      return Razor.fromJson(data);
    });
  }

  // If the interface is `Stream<Razor> watchOne(String id)` (non-null), use this instead:
  // @override
  // Stream<Razor> watchOne(String id) => _col.doc(id).snapshots()
  //   .where((s) => s.exists)
  //   .map((snap) {
  //     final data = snap.data()!..['id'] = snap.id;
  //     _migrateIfNeeded(snap.reference, data).ignore();
  //     return Razor.fromJson(data);
  //   });

  Future<void> _migrateIfNeeded(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) async {
    final ver = (data['schemaVersion'] as num?)?.toInt() ?? 1;
    if (ver >= Razor.currentSchema) return;
    final migrated = Razor.migrateJson(data, ver)..['migratedAt'] = FieldValue.serverTimestamp();
    try {
      await ref.set(migrated, SetOptions(merge: true));
    } catch (_) {/* ignore */}
  }
}

extension on Future<void> {
  void ignore() {}
}
