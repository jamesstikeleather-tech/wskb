class Maker {
  final String id;
  final String name;
  final String? country; // optional, for later

  const Maker({
    required this.id,
    required this.name,
    this.country,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
      };

  factory Maker.fromJson(Map<String, dynamic> json) => Maker(
        id: json['id'] as String,
        name: json['name'] as String,
        country: json['country'] as String?,
      );
}
