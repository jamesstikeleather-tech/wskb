// lib/features/catalogs/models/razor.dart


/// High-level razor types used for filtering and grouping.
enum RazorType { safety, straight, shavette, kamisori, other }

/// Form factors (blades/handles) for safety and straight variants.
/// NOTE: Use camelCase names so analyzer stays happy.
enum RazorForm {
  // Safety
  de,              // double-edge
  seGem,           // GEM format
  seInjector,      // Injector format
  seAc,            // Artist Club (AC)
  seFhs10,         // FHS-10 (Valet/OneBlade)
  cartridgeMulti,  // multi-blade cartridge

  // Straight families
  straightFolding,
  straightFixed,          // non-folding straight
  kamisoriTraditional,    // asymmetrical grind
  shavetteFolding,
  shavetteFixed,

  // Fallback
  other,
}

/// Primary model for cataloged razors.
/// Includes schemaVersion so we can evolve the shape safely.
class Razor {
  /// Bump when structure changes (migrations below will upgrade older docs).
  static const int currentSchema = 3;

  final String id;
  final String name;
  final RazorType razorType;
  final RazorForm? form;

  final String? brandId;
  final String? makerId;

  final List<String> aliases;
  final Map<String, dynamic> specs;

  /// NEW: images (Storage paths or HTTPS URLs)
  final List<String> images;

  /// The schema version this instance represents.
  final int schemaVersion;

  const Razor({
    required this.id,
    required this.name,
    required this.razorType,
    this.form,
    this.brandId,
    this.makerId,
    this.aliases = const [],
    this.specs = const {},
    this.images = const [],
    this.schemaVersion = currentSchema,
  });

  Razor copyWith({
    String? id,
    String? name,
    RazorType? razorType,
    RazorForm? form,
    String? brandId,
    String? makerId,
    List<String>? aliases,
    Map<String, dynamic>? specs,
    List<String>? images,
    int? schemaVersion,
  }) {
    return Razor(
      id: id ?? this.id,
      name: name ?? this.name,
      razorType: razorType ?? this.razorType,
      form: form ?? this.form,
      brandId: brandId ?? this.brandId,
      makerId: makerId ?? this.makerId,
      aliases: aliases ?? List<String>.from(this.aliases),
      specs: specs ?? Map<String, dynamic>.from(this.specs),
      images: images ?? List<String>.from(this.images),
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'razorType': razorType.name,
        'form': form?.name,
        'brandId': brandId,
        'makerId': makerId,
        'aliases': aliases,
        'specs': specs,
        'images': images,
        'schemaVersion': schemaVersion,
      };

  /// Tolerant builder from JSON (works for older docs too).
  factory Razor.fromJson(Map<String, dynamic> json) {
    final ver = (json['schemaVersion'] as num?)?.toInt() ?? 1;
    final migrated = migrateJson(json, ver);

    RazorForm? form;
    final f = migrated['form'];
    if (f is String && f.isNotEmpty) {
      // parse form name, case-insensitive
      form = RazorForm.values.firstWhere(
        (v) => v.name.toLowerCase() == f.toLowerCase(),
        orElse: () => RazorForm.other,
      );
    }

    RazorType type = RazorType.other;
    final t = migrated['razorType'];
    if (t is String && t.isNotEmpty) {
      type = RazorType.values.firstWhere(
        (v) => v.name == t,
        orElse: () => RazorType.other,
      );
    }

    return Razor(
      id: (migrated['id'] as String?) ?? '',
      name: (migrated['name'] as String?) ?? '',
      razorType: type,
      form: form,
      brandId: migrated['brandId'] as String?,
      makerId: migrated['makerId'] as String?,
      aliases: (migrated['aliases'] as List?)?.cast<String>() ?? const [],
      specs: (migrated['specs'] as Map?)?.cast<String, dynamic>() ?? const {},
      images: (migrated['images'] as List?)?.cast<String>() ?? const [],
      schemaVersion: (migrated['schemaVersion'] as num?)?.toInt() ?? currentSchema,
    );
  }

  /// Pure function: take any older JSON + its version and return v[currentSchema].
  static Map<String, dynamic> migrateJson(Map<String, dynamic> src, int ver) {
    final out = Map<String, dynamic>.from(src);

    // v1 -> v2: normalize aliases/specs, add makerId slot, stamp schemaVersion=2
    if (ver < 2) {
      // aliases may have been a semicolon-joined string
      final a = out['aliases'];
      if (a is String) {
        out['aliases'] = a
            .split(';')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (a == null) {
        out['aliases'] = <String>[];
      }

      // specs should be a Map<String,dynamic>
      out['specs'] = (out['specs'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

      // ensure makerId exists (nullable)
      if (!out.containsKey('makerId')) out['makerId'] = null; // optional; or just drop it

      out['schemaVersion'] = 2;
    }

    // v2 -> v3: move specs.images -> images[], ensure images list exists
    final sv = (out['schemaVersion'] as num?)?.toInt() ?? 2;
    if (sv < 3) {
      final specs = (out['specs'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final imgs = <String>[];

      final si = specs['images'];
      if (si is String && si.trim().isNotEmpty) {
        imgs.addAll(
          si.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty),
        );
        specs.remove('images');
      } else if (si is List) {
        imgs.addAll(si.map((e) => e.toString()).where((s) => s.isNotEmpty));
        specs.remove('images');
      }

      out['images'] = (out['images'] as List?)?.cast<String>() ?? imgs;
      out['specs'] = specs;
      out['schemaVersion'] = 3;
    }

    return out;
  }
}
