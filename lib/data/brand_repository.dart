// lib/data/brand_repository.dart
import 'brand.dart';

class BrandRepository {
  static final BrandRepository _instance = BrandRepository._internal();
  factory BrandRepository() => _instance;
  BrandRepository._internal();

  final List<Brand> _brands = const [
    Brand(id: 'brand_rockwell', name: 'Rockwell Razors', country: 'CA'),
    Brand(id: 'brand_dovo', name: 'DOVO', country: 'DE'),
    Brand(id: 'brand_feather', name: 'Feather', country: 'JP'),
    Brand(id: 'brand_iwasaki', name: 'Iwasaki', country: 'JP'),
    Brand(id: 'b1', name: 'Alpha Shaving Works', country: 'UK'),
    Brand(id: 'b2', name: 'Paradigm', country: 'USA'),
    Brand(id: 'b3', name: 'Ascender Razors', country: 'USA'),
    Brand(id: 'brand_oneblade', name: 'OneBlade', country: 'US'),
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
