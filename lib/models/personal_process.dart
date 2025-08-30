// lib/models/personal_process.dart
// WSKB v2.2 — Personal Process Inventory models
// Pure Dart models with toMap/fromMap for Firestore JSON.

import 'dart:convert';

enum LatherStyle { bowl, face, hand }
enum PassDirection { WTG, XTG, ATG }
enum RinseTemp { cold, cool, tepid, warm, hot }

class ProductRef {
  final String? catalogId;
  final String? personalMemoId;

  const ProductRef({this.catalogId, this.personalMemoId});

  Map<String, dynamic> toMap() => {
        'catalogId': catalogId,
        'personalMemoId': personalMemoId,
      };

  factory ProductRef.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ProductRef();
    return ProductRef(
      catalogId: map['catalogId'] as String?,
      personalMemoId: map['personalMemoId'] as String?,
    );
  }
}

class PrepDefaults {
  final bool? shower;
  final ProductRef preShaveProductRef;
  final String? notes;

  const PrepDefaults({
    this.shower,
    this.preShaveProductRef = const ProductRef(),
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'shower': shower,
        'preShaveProductRef': preShaveProductRef.toMap(),
        'notes': notes,
      };

  factory PrepDefaults.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PrepDefaults();
    return PrepDefaults(
      shower: map['shower'] as bool?,
      preShaveProductRef: ProductRef.fromMap(map['preShaveProductRef'] as Map<String, dynamic>?),
      notes: map['notes'] as String?,
    );
  }
}

class LatherDefaults {
  final LatherStyle? style;
  final ProductRef brushPreferenceRef;
  final String? waterAdjustment;

  const LatherDefaults({
    this.style,
    this.brushPreferenceRef = const ProductRef(),
    this.waterAdjustment,
  });

  Map<String, dynamic> toMap() => {
        'style': style?.name,
        'brushPreferenceRef': brushPreferenceRef.toMap(),
        'waterAdjustment': waterAdjustment,
      };

  factory LatherDefaults.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const LatherDefaults();
    final styleStr = map['style'] as String?;
    return LatherDefaults(
      style: styleStr == null ? null : LatherStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => LatherStyle.bowl),
      brushPreferenceRef: ProductRef.fromMap(map['brushPreferenceRef'] as Map<String, dynamic>?),
      waterAdjustment: map['waterAdjustment'] as String?,
    );
  }
}

class SoftwareDefaults {
  final ProductRef soapRef;
  final ProductRef aftershaveRef;
  final ProductRef fragranceRef;

  const SoftwareDefaults({
    this.soapRef = const ProductRef(),
    this.aftershaveRef = const ProductRef(),
    this.fragranceRef = const ProductRef(),
  });

  Map<String, dynamic> toMap() => {
        'soapRef': soapRef.toMap(),
        'aftershaveRef': aftershaveRef.toMap(),
        'fragranceRef': fragranceRef.toMap(),
      };

  factory SoftwareDefaults.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SoftwareDefaults();
    return SoftwareDefaults(
      soapRef: ProductRef.fromMap(map['soapRef'] as Map<String, dynamic>?),
      aftershaveRef: ProductRef.fromMap(map['aftershaveRef'] as Map<String, dynamic>?),
      fragranceRef: ProductRef.fromMap(map['fragranceRef'] as Map<String, dynamic>?),
    );
  }
}

class PostDefaults {
  final bool? alum;
  final RinseTemp? rinseTemp;
  final ProductRef tonerRef;
  final ProductRef balmRef;
  final String? notes;

  const PostDefaults({
    this.alum,
    this.rinseTemp,
    this.tonerRef = const ProductRef(),
    this.balmRef = const ProductRef(),
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'alum': alum,
        'rinseTemp': rinseTemp?.name,
        'tonerRef': tonerRef.toMap(),
        'balmRef': balmRef.toMap(),
        'notes': notes,
      };

  factory PostDefaults.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PostDefaults();
    final tempStr = map['rinseTemp'] as String?;
    return PostDefaults(
      alum: map['alum'] as bool?,
      rinseTemp: tempStr == null ? null : RinseTemp.values.firstWhere((e) => e.name == tempStr, orElse: () => RinseTemp.cool),
      tonerRef: ProductRef.fromMap(map['tonerRef'] as Map<String, dynamic>?),
      balmRef: ProductRef.fromMap(map['balmRef'] as Map<String, dynamic>?),
      notes: map['notes'] as String?,
    );
  }
}

class RazorSetting {
  final String? plate;
  final String? adjustableSetting;

  const RazorSetting({this.plate, this.adjustableSetting});

  Map<String, dynamic> toMap() => {
        'plate': plate,
        'adjustableSetting': adjustableSetting,
      };

  factory RazorSetting.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const RazorSetting();
    return RazorSetting(
      plate: map['plate'] as String?,
      adjustableSetting: map['adjustableSetting'] as String?,
    );
  }
}

class PassPlan {
  final int order; // 1=WTG, 2=XTG, 3=ATG typical
  final PassDirection direction;
  final String? areas;
  final RazorSetting razorSetting;
  final String? angleCue;
  final String? pressureCue;

