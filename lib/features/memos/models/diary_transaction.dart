// lib/features/memos/models/diary_transaction.dart
import 'dart:convert';

/// A simple Likert scale used across diary outcomes.
enum Likert5 { none, low, medium, high, extreme }

/// How the lather was built for the shave.
enum LatherMethod { bowl, face, palm, other }

/// Transaction type, if you later decide to store diffs/events.
/// For now, most entries will be `entry`.
enum DiaryTxnKind { entry, edit, delete }

/// A “transaction” = one atomic diary record capturing a shave and its outcomes.
/// Keep it flat & reference IDs for catalogs/inventory to avoid duplication.
class DiaryTransaction {
  final String id; // UUID
  final DateTime occurredAt; // when the shave happened
  final String userId;

  final DiaryTxnKind kind;

  // References to items used (prefer inventory IDs; fallback to catalog IDs if needed)
  final String? razorHeadId;
  final String? razorHandleId;
  final String? straightRazorId;

  final String? bladeId;
  final String? brushHandleId;
  final String? brushKnotId;

  final String? soapId; // or cream/croap (unified as "soapId" for now)
  final String? preShaveId;
  final String? aftershaveId;
  final String? fragranceId;

  // Environment & technique
  final bool showerBefore;
  final LatherMethod latherMethod;
  final int passCount; // WTG/XTG/ATG count (0–5 typical)
  final bool headShave; // if true, includes head; else face-only (or vice versa per your usage)

  // Outcomes
  final Likert5 closeness;        // perceived closeness
  final Likert5 irritation;       // overall irritation
  final Likert5 alumFeedback;     // sting intensity
  final int weepers;              // small bleeds
  final int nicks;                // larger cuts
  final bool bbsAchieved;         // baby-butt smooth yes/no
  final Likert5 postShaveFeel;    // skin feel after
  final Likert5 overallSatisfaction;

  // Extra data
  final String? notes;
  final Map<String, dynamic> extra; // extensibility: humidity, waterHardness, etc.

  const DiaryTransaction({
    required this.id,
    required this.occurredAt,
    required this.userId,
    this.kind = DiaryTxnKind.entry,
    this.razorHeadId,
    this.razorHandleId,
    this.straightRazorId,
    this.bladeId,
    this.brushHandleId,
    this.brushKnotId,
    this.soapId,
    this.preShaveId,
    this.aftershaveId,
    this.fragranceId,
    this.showerBefore = false,
    this.latherMethod = LatherMethod.bowl,
    this.passCount = 3,
    this.headShave = false,
    this.closeness = Likert5.medium,
    this.irritation = Likert5.none,
    this.alumFeedback = Likert5.none,
    this.weepers = 0,
    this.nicks = 0,
    this.bbsAchieved = false,
    this.postShaveFeel = Likert5.medium,
    this.overallSatisfaction = Likert5.medium,
    this.notes,
    this.extra = const {},
  });

