// lib/features/memos/models/personal_memo_entry.dart
import 'dart:convert';
import 'catalog_update_request.dart' show CurEntityType;

/// Lifecycle state of a personal memo entry.
enum PersonalMemoStatus {
  active,      // user is using it locally
  linked,      // admin approved; linked to a cloud catalog id
  rejected,    // admin rejected (user may still keep it locally)
  archived,    // no longer used
}

/// User-owned local placeholder for an entity that may not exist in the cloud catalog yet.
class PersonalMemoEntry {
  final String id;               // UUID or Firestore doc id
  final String ownerUserId;      // who owns it
  final CurEntityType entityType;
  final String name;             // display name ("Maker", "Blade", etc.)
  final Map<String, dynamic> fields; // extra arbitrary fields, e.g., {"country":"JP"}
  final PersonalMemoStatus status;

  /// If/when approved & created in cloud catalog, store the canonical id here.
  final String? canonicalEntityId;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PersonalMemoEntry({
    required this.id,
    required this.ownerUserId,
    required this.entityType,
    required this.name,
    this.fields = const {},
    this.status = PersonalMemoStatus.active,
    this.canonicalEntityId,
    required this.createdAt,
    required this.updatedAt,
  });

  PersonalMemoEntry copyWith({
    String? id,
    String? ownerUserId,
    CurEntityType? entityType,
    String? name,
    Map<String, dynamic>? fields,
    PersonalMemoStatus? status,
    String? canonicalEntityId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalMemoEntry(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      entityType: entityType ?? this.entityType,
      name: name ?? this.name,
      fields: fields ?? Map<String, dynamic>.from(this.fields),
      status: status ?? this.status,
      canonicalEntityId: canonicalEntityId ?? this.canonicalEntityId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'entityType': entityType.name,
        'name': name,
        'fields': fields,
        'status': status.name,
        'canonicalEntityId': canonicalEntityId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PersonalMemoEntry.fromJson(Map<String, dynamic> json) {
    return PersonalMemoEntry(
      id: json['id'] as String,
      ownerUserId: json['ownerUserId'] as String,
      entityType: CurEntityType.values.byName(json['entityType'] as String),
      name: json['name'] as String,
      fields: (json['fields'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      status: PersonalMemoStatus.values.byName(json['status'] as String),
      canonicalEntityId: json['canonicalEntityId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory PersonalMemoEntry.fromJsonString(String s) =>
      PersonalMemoEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