  const PassPlan({
    required this.order,
    required this.direction,
    this.areas,
    this.razorSetting = const RazorSetting(),
    this.angleCue,
    this.pressureCue,
  });

  Map<String, dynamic> toMap() => {
        'order': order,
        'direction': direction.name,
        'areas': areas,
        'razorSetting': razorSetting.toMap(),
        'angleCue': angleCue,
        'pressureCue': pressureCue,
      };

  factory PassPlan.fromMap(Map<String, dynamic> map) {
    final dirStr = map['direction'] as String? ?? 'WTG';
    return PassPlan(
      order: (map['order'] as num?)?.toInt() ?? 1,
      direction: PassDirection.values.firstWhere((e) => e.name == dirStr, orElse: () => PassDirection.WTG),
      areas: map['areas'] as String?,
      razorSetting: RazorSetting.fromMap(map['razorSetting'] as Map<String, dynamic>?),
      angleCue: map['angleCue'] as String?,
      pressureCue: map['pressureCue'] as String?,
    );
  }
}

class ProcessDefaults {
  final PrepDefaults prep;
  final LatherDefaults lather;
  final ProductRef razorRef;
  final ProductRef bladeRef;
  final SoftwareDefaults software;
  final PostDefaults post;

  const ProcessDefaults({
    this.prep = const PrepDefaults(),
    this.lather = const LatherDefaults(),
    this.razorRef = const ProductRef(),
    this.bladeRef = const ProductRef(),
    this.software = const SoftwareDefaults(),
    this.post = const PostDefaults(),
  });

  Map<String, dynamic> toMap() => {
        'prep': prep.toMap(),
        'lather': lather.toMap(),
        'razorRef': razorRef.toMap(),
        'bladeRef': bladeRef.toMap(),
        'software': software.toMap(),
        'post': post.toMap(),
      };

  factory ProcessDefaults.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ProcessDefaults();
    return ProcessDefaults(
      prep: PrepDefaults.fromMap(map['prep'] as Map<String, dynamic>?),
      lather: LatherDefaults.fromMap(map['lather'] as Map<String, dynamic>?),
      razorRef: ProductRef.fromMap(map['razorRef'] as Map<String, dynamic>?),
      bladeRef: ProductRef.fromMap(map['bladeRef'] as Map<String, dynamic>?),
      software: SoftwareDefaults.fromMap(map['software'] as Map<String, dynamic>?),
      post: PostDefaults.fromMap(map['post'] as Map<String, dynamic>?),
    );
  }
}

class PersonalProcess {
  final String id;
  final int schemaVersion;
  final String ownerUserId;
  final String name;
  final String? description;
  final List<String> tags;
  final List<String> useCases;
  final int? timeEstimateMin;
  final bool isActive;
  final bool isFavorite;
  final ProcessDefaults defaults;
  final List<PassPlan> passPlan;

  const PersonalProcess({
    required this.id,
    required this.schemaVersion,
    required this.ownerUserId,
    required this.name,
    this.description,
    this.tags = const [],
    this.useCases = const [],
    this.timeEstimateMin,
    this.isActive = true,
    this.isFavorite = false,
    this.defaults = const ProcessDefaults(),
    this.passPlan = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'schemaVersion': schemaVersion,
        'ownerUserId': ownerUserId,
        'name': name,
        'name_lc': name.toLowerCase(),
        'description': description,
        'tags': tags,
        'useCases': useCases,
        'timeEstimate_min': timeEstimateMin,
        'isActive': isActive,
        'isFavorite': isFavorite,
        'defaults': defaults.toMap(),
        'passPlan': passPlan.map((p) => p.toMap()).toList(),
        'limits': {'maxTemplates': 12},
      };

  factory PersonalProcess.fromMap(Map<String, dynamic> map) {
    return PersonalProcess(
      id: map['id'] as String? ?? '',
      schemaVersion: (map['schemaVersion'] as num?)?.toInt() ?? 1,
      ownerUserId: map['ownerUserId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      useCases: (map['useCases'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      timeEstimateMin: (map['timeEstimate_min'] as num?)?.toInt(),
      isActive: map['isActive'] as bool? ?? true,
      isFavorite: map['isFavorite'] as bool? ?? false,
      defaults: ProcessDefaults.fromMap(map['defaults'] as Map<String, dynamic>?),
      passPlan: (map['passPlan'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((m) => PassPlan.fromMap(m))
          .toList(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory PersonalProcess.fromJson(String s) => PersonalProcess.fromMap(jsonDecode(s) as Map<String, dynamic>);

  PersonalProcess copyWith({
    String? id,
    int? schemaVersion,
    String? ownerUserId,
    String? name,
    String? description,
    List<String>? tags,
    List<String>? useCases,
    int? timeEstimateMin,
    bool? isActive,
    bool? isFavorite,
    ProcessDefaults? defaults,
    List<PassPlan>? passPlan,
  }) {
    return PersonalProcess(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      useCases: useCases ?? this.useCases,
      timeEstimateMin: timeEstimateMin ?? this.timeEstimateMin,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      defaults: defaults ?? this.defaults,
      passPlan: passPlan ?? this.passPlan,
    );
  }
}
