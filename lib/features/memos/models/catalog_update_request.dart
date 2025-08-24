// lib/features/memos/models/catalog_update_request.dart
import 'dart:convert';

/// What kind of change the requester wants to make.
enum CurAction { add, update, deleteRequest }

/// Which catalog (or meta-catalog) the request targets.
/// Add more as your schema grows.
enum CurEntityType {
  razorHead,
  razorHandle,
  straightRazor,
  brushHandle,
  brushKnot,
  blade,
  fragrance,
  brand,
  company,
  material,
  themeMood,
  topCap,
  basePlate,
  adjustableSet,
  storageLocation,
  other,
}

/// Review lifecycle for a request.
enum CurStatus { open, underReview, approved, rejected, merged, withdrawn }

/// Priority triage. Keep it simple.
enum CurPriority { low, normal, high, urgent }

/// A lightweight, serializable record for proposing changes to shared catalogs.
/// - `targetEntityId` is null when `action == add`.
/// - `proposedChanges` is a free-form field/value map (e.g., {"name":"Kai Stainless"})
class CatalogUpdateRequest {
  final String id; // e.g., UUID (client-generated is fine)
  final DateTime createdAt;
  final String createdByUserId;

  final CurAction action;
  final CurEntityType entityType;
  final String? targetEntityId; // null when adding a new entity

  final String title; // short human-readable summary
  final String? description; // longer rationale/context

  final Map<String, dynamic> proposedChanges;

  final CurStatus status;
  final CurPriority priority;

  // Optional moderation/ops fields
  final String? reviewerUserId;
  final DateTime? reviewedAt;

  // Optional references
  final List<String> attachmentUrls; // images/docs stored elsewhere
  final List<String> relatedLinks; // forum threads, vendor pages, etc.

  const CatalogUpdateRequest({
    required this.id,
    required this.createdAt,
    required this.createdByUserId,
    required this.action,
    required this.entityType,
    required this.targetEntityId,
    required this.title,
    this.description,
    required this.proposedChanges,
    this.status = CurStatus.open,
    this.priority = CurPriority.normal,
    this.reviewerUserId,
    this.reviewedAt,
    this.attachmentUrls = const [],
    this.relatedLinks = const [],
  });

  CatalogUpdateRequest copyWith({
    String? id,
    DateTime? createdAt,
    String? createdByUserId,
    CurAction? action,
    CurEntityType? entityType,
    String? targetEntityId,
    String? title,
    String? description,
    Map<String, dynamic>? proposedChanges,
    CurStatus? status,
    CurPriority? priority,
    String? reviewerUserId,
    DateTime? reviewedAt,
    List<String>? attachmentUrls,
    List<String>? relatedLinks,
  }) {
    return CatalogUpdateRequest(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      targetEntityId: targetEntityId ?? this.targetEntityId,
      title: title ?? this.title,
      description: description ?? this.description,
      proposedChanges: proposedChanges ?? Map<String, dynamic>.from(this.proposedChanges),
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reviewerUserId: reviewerUserId ?? this.reviewerUserId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      attachmentUrls: attachmentUrls ?? List<String>.from(this.attachmentUrls),
      relatedLinks: relatedLinks ?? List<String>.from(this.relatedLinks),
    );
  }

  // ---- Serialization helpers (plain Dart) ----

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'createdByUserId': createdByUserId,
        'action': action.name,
        'entityType': entityType.name,
        'targetEntityId': targetEntityId,
        'title': title,
        'description': description,
        'proposedChanges': proposedChanges,
        'status': status.name,
        'priority': priority.name,
        'reviewerUserId': reviewerUserId,
        'reviewedAt': reviewedAt?.toIso8601String(),
        'attachmentUrls': attachmentUrls,
        'relatedLinks': relatedLinks,
      };

  factory CatalogUpdateRequest.fromJson(Map<String, dynamic> json) {
    return CatalogUpdateRequest(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdByUserId: json['createdByUserId'] as String,
      action: CurAction.values.byName(json['action'] as String),
      entityType: CurEntityType.values.byName(json['entityType'] as String),
      targetEntityId: json['targetEntityId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      proposedChanges: (json['proposedChanges'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      status: json['status'] != null
          ? CurStatus.values.byName(json['status'] as String)
          : CurStatus.open,
      priority: json['priority'] != null
          ? CurPriority.values.byName(json['priority'] as String)
          : CurPriority.normal,
      reviewerUserId: json['reviewerUserId'] as String?,
      reviewedAt: (json['reviewedAt'] as String?) != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      attachmentUrls: (json['attachmentUrls'] as List?)?.cast<String>() ?? const <String>[],
      relatedLinks: (json['relatedLinks'] as List?)?.cast<String>() ?? const <String>[],
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory CatalogUpdateRequest.fromJsonString(String source) =>
      CatalogUpdateRequest.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CatalogUpdateRequest(${jsonEncode(toJson())})';

  @override
  bool operator ==(Object other) =>
      other is CatalogUpdateRequest && other.toJsonString() == toJsonString();

  @override
  int get hashCode => toJsonString().hashCode;
}
