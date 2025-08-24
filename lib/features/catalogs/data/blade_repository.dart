// lib/features/catalogs/data/blade_repository.dart
import '../models/blade.dart';
import '../models/alias_utils.dart';

class BladeRepository {
  static final BladeRepository _instance = BladeRepository._internal();
  factory BladeRepository() => _instance;
  BladeRepository._internal();

  // Sample data with aliases
  final List<Blade> _blades = const [
    Blade(
      id: 'blade_personna_lab_blue',
      name: 'Personna Lab Blue',
      country: 'USA',
      aliases: ['Lab Blue', 'Med Prep', 'AccuForge', 'AccuThrive'],
    ),
    Blade(
      id: 'blade_personna_med_prep',
      name: 'Personna Med Prep',
      country: 'USA',
      aliases: ['Med Prep', 'Lab Blue', 'AccuForge', 'AccuThrive'],
    ),
    Blade(
      id: 'blade_personna_platinum_red',
      name: 'Personna Platinum (Red)',
      country: 'IL',
      aliases: ['Israeli Red', 'Red Personna', 'Personna Red'],
    ),
    Blade(
      id: 'blade_personna_platinum_german',
      name: 'Personna Platinum (German)',
      country: 'DE',
      aliases: ['German Personna', 'Personna Platinum'],
    ),
  ];

  List<Blade> all() => List.unmodifiable(_blades);

  Blade? findByNameOrAlias(String query) {
    for (final b in _blades) {
      if (matchesByNameOrAlias(query: query, name: b.name, aliases: b.aliases)) {
        return b;
      }
    }
    return null;
  }
}
