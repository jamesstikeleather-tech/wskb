// lib/features/catalogs/models/blade.dart
class Blade {
  final String id;
  final String name;           // canonical
  final String? brandId;       // optional for now
  final String? country;       // optional info (e.g., IL, DE, US, etc.)
  final List<String> aliases;  // alternate names people use

  const Blade({
    required this.id,
    required this.name,
    this.brandId,
    this.country,
    this.aliases = const [],
  });

  Blade copyWith({
    String? id,
    String? name,
    String? brandId,
    String? country,
    List<String>? aliases,
  }) {
    return Blade(
      id: id ?? this.id,
      name: name ?? this.name,
      brandId: brandId ?? this.brandId,
      country: country ?? this.country,
      aliases: aliases ?? List<String>.from(this.aliases),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brandId': brandId,
        'country': country,
        'aliases': aliases,
      };

  factory Blade.fromJson(Map<String, dynamic> json) {
    return Blade(
      id: json['id'] as String,
      name: json['name'] as String,
      brandId: json['brandId'] as String?,
      country: json['country'] as String?,
      aliases: (json['aliases'] as List?)?.cast<String>() ?? const [],
    );
  }
}
