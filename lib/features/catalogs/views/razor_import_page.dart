import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/env.dart';
import '../models/razor.dart';
import '../data/razor_repository.dart';
import '../data/memory_razor_repository.dart';
import '../data/firestore_razor_repository.dart';

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
  // Trim and unquote outer quotes
  return out.map((s) {
    final t = s.trim();
    return (t.startsWith('"') && t.endsWith('"') && t.length >= 2)
        ? t.substring(1, t.length - 1)
        : t;
  }).toList();
}


class RazorImportPage extends StatefulWidget {
  const RazorImportPage({super.key});

  @override
  State<RazorImportPage> createState() => _RazorImportPageState();
}

class _RazorImportPageState extends State<RazorImportPage> {
  late final RazorRepository repo;
  final _csvCtrl = TextEditingController();
  List<_ParsedRow> _preview = const [];
  List<String> _errors = const [];

  @override
  void initState() {
    super.initState();
    repo = useFirestore ? FirestoreRazorRepository() : MemoryRazorRepository();

    // Example header to guide formatting (you can delete this placeholder later)
    _csvCtrl.text = [
      'name,razorType,form,brandId,aliases,specs.grind,specs.width_in,specs_json',
      'Dovo Bismarck,straight,straightFolding,brand_dovo,Bismarck,full_hollow,6/8,',
      'Rockwell 6S,safety,de,brand_rockwell,6S,,,{"plates":[{"name":"R1","barTypes":["SB"],"gap_mm":0.20,"exposure":"mild"}]}',
      'OneBlade Core,safety,seFhs10,brand_oneblade,Core,,,{"barTypes":["SB"],"bladeFormat":"FHS-10"}',
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
                            'name,razorType,form,brandId,aliases,specs.grind,specs.width_in,specs_json\n...',
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
        await repo.add(row.razor);
        ok++;
      } catch (e, st) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Import error: $e\n$st');
        }
        fail++;
      }
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text('Imported: $ok  •  Failed: $fail')),
    );
  }
}

/// Parsed row holder
class _ParsedRow {
  final Razor razor;
  final String? error;
  _ParsedRow(this.razor, this.error);
}

class _ParseResult {
  final List<_ParsedRow> rows;
  final List<String> errors;
  _ParseResult(this.rows, this.errors);
}

/// Very simple CSV parser:
/// - Comma-separated
/// - No embedded commas or quotes
/// - `aliases` split by `;`
/// - Any column starting with `specs.` becomes a nested `specs[key]`
/// - Optional `specs_json` (raw JSON) is merged into `specs`
/// Columns we expect at minimum: name, razorType

String _sanitizeJsonCandidate(String s) {
  var t = s.trim();

  // Excel/Notion sometimes wrap JSON like ="{...}"
  if (t.startsWith('="{') && t.endsWith('}"')) {
    t = t.substring(2, t.length - 1);
  }

  // Replace smart quotes with normal quotes
  t = t
      .replaceAll('\u201C', '"') // left  “
      .replaceAll('\u201D', '"') // right ”
      .replaceAll('\u2018', "'") // left  ‘
      .replaceAll('\u2019', "'"); // right ’

  // If outer quotes remain, strip them
  if (t.length >= 2 && ((t.startsWith('"') && t.endsWith('"')) || (t.startsWith("'") && t.endsWith("'")))) {
    t = t.substring(1, t.length - 1);
  }
  return t;
}

String _json5ishToJson(String s) {
  var t = s.trim();

  // Convert single quotes to double quotes
  t = t.replaceAll("'", '"');

  // Quote unquoted object keys:  { key: ... } or , key: ...
  t = t.replaceAllMapped(
    RegExp(r'([{\[,]\s*)([A-Za-z_][A-Za-z0-9_]*)(\s*:)'),
    (m) => '${m[1]}"${m[2]}"${m[3]}',
  );

  // Quote bareword values after ':' (but keep true/false/null and numbers)
  t = t.replaceAllMapped(
    RegExp(r'(:\s*)([A-Za-z_][A-Za-z0-9_\-\/]+)(\s*)(?=,|}|])'),
    (m) {
      final v = m[2];
      if (v == 'true' || v == 'false' || v == 'null') return '${m[1]}$v';
      return '${m[1]}"$v"';
    },
  );

  // Quote barewords inside arrays: [SB, OC] -> ["SB","OC"]
  t = t.replaceAllMapped(
    RegExp(r'([\[,]\s*)([A-Za-z_][A-Za-z0-9_\-\/]+)(\s*)(?=,|\])'),
    (m) => '${m[1]}"${m[2]}"',
  );

  return t;
}


