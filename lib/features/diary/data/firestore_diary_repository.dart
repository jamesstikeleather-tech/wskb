import 'package:cloud_firestore/cloud_firestore.dart';
import '../../memos/models/diary_transaction.dart';
import 'diary_repository.dart';

class FirestoreDiaryRepository implements DiaryRepository {
  final _col = FirebaseFirestore.instance.collection('diary');

  @override
  Stream<List<DiaryTransaction>> watchAll() {
    return _col.orderBy('occurredAt', descending: true).snapshots().map((qs) {
      return qs.docs.map((d) {
        final map = d.data(); // Map<String, dynamic>
        final occurredAt = map['occurredAt'];
        if (occurredAt is Timestamp) {
          map['occurredAt'] = occurredAt.toDate().toIso8601String();
        }
        map['id'] = map['id'] ?? d.id;
        return DiaryTransaction.fromJson(map);
      }).toList();
    });
  }

  @override
  Future<void> add(DiaryTransaction tx) async {
    final id = tx.id.isNotEmpty ? tx.id : _col.doc().id;
    final json = tx.toJson();
    json['occurredAt'] = Timestamp.fromDate(tx.occurredAt);
    json['id'] = id;
    await _col.doc(id).set(json);
  }

  @override
  Future<void> remove(String id) => _col.doc(id).delete();
}
