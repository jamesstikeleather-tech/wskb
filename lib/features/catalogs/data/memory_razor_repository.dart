// lib/features/catalogs/data/memory_razor_repository.dart
import 'dart:async';
import '../models/razor.dart';
import 'razor_repository.dart';

class MemoryRazorRepository implements RazorRepository {
  final _controller = StreamController<List<Razor>>.broadcast();
  final List<Razor> _items = [
 Razor(
    id: 'r_rockwell_6s',
    name: 'Rockwell 6S',
    razorType: RazorType.safety,
    form: RazorForm.de,
    brandId: 'brand_rockwell',
    aliases: ['6S'],
    specs: {
      'mechanism': 'three_piece',
      'adjustable': true,
      'slant': false,
      'tto': false,
      // plate-specific specs live here
      'plates': [
       {'name': 'R1', 'barTypes': ['SB'], 'gap_mm': 0.20, 'exposure': 'mild'},
       {'name': 'R2', 'barTypes': ['SB'], 'gap_mm': 0.35, 'exposure': 'mild'},
        // (you can add R3–R6 later)
      ],
    },
  ),
  Razor(
    id: 'r_dovo_bismarck',
    name: 'Dovo Bismarck',
    razorType: RazorType.straight,
    form: RazorForm.straightFolding, // ⬅️ folding straight
    brandId: 'brand_dovo',
    aliases: ['Bismarck'],
    specs: {'grind': 'full_hollow', 'width_in': '6/8', 'point': 'round', 'steel': 'carbon'},
  ),
  Razor(
    id: 'r_feather_ac_ss',
    name: 'Feather Artist Club SS',
    razorType: RazorType.shavette,
    form: RazorForm.shavetteFolding, // ⬅️ folding shavette
    brandId: 'brand_feather',
    aliases: ['Feather SS', 'AC SS'],
    specs: {'bladeFormat': 'AC', 'clamp': 'spring'},
  ),
  Razor(
    id: 'r_iwasaki_kamisori',
    name: 'Iwasaki Kamisori',
    razorType: RazorType.kamisori,
    form: RazorForm.kamisoriTraditional, // ⬅️ asymmetric grind
    brandId: 'brand_iwasaki',
    aliases: ['Iwasaki'],
    specs: {'steel': 'Swedish steel', 'handedness': 'right'},
  ),
Razor(
    id: 'r_oneblade_core',
    name: 'OneBlade Core',
    razorType: RazorType.safety,
    form: RazorForm.seFhs10,     // ⬅️ FHS-10 form
    brandId: 'brand_oneblade',
    aliases: ['Core'],
    specs: {
      'mechanism': 'one_piece',
      'adjustable': false,
      'slant': false,
      'tto': false,
      'bladeFormat': 'FHS-10',
      'barTypes': ['SB'], // top-level for fixed guard 
    },
  ),
];


  void _emit() => _controller.add(List.unmodifiable(_items));
  Razor? _findById(String id) {
    for (final r in _items) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Stream<List<Razor>> watchAll({RazorType? typeFilter}) async* {
    // seed immediately
    final seed = typeFilter == null
        ? List<Razor>.unmodifiable(_items)
        : List<Razor>.unmodifiable(_items.where((r) => r.razorType == typeFilter));
    yield seed;

    // then stream updates
    yield* _controller.stream.map((list) {
      if (typeFilter == null) return list;
      return list.where((r) => r.razorType == typeFilter).toList(growable: false);
    });
  }

  @override
  Stream<Razor?> watchOne(String id) async* {
    // seed
    yield _findById(id);
    // then update whenever the list changes
    yield* _controller.stream.map((_) => _findById(id));
  }

  @override
  Future<void> add(Razor r) async { _items.add(r); _emit(); }

  @override
  Future<void> update(Razor r) async {
    final i = _items.indexWhere((x) => x.id == r.id);
    if (i != -1) _items[i] = r;
    _emit();
  }

  @override
  Future<void> remove(String id) async { _items.removeWhere((x) => x.id == id); _emit(); }
}