_ParseResult _parseCsv(String text) {
  final errors = <String>[];
  final rows = <_ParsedRow>[];

  // Normalize newlines and trim
  // Normalize newlines and trim
final lines = const LineSplitter().convert(text.replaceAll('\r', '').trim());
if (lines.isEmpty) return _ParseResult(rows, ['No lines found']);

// Strip BOM if present
final raw0 = lines.first.replaceFirst('\uFEFF', '');
final headers = _splitCsvLine(raw0).map((h) => h.trim()).toList();
final specsIdx = headers.indexOf('specs_json');

Map<String, String> mapRow(List<String> cols) {
  final m = <String, String>{};
  for (var i = 0; i < headers.length; i++) {
    m[headers[i]] = i < cols.length ? cols[i].trim() : '';
  }
  // If specs_json exists and the row had extra commas (unquoted JSON),
  // join the remainder of the columns back into specs_json.
  if (specsIdx != -1 && cols.length > specsIdx) {
    final joined = cols.sublist(specsIdx).join(',');
    m['specs_json'] = joined.trim();
  }
  return m;
}

for (var i = 1; i < lines.length; i++) {
  final raw = lines[i].trim();
  if (raw.isEmpty) continue;

  final cols = _splitCsvLine(raw);  // 👈 robust split
  final m = mapRow(cols);
  // ... rest of your existing parsing stays the same


    try {
      final name = m['name'] ?? '';
      final typeStr = (m['razorType'] ?? '').trim();
      if (name.isEmpty || typeStr.isEmpty) {
        throw 'Missing required "name" or "razorType"';
      }

      final rType = RazorType.values.byName(typeStr);

      // Optional: form
      RazorForm? form;
      final formStr = (m['form'] ?? '').trim();
      if (formStr.isNotEmpty) {
        form = _parseFormCompat(formStr);
      }

      // Optional: brandId
      final brandId = (m['brandId'] ?? '').isNotEmpty ? m['brandId'] : null;

      // Aliases
      final aliasesStr = (m['aliases'] ?? '').trim();
      final aliases = aliasesStr.isEmpty
          ? const <String>[]
          : aliasesStr.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      // Specs
      final specs = <String, dynamic>{};

      // Collect specs.* columns
      for (final h in headers) {
        if (h.startsWith('specs.') && (m[h]?.isNotEmpty ?? false)) {
          final key = h.substring('specs.'.length);
          final val = m[h]!;
          // try to parse numbers/bools minimally
          final parsed = _smart(val);
          specs[key] = parsed;
        }
      }

// Merge specs_json if present (accepts raw JSON or JSON-ish)
final rawSpecsJson = (m['specs_json'] ?? '');
final normalized = _sanitizeJsonCandidate(rawSpecsJson); // keep your existing sanitizer
if (normalized.isNotEmpty) {
  try {
    final Map<String, dynamic> j = jsonDecode(normalized);
    specs.addAll(j);
  } catch (_) {
    // Try JSON-ish -> JSON conversion
    final converted = _json5ishToJson(normalized);
    try {
      final Map<String, dynamic> j2 = jsonDecode(converted);
      specs.addAll(j2);
    } catch (e) {
      final preview = normalized.length > 60 ? '${normalized.substring(0, 60)}…' : normalized;
      throw 'Invalid specs_json at line ${i + 1}: $e  |  value starts: $preview';
    }
  }
}


      // ID: slug + timestamp to avoid collisions
      final id = '${_slug(name)}_${DateTime.now().microsecondsSinceEpoch}';

      final razor = Razor(
        id: id,
        name: name,
        razorType: rType,
        form: form,
        brandId: brandId,
        aliases: aliases,
        specs: specs,
      );

      rows.add(_ParsedRow(razor, null));
    } catch (e) {
      errors.add('Line ${i + 1}: $e');
    }
  }

  return _ParseResult(rows, errors);
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
  // try exact
  for (final v in RazorForm.values) {
    if (v.name == raw) return v;
  }
  // snake_case -> lowerCamel
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
