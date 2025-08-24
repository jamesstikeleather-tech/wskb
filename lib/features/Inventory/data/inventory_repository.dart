// lib/features/inventory/data/inventory_repository.dart
import 'dart:async';
import '../../inventory/models/inventory_item.dart';

abstract class InventoryRepository {
  Stream<List<InventoryItem>> watchAll();
  Future<void> add(InventoryItem item);
  Future<void> update(InventoryItem item);
  Future<void> remove(String id);
}
