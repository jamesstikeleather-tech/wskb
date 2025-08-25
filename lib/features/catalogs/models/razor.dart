enum RazorType { safety, straight, shavette, kamisori, other }

enum RazorForm {
  de,
  seGem,
  seInjector,
  seAc,
  seFhs10,
  cartridgeMulti,
  straightFolding,
  straightFixed,
  kamisoriTraditional,
  shavetteFolding,
  shavetteFixed,
  other,
}

class Razor {
  final String id;
  final String name;
  final RazorType razorType;
  final RazorForm? form;
  final String? brandId;
  final List<String> aliases;
  final Map<String, dynamic> specs;

  const Razor({
    required this.id,
    required this.name,
    required this.razorType,
    this.form,
    this.brandId,
    this.aliases = const [],
    this.specs = const {},
  });

  Razor copyWith({
    String? id,
    String? name,
    RazorType? razorType,
    RazorForm? form,
    String? brandId,
    List<String>? aliases,
    Map<String, dynamic>? specs,
  }) {
    return Razor(
      id: id ?? this.id,
      name: name ?? this.name,
      razorType: razorType ?? this.razorType,
      form: form ?? this.form,
      brandId: brandId ?? this.brandId,
      aliases: aliases ?? List<String>.from(this.aliases),
      specs: specs ?? Map<String, dynamic>.from(this.specs),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'razorType': razorType.name,
    'form': form?.name, // writes camelCase going forward
    'brandId': brandId,
    'aliases': aliases,
    'specs': specs,
  };

  factory Razor.fromJson(Map<String, dynamic> json) {
    RazorForm? form;
    final f = json['form'];
    if (f is String) form = _parseRazorFormCompat(f);

    return Razor(
      id: json['id'] as String,
      name: json['name'] as String,
      razorType: RazorType.values.byName(json['razorType'] as String),
      form: form,
      brandId: json['brandId'] as String?,
      aliases: (json['aliases'] as List?)?.cast<String>() ?? const [],
      specs: (json['specs'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}

/// Accepts both legacy snake_case (e.g. "se_fhs10") and new camelCase ("seFhs10")
RazorForm _parseRazorFormCompat(String raw) {
  // try exact camelCase first
  for (final v in RazorForm.values) {
    if (v.name == raw) return v;
  }
  // convert snake_case -> lowerCamel
  final parts = raw.trim().split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return RazorForm.other;
  final camel = [
    parts.first.toLowerCase(),
    ...parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase()),
  ].join();
  for (final v in RazorForm.values) {
    if (v.name.toLowerCase() == camel.toLowerCase()) return v;
  }
  return RazorForm.other;
}
