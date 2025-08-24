// lib/features/diary/data/diary_repository.dart
import 'dart:async';
import '../../memos/models/diary_transaction.dart';

abstract class DiaryRepository {
  Stream<List<DiaryTransaction>> watchAll();
  Future<void> add(DiaryTransaction tx);
  Future<void> remove(String id);
}
