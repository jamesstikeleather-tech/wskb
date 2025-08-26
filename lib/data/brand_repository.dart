import 'dart:async';
import 'brand.dart';

class BrandRepository {
  // Singleton so everyone sees the same list
  static final BrandRepository _instance = BrandRepository._();
  factory BrandRepository() => _instance;
  BrandRepository._() {
    // Seed your existing sample brands here if you have them.
    // If you already had a list, keep it—don’t duplicate ids.
    _items.addAll([
      // Example seeds (replace with your own or remove):
      // Brand(id: 'brand_alpha', name: 'Alpha Shaving Works', country: 'UK'),
      // Brand(id: 'brand_paradigm', name: 'Paradigm', country: 'USA'),
      // Brand(id: 'brand_ascender', name: 'Ascender Razors', country: 'USA'),
    Brand(id: 'brand_rockwell', name: 'Rockwell Razors', country: 'CA'),
    Brand(id: 'brand_dovo', name: 'DOVO', country: 'DE'),
    Brand(id: 'brand_feather', name: 'Feather', country: 'JP'),
    Brand(id: 'brand_iwasaki', name: 'Iwasaki', country: 'JP'),
    Brand(id: 'b1', name: 'Alpha Shaving Works', country: 'UK'),
    Brand(id: 'b2', name: 'Paradigm', country: 'USA'),
    Brand(id: 'b3', name: 'Ascender Razors', country: 'USA'),
    Brand(id: 'brand_oneblade', name: 'OneBlade', country: 'US'),

    ]);
    _emit();
  }

  final _items = <Brand>[];
  final _ctrl = StreamController<List<Brand>>.broadcast();

  void _emit() => _ctrl.add(List.unmodifiable(_items));

  List<Brand> all() => List.unmodifiable(_items);

  Stream<List<Brand>> watchAll() {
    // emit immediately to new listeners
    _emit();
    return _ctrl.stream;
  }

  Brand? byId(String id) {
    for (final b in _items) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Create the brand if missing; return the id (existing or new).
  String ensure({required String id, required String name, String? country}) {
    final existing = byId(id);
    if (existing != null) return existing.id;
    _items.add(Brand(id: id, name: name, country: country));
    _emit();
    return id;
  }
}
