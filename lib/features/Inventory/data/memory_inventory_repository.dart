// lib/features/inventory/data/memory_inventory_repository.dart
import 'dart:async';
import '../../inventory/models/inventory_item.dart';
import 'inventory_repository.dart';

class MemoryInventoryRepository implements InventoryRepository {
  final _controller = StreamController<List<InventoryItem>>.broadcast();
  final List<InventoryItem> _items = [
    InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: InventoryType.razor,
      name: 'Alpha Outlaw Evolution Titanium',
      notes: 'Initial sample entry',
    ),
  ];

  MemoryInventoryRepository() {
    _emit();
  }

  void _emit() => _controller.add(List.unmodifiable(_items));

  @override
 Stream<List<InventoryItem>> watchAll() async* {
  // seed with current items immediately
  yield List.unmodifiable(_items);
  // then forward subsequent updates
  yield* _controller.stream;
 }


  @override
  Future<void> add(InventoryItem item) async {
    _items.add(item);
    _emit();
  }

  @override
  Future<void> update(InventoryItem item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      _emit();
    }
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    _emit();
  }
}
