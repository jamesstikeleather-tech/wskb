import 'package:cloud_firestore/cloud_firestore.dart';
import '../../inventory/models/inventory_item.dart';
import 'inventory_repository.dart';

class FirestoreInventoryRepository implements InventoryRepository {
  final _col = FirebaseFirestore.instance.collection('inventory');

  @override
  Stream<List<InventoryItem>> watchAll() {
    return _col.orderBy('name').snapshots().map((qs) {
      return qs.docs.map((d) {
        final data = d.data(); // already Map<String, dynamic>
        final withId = {...data, 'id': data['id'] ?? d.id};
        return InventoryItem.fromJson(withId);
      }).toList();
    });
  }

  @override
  Future<void> add(InventoryItem item) async {
    final id = item.id.isNotEmpty ? item.id : _col.doc().id;
    await _col.doc(id).set({...item.toJson(), 'id': id});
  }

  @override
  Future<void> update(InventoryItem item) async {
    await _col.doc(item.id).set({...item.toJson(), 'id': item.id}, SetOptions(merge: true));
  }

  @override
  Future<void> remove(String id) => _col.doc(id).delete();
}
