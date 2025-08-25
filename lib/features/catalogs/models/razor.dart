// lib/features/catalogs/models/razor.dart
enum RazorType { safety, straight, shavette, kamisori, other }

class Razor {
  final String id;
  final String name;
  final RazorType razorType;
  final String? brandId;              // optional for now
  final List<String> aliases;         // alternate names
  final Map<String, dynamic> specs;   // type-specific fields (flexible)

  const Razor({
    required this.id,
    required this.name,
    required this.razorType,
    this.brandId,
    this.aliases = const [],
    this.specs = const {},
  });

  Razor copyWith({
    String? id,
    String? name,
    RazorType? razorType,
    String? brandId,
    List<String>? aliases,
    Map<String, dynamic>? specs,
  }) {
    return Razor(
      id: id ?? this.id,
      name: name ?? this.name,
      razorType: razorType ?? this.razorType,
      brandId: brandId ?? this.brandId,
      aliases: aliases ?? List<String>.from(this.aliases),
      specs: specs ?? Map<String, dynamic>.from(this.specs),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'razorType': razorType.name,
    'brandId': brandId,
    'aliases': aliases,
    'specs': specs,
  };

  factory Razor.fromJson(Map<String, dynamic> json) {
    return Razor(
      id: json['id'] as String,
      name: json['name'] as String,
      razorType: RazorType.values.byName(json['razorType'] as String),
      brandId: json['brandId'] as String?,
      aliases: (json['aliases'] as List?)?.cast<String>() ?? const [],
      specs: (json['specs'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}