  DiaryTransaction copyWith({
    String? id,
    DateTime? occurredAt,
    String? userId,
    DiaryTxnKind? kind,
    String? razorHeadId,
    String? razorHandleId,
    String? straightRazorId,
    String? bladeId,
    String? brushHandleId,
    String? brushKnotId,
    String? soapId,
    String? preShaveId,
    String? aftershaveId,
    String? fragranceId,
    bool? showerBefore,
    LatherMethod? latherMethod,
    int? passCount,
    bool? headShave,
    Likert5? closeness,
    Likert5? irritation,
    Likert5? alumFeedback,
    int? weepers,
    int? nicks,
    bool? bbsAchieved,
    Likert5? postShaveFeel,
    Likert5? overallSatisfaction,
    String? notes,
    Map<String, dynamic>? extra,
  }) {
    return DiaryTransaction(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      razorHeadId: razorHeadId ?? this.razorHeadId,
      razorHandleId: razorHandleId ?? this.razorHandleId,
      straightRazorId: straightRazorId ?? this.straightRazorId,
      bladeId: bladeId ?? this.bladeId,
      brushHandleId: brushHandleId ?? this.brushHandleId,
      brushKnotId: brushKnotId ?? this.brushKnotId,
      soapId: soapId ?? this.soapId,
      preShaveId: preShaveId ?? this.preShaveId,
      aftershaveId: aftershaveId ?? this.aftershaveId,
      fragranceId: fragranceId ?? this.fragranceId,
      showerBefore: showerBefore ?? this.showerBefore,
      latherMethod: latherMethod ?? this.latherMethod,
      passCount: passCount ?? this.passCount,
      headShave: headShave ?? this.headShave,
      closeness: closeness ?? this.closeness,
      irritation: irritation ?? this.irritation,
      alumFeedback: alumFeedback ?? this.alumFeedback,
      weepers: weepers ?? this.weepers,
      nicks: nicks ?? this.nicks,
      bbsAchieved: bbsAchieved ?? this.bbsAchieved,
      postShaveFeel: postShaveFeel ?? this.postShaveFeel,
      overallSatisfaction: overallSatisfaction ?? this.overallSatisfaction,
      notes: notes ?? this.notes,
      extra: extra ?? Map<String, dynamic>.from(this.extra),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'occurredAt': occurredAt.toIso8601String(),
        'userId': userId,
        'kind': kind.name,
        'razorHeadId': razorHeadId,
        'razorHandleId': razorHandleId,
        'straightRazorId': straightRazorId,
        'bladeId': bladeId,
        'brushHandleId': brushHandleId,
        'brushKnotId': brushKnotId,
        'soapId': soapId,
        'preShaveId': preShaveId,
        'aftershaveId': aftershaveId,
        'fragranceId': fragranceId,
        'showerBefore': showerBefore,
        'latherMethod': latherMethod.name,
        'passCount': passCount,
        'headShave': headShave,
        'closeness': closeness.name,
        'irritation': irritation.name,
        'alumFeedback': alumFeedback.name,
        'weepers': weepers,
        'nicks': nicks,
        'bbsAchieved': bbsAchieved,
        'postShaveFeel': postShaveFeel.name,
        'overallSatisfaction': overallSatisfaction.name,
        'notes': notes,
        'extra': extra,
      };

  factory DiaryTransaction.fromJson(Map<String, dynamic> json) {
    return DiaryTransaction(
      id: json['id'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      userId: json['userId'] as String,
      kind: json['kind'] != null
          ? DiaryTxnKind.values.byName(json['kind'] as String)
          : DiaryTxnKind.entry,
      razorHeadId: json['razorHeadId'] as String?,
      razorHandleId: json['razorHandleId'] as String?,
      straightRazorId: json['straightRazorId'] as String?,
      bladeId: json['bladeId'] as String?,
      brushHandleId: json['brushHandleId'] as String?,
      brushKnotId: json['brushKnotId'] as String?,
      soapId: json['soapId'] as String?,
      preShaveId: json['preShaveId'] as String?,
      aftershaveId: json['aftershaveId'] as String?,
      fragranceId: json['fragranceId'] as String?,
      showerBefore: (json['showerBefore'] as bool?) ?? false,
      latherMethod: json['latherMethod'] != null
          ? LatherMethod.values.byName(json['latherMethod'] as String)
          : LatherMethod.bowl,
      passCount: (json['passCount'] as num?)?.toInt() ?? 3,
      headShave: (json['headShave'] as bool?) ?? false,
      closeness: json['closeness'] != null
          ? Likert5.values.byName(json['closeness'] as String)
          : Likert5.medium,
      irritation: json['irritation'] != null
          ? Likert5.values.byName(json['irritation'] as String)
          : Likert5.none,
      alumFeedback: json['alumFeedback'] != null
          ? Likert5.values.byName(json['alumFeedback'] as String)
          : Likert5.none,
      weepers: (json['weepers'] as num?)?.toInt() ?? 0,
      nicks: (json['nicks'] as num?)?.toInt() ?? 0,
      bbsAchieved: (json['bbsAchieved'] as bool?) ?? false,
      postShaveFeel: json['postShaveFeel'] != null
          ? Likert5.values.byName(json['postShaveFeel'] as String)
          : Likert5.medium,
      overallSatisfaction: json['overallSatisfaction'] != null
          ? Likert5.values.byName(json['overallSatisfaction'] as String)
          : Likert5.medium,
      notes: json['notes'] as String?,
      extra: (json['extra'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );
  }

  String toJsonString() => jsonEncode(toJson());
  factory DiaryTransaction.fromJsonString(String source) =>
      DiaryTransaction.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DiaryTransaction(${jsonEncode(toJson())})';

  @override
  bool operator ==(Object other) => other is DiaryTransaction && other.toJsonString() == toJsonString();

  @override
  int get hashCode => toJsonString().hashCode;
}
