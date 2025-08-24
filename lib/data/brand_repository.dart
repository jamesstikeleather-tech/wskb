// lib/data/brand_repository.dart
import 'brand.dart';

class BrandRepository {
  static final BrandRepository _instance = BrandRepository._internal();
  factory BrandRepository() => _instance;
  BrandRepository._internal();

  final List<Brand> _brands = const [
    Brand(id: 'b1', name: 'Alpha Shaving Works', country: 'UK'),
    Brand(id: 'b2', name: 'Paradigm', country: 'USA'),
    Brand(id: 'b3', name: 'Ascender Razors', country: 'USA'),
  ];

  List<Brand> all() => List.unmodifiable(_brands);

  Brand? byId(String id) {
    try {
      return _brands.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
