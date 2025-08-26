import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../app/env.dart';
import '../models/razor.dart';
import '../data/razor_repository.dart';
import '../data/memory_razor_repository.dart';
import '../data/firestore_razor_repository.dart';

// Maker support
import '../data/maker_repository.dart';
import '../data/memory_maker_repository.dart';

// Brand name -> id mapping
import '../../../data/brand_repository.dart';

class RazorImportPage extends StatefulWidget {
  const RazorImportPage({super.key});

  @override
  State<RazorImportPage> createState() => _RazorImportPageState();
}

class _RazorImportPageState extends State<RazorImportPage> {
  late final RazorRepository repo;
  late final MakerRepository makerRepo;

  final _csvCtrl = TextEditingController();
  List<_ParsedRow> _preview = const [];
  List<String> _errors = const [];

  @override
  void initState() {
    super.initState();
    repo = useFirestore ? FirestoreRazorRepository() : MemoryRazorRepository();
    makerRepo = MemoryMakerRepository(); // Firestore impl later

    // Example CSV (you can clear this)
    _csvCtrl.text = [
      'name,razorType,form,brandId,brandName,aliases,specs.grind,specs.width_in,maker,specs_json',
      'Dovo Bismarck,straight,straightFolding,,DOVO,Bismarck,full_hollow,6/8,DOVO,',
      'Rockwell 6S,safety,de,,Rockwell Razors,6S,,,,{ "plates":[{"name":"R1","barTypes":["SB"],"gap_mm":0.20,"exposure":"mild"}] }',
      'OneBlade Core,safety,seFhs10,,OneBlade,Core,,,,{ "barTypes":["SB"],"bladeFormat":"FHS-10" }',
    ].join('\n');
  }

