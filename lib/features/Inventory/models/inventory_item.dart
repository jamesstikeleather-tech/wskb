// lib/features/inventory/models/inventory_item.dart
enum InventoryType { razor, blade, brush, software, other }

class InventoryItem {
  final String id;          // UUID
  final InventoryType type; // category
  final String name;        // display name
  final String? notes;

  /// New: mark that this item’s definition comes from a local Personal Memo.
  final bool isPersonal;

  /// New: link to the PersonalMemoEntry.id (if isPersonal==true).
  final String? personalMemoId;

  const InventoryItem({
    required this.id,
    required this.type,
    required this.name,
    this.notes,
    this.isPersonal = false,
    this.personalMemoId,
  });

  InventoryItem copyWith({
    String? id,
    InventoryType? type,
    String? name,
    String? notes,
    bool? isPersonal,
    String? personalMemoId,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      isPersonal: isPersonal ?? this.isPersonal,
      personalMemoId: personalMemoId ?? this.personalMemoId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'notes': notes,
        'isPersonal': isPersonal,
        'personalMemoId': personalMemoId,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      type: InventoryType.values.byName(json['type'] as String),
      name: json['name'] as String,
      notes: json['notes'] as String?,
      isPersonal: (json['isPersonal'] as bool?) ?? false,
      personalMemoId: json['personalMemoId'] as String?,
    );
  }
}
