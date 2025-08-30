// lib/models/diary_entry.dart
// Minimal DiaryEntry model focused on process template linkage.
// You can merge these fields into your existing DiaryEntry.

import 'dart:convert';
import 'personal_process.dart';

class CatalogOrMemoRef {
  final String? catalogId;
  final String? personalMemoId;
  const CatalogOrMemoRef({this.catalogId, this.personalMemoId});

  Map<String, dynamic> toMap() => {
        'catalogId': catalogId,
        'personalMemoId': personalMemoId,
      };

  factory CatalogOrMemoRef.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CatalogOrMemoRef();
    return CatalogOrMemoRef(
      catalogId: map['catalogId'] as String?,
      personalMemoId: map['personalMemoId'] as String?,
    );
  }
}

class DiaryEntry {
  final String id;
  final String ownerUserId;
  final String dateIso;
  final String? processTemplateId;
  final Map<String, dynamic>? processSnapshot;

  final CatalogOrMemoRef razorRef;
  final CatalogOrMemoRef bladeRef;
  final CatalogOrMemoRef brushRef;
  final CatalogOrMemoRef soapRef;
  final CatalogOrMemoRef aftershaveRef;
  final CatalogOrMemoRef fragranceRef;

  final double? rating;
  final int? weepers;
  final int? nicks;
  final int? irritation;
  final String? notes;

  const DiaryEntry({
    required this.id,
    required this.ownerUserId,
    required this.dateIso,
    this.processTemplateId,
    this.processSnapshot,
    this.razorRef = const CatalogOrMemoRef(),
    this.bladeRef = const CatalogOrMemoRef(),
    this.brushRef = const CatalogOrMemoRef(),
    this.soapRef = const CatalogOrMemoRef(),
    this.aftershaveRef = const CatalogOrMemoRef(),
    this.fragranceRef = const CatalogOrMemoRef(),
    this.rating,
    this.weepers,
    this.nicks,
    this.irritation,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'date': dateIso,
        'processTemplateId': processTemplateId,
        'processSnapshot': processSnapshot,
        'razorRef': razorRef.toMap(),
        'bladeRef': bladeRef.toMap(),
        'brushRef': brushRef.toMap(),
        'soapRef': soapRef.toMap(),
        'aftershaveRef': aftershaveRef.toMap(),
        'fragranceRef': fragranceRef.toMap(),
        'rating': rating,
        'outcomes': {'weepers': weepers, 'nicks': nicks, 'irritation': irritation},
        'notes': notes,
      };

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    final outcomes = (map['outcomes'] as Map<String, dynamic>?) ?? {};
    return DiaryEntry(
      id: map['id'] as String? ?? '',
      ownerUserId: map['ownerUserId'] as String? ?? '',
      dateIso: map['date'] as String? ?? '',
      processTemplateId: map['processTemplateId'] as String?,
      processSnapshot: map['processSnapshot'] as Map<String, dynamic>?,
      razorRef: CatalogOrMemoRef.fromMap(map['razorRef'] as Map<String, dynamic>?),
      bladeRef: CatalogOrMemoRef.fromMap(map['bladeRef'] as Map<String, dynamic>?),
      brushRef: CatalogOrMemoRef.fromMap(map['brushRef'] as Map<String, dynamic>?),
      soapRef: CatalogOrMemoRef.fromMap(map['soapRef'] as Map<String, dynamic>?),
      aftershaveRef: CatalogOrMemoRef.fromMap(map['aftershaveRef'] as Map<String, dynamic>?),
      fragranceRef: CatalogOrMemoRef.fromMap(map['fragranceRef'] as Map<String, dynamic>?),
      rating: (map['rating'] as num?)?.toDouble(),
      weepers: (outcomes['weepers'] as num?)?.toInt(),
      nicks: (outcomes['nicks'] as num?)?.toInt(),
      irritation: (outcomes['irritation'] as num?)?.toInt(),
      notes: map['notes'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory DiaryEntry.fromJson(String s) => DiaryEntry.fromMap(jsonDecode(s) as Map<String, dynamic>);

  /// Apply a PersonalProcess to prefill references and produce a snapshot.
  DiaryEntry applyingProcess(PersonalProcess process) {
    final snap = process.toMap(); // lightweight snapshot
    return DiaryEntry(
      id: id,
      ownerUserId: ownerUserId,
      dateIso: dateIso,
      processTemplateId: process.id,
      processSnapshot: snap,
      razorRef: CatalogOrMemoRef(
        catalogId: process.defaults.razorRef.catalogId,
        personalMemoId: process.defaults.razorRef.personalMemoId,
      ),
      bladeRef: CatalogOrMemoRef(
        catalogId: process.defaults.bladeRef.catalogId,
        personalMemoId: process.defaults.bladeRef.personalMemoId,
      ),
      brushRef: const CatalogOrMemoRef(), // optional: lather.brushPreferenceRef could map here
      soapRef: CatalogOrMemoRef(
        catalogId: process.defaults.software.soapRef.catalogId,
        personalMemoId: process.defaults.software.soapRef.personalMemoId,
      ),
      aftershaveRef: CatalogOrMemoRef(
        catalogId: process.defaults.software.aftershaveRef.catalogId,
        personalMemoId: process.defaults.software.aftershaveRef.personalMemoId,
      ),
      fragranceRef: CatalogOrMemoRef(
        catalogId: process.defaults.software.fragranceRef.catalogId,
        personalMemoId: process.defaults.software.fragranceRef.personalMemoId,
      ),
      rating: rating,
      weepers: weepers,
      nicks: nicks,
      irritation: irritation,
      notes: notes,
    );
  }
}
