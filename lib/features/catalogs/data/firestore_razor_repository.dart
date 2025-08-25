// lib/features/catalogs/data/firestore_razor_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/razor.dart';
import 'razor_repository.dart';

class FirestoreRazorRepository implements RazorRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('razors');

  @override
  Stream<List<Razor>> watchAll({RazorType? typeFilter}) {
    final base = (typeFilter == null)
        ? _col.orderBy('name')
        : _col.where('razorType', isEqualTo: typeFilter.name).orderBy('name');

    return base.snapshots().map((qs) {
      return qs.docs.map((d) {
        final data = d.data();
        final withId = {...data, 'id': data['id'] ?? d.id};
        return Razor.fromJson(withId);
      }).toList();
    });
  }

  @override
  Stream<Razor?> watchOne(String id) {
    return _col.doc(id).snapshots().map((ds) {
      if (!ds.exists) return null;
      final data = ds.data()!;
      final withId = {...data, 'id': data['id'] ?? ds.id};
      return Razor.fromJson(withId);
    });
  }

  @override
  Future<void> add(Razor r) async {
    final id = r.id.isNotEmpty ? r.id : _col.doc().id;
    await _col.doc(id).set({...r.toJson(), 'id': id});
  }

  @override
  Future<void> update(Razor r) async {
    await _col.doc(r.id).set({...r.toJson(), 'id': r.id}, SetOptions(merge: true));
  }

  @override
  Future<void> remove(String id) => _col.doc(id).delete();
}
