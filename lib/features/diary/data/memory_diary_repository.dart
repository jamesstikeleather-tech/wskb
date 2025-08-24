// lib/features/diary/data/memory_diary_repository.dart
import 'dart:async';
import '../../memos/models/diary_transaction.dart';
import 'diary_repository.dart';

class MemoryDiaryRepository implements DiaryRepository {
  final _controller = StreamController<List<DiaryTransaction>>.broadcast();
  final List<DiaryTransaction> _items = [
    DiaryTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      occurredAt: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'local',
      overallSatisfaction: Likert5.high,
      notes: 'Sample entry',
    ),
  ];

  MemoryDiaryRepository() {
    _emit();
  }

  void _emit() => _controller.add(List.unmodifiable(_items));

  @override
 Stream<List<DiaryTransaction>> watchAll() async* {
  yield List.unmodifiable(_items);
  yield* _controller.stream;
 }


  @override
  Future<void> add(DiaryTransaction tx) async {
    _items.add(tx);
    _emit();
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    _emit();
  }
}
