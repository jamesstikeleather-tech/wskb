// lib/features/catalogs/data/razor_repository.dart
import '../models/razor.dart';

abstract class RazorRepository {
  Stream<List<Razor>> watchAll({RazorType? typeFilter});
  Stream<Razor?> watchOne(String id);        // ⬅️ NEW
  Future<void> add(Razor r);
  Future<void> update(Razor r);
  Future<void> remove(String id);
}