  @override
  void dispose() {
    _csvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backend = useFirestore ? 'Firestore' : 'Memory';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Razors (CSV)'),
        actions: [
          IconButton(
            tooltip: 'Parse Preview',
            icon: const Icon(Icons.preview),
            onPressed: _parsePreview,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left: CSV input
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Paste CSV — importing into $backend',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _csvCtrl,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'name,razorType,form,brandId,brandName,aliases,specs.grind,specs.width_in,maker,specs_json\n...',
                      ),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _parsePreview,
                    icon: const Icon(Icons.preview),
                    label: const Text('Parse Preview'),
                  ),
                ],
              ),
            ),
          ),

          // Right: Preview & Import
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Preview', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _errors.isNotEmpty
                      ? Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _errors.map((e) => Text('• $e')).toList(),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _preview.isEmpty
                        ? const Center(child: Text('No parsed rows yet.'))
                        : ListView.separated(
                            itemCount: _preview.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final p = _preview[i];
                              return ListTile(
                                leading: const Icon(Icons.safety_divider),
                                title: Text(p.razor.name),
                                subtitle: Text([
                                  'type=${p.razor.razorType.name}',
                                  if (p.razor.form != null) 'form=${p.razor.form!.name}',
                                  if (p.razor.brandId != null) 'brand=${p.razor.brandId}',
                                  if (p.makerName != null) 'maker=${p.makerName}',
                                  if (p.razor.aliases.isNotEmpty) 'aliases=${p.razor.aliases.length}',
                                  if (p.razor.specs.isNotEmpty) 'specs=${p.razor.specs.keys.length}',
                                ].join(' • ')),
                                trailing: p.error == null
                                    ? const Icon(Icons.check, color: Colors.green)
                                    : const Icon(Icons.error_outline, color: Colors.red),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _preview.isEmpty || _errors.isNotEmpty ? null : _doImport,
                    icon: const Icon(Icons.cloud_upload),
                    label: Text('Import ${_preview.length} razors'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _parsePreview() {
    final text = _csvCtrl.text;
    final result = _parseCsv(text);
    setState(() {
      _preview = result.rows;
      _errors = result.errors;
    });
  }

  Future<void> _doImport() async {
    final messenger = ScaffoldMessenger.of(context);
    int ok = 0, fail = 0;
    for (final row in _preview) {
      if (row.error != null) {
        fail++;
        continue;
      }
      try {
        Razor toSave = row.razor;
        if (row.makerName != null) {
          final makerId = await makerRepo.ensureByName(row.makerName!);
          toSave = toSave.copyWith(makerId: makerId);
        }
        await repo.add(toSave);
        ok++;
      } catch (_) {
        fail++;
      }
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text('Imported: $ok  •  Failed: $fail')),
    );
  }
}

/// ---------- parsing helpers ----------

class _ParsedRow {
  final Razor razor;
  final String? error;
  final String? makerName; // raw maker name from CSV (resolved in _doImport)
  _ParsedRow(this.razor, this.error, {this.makerName});
}

class _ParseResult {
  final List<_ParsedRow> rows;
  final List<String> errors;
  _ParseResult(this.rows, this.errors);
}

List<String> _splitCsvLine(String line) {
  // Handles commas inside double quotes and doubled quotes ("")
  final out = <String>[];
  final buf = StringBuffer();
  bool inQuotes = false;
  for (int i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        buf.write('"'); // escaped quote
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (ch == ',' && !inQuotes) {
      out.add(buf.toString());
      buf.clear();
    } else {
      buf.write(ch);
    }
  }
  out.add(buf.toString());
  return out.map((s) {
    final t = s.trim();
    return (t.startsWith('"') && t.endsWith('"') && t.length >= 2)
        ? t.substring(1, t.length - 1)
        : t;
  }).toList();
}

String _sanitizeJsonCandidate(String s) {
  var t = s.trim();
  if (t.startsWith('="{') && t.endsWith('}"')) {
    t = t.substring(2, t.length - 1);
  }
  t = t
      .replaceAll('\u201C', '"')
      .replaceAll('\u201D', '"')
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'");
  if (t.length >= 2 &&
      ((t.startsWith('"') && t.endsWith('"')) ||
          (t.startsWith("'") && t.endsWith("'")))) {
    t = t.substring(1, t.length - 1);
  }
  return t;
}

String _json5ishToJson(String s) {
  var t = s.trim();
  t = t.replaceAll("'", '"');
  // "{ key: ... }" or ", key: ..."
  t = t.replaceAllMapped(
    RegExp(r'([{\[,]\s*)([A-Za-z_][A-Za-z0-9_]*)(\s*:)'),
    (m) => '${m[1]}"${m[2]}"${m[3]}',
  );
  // values after ':'
  t = t.replaceAllMapped(
    RegExp(r'(:\s*)([A-Za-z_][A-Za-z0-9_\-\/]+)(\s*)(?=,|}|])'),
    (m) {
      final v = m[2];
      if (v == 'true' || v == 'false' || v == 'null') return '${m[1]}$v';
      return '${m[1]}"$v"';
    },
  );
  // values in arrays
  t = t.replaceAllMapped(
    RegExp(r'([\[,]\s*)([A-Za-z_][A-Za-z0-9_\-\/]+)(\s*)(?=,|\])'),
    (m) => '${m[1]}"${m[2]}"',
  );
  return t;
}

dynamic _smart(String s) {
  final lower = s.toLowerCase();
  if (lower == 'true') return true;
  if (lower == 'false') return false;
  final n = num.tryParse(s);
  if (n != null) return n;
  return s;
}

RazorForm _parseFormCompat(String raw) {
  for (final v in RazorForm.values) {
    if (v.name == raw) return v;
  }
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

String _slug(String s) {
  final cleaned = s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return cleaned.isEmpty ? 'razor' : cleaned;
}

_ParseResult _parseCsv(String text) {
  final errors = <String>[];
  final rows = <_ParsedRow>[];

  // Normalize newlines and trim
  final lines = const LineSplitter().convert(text.replaceAll('\r', '').trim());
  if (lines.isEmpty) return _ParseResult(rows, ['No lines found']);

  // Headers
  final raw0 = lines.first.replaceFirst('\uFEFF', '');
  final headers = _splitCsvLine(raw0).map((h) => h.trim()).toList();
  final specsIdx = headers.indexOf('specs_json');

  Map<String, String> mapRow(List<String> cols) {
    final m = <String, String>{};
    for (var i = 0; i < headers.length; i++) {
      m[headers[i]] = i < cols.length ? cols[i].trim() : '';
    }
    // If specs_json is present and unquoted JSON spilled past commas,
    // join the remainder of the row back into specs_json.
    if (specsIdx != -1 && cols.length > specsIdx) {
      m['specs_json'] = cols.sublist(specsIdx).join(',').trim();
    }
    return m;
  }

  for (var i = 1; i < lines.length; i++) {
    final raw = lines[i].trim();
    if (raw.isEmpty) continue;

    final cols = _splitCsvLine(raw);
    final m = mapRow(cols);

    try {
      // Required
      final name = m['name'] ?? '';
      final typeStr = (m['razorType'] ?? '').trim();
      if (name.isEmpty || typeStr.isEmpty) {
        throw 'Missing required "name" or "razorType"';
      }
      final rType = RazorType.values.byName(typeStr); // expects lowercase (e.g., straight)

      // Optional form
      RazorForm? form;
      final formStr = (m['form'] ?? '').trim();
      if (formStr.isNotEmpty) form = _parseRazorFormCompat(formStr);

      // brandId / brandID and/or brandName -> ensure (create if missing)
      String? brandId;
      final brandIdCsv = ((m['brandId'] ?? m['brandID']) ?? '').trim();
      final brandNameCsv = (m['brandName'] ?? '').trim();
      if (brandIdCsv.isNotEmpty || brandNameCsv.isNotEmpty) {
        final derivedId = brandIdCsv.isNotEmpty ? brandIdCsv : 'brand_${_slug(brandNameCsv)}';
        final nameForCreate = brandNameCsv.isNotEmpty ? brandNameCsv : derivedId;
        brandId = BrandRepository().ensure(id: derivedId, name: nameForCreate);
      }

      // Maker (resolve id later in _doImport)
      final makerName = (m['maker'] ?? '').trim();
      final makerNameOpt = makerName.isEmpty ? null : makerName;

      // Aliases (semicolon-separated)
      final aliasesStr = (m['aliases'] ?? '').trim();
      final aliases = aliasesStr.isEmpty
          ? const <String>[]
          : aliasesStr.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      // Specs from columns specs.*
      final specs = <String, dynamic>{};
      for (final h in headers) {
        if (h.startsWith('specs.') && (m[h]?.isNotEmpty ?? false)) {
          final key = h.substring('specs.'.length);
          final val = m[h]!;
          specs[key] = _smart(val);
        }
      }

      // specs_json (raw/quoted/json-ish)
      final rawSpecsJson = (m['specs_json'] ?? '');
      final normalized = _sanitizeJsonCandidate(rawSpecsJson);
      if (normalized.isNotEmpty) {
        try {
          final Map<String, dynamic> j = jsonDecode(normalized);
          specs.addAll(j);
        } catch (_) {
          final converted = _json5ishToJson(normalized);
          final Map<String, dynamic> j2 = jsonDecode(converted);
          specs.addAll(j2);
        }
      }

      // ID
      final id = '${_slug(name)}_${DateTime.now().microsecondsSinceEpoch}';

      // Build row (makerId resolved later)
      final razor = Razor(
        id: id,
        name: name,
        razorType: rType,
        form: form,
        brandId: brandId,
        makerId: null,
        aliases: aliases,
        specs: specs,
      );

      rows.add(_ParsedRow(razor, null, makerName: makerNameOpt));
    } catch (e) {
      errors.add('Line ${i + 1}: $e');
    }
  }

  return _ParseResult(rows, errors);
}

