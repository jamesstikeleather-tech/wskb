// lib/features/catalogs/models/alias_utils.dart
String normalizeName(String s) {
  var out = s.toLowerCase().trim();
  out = out.replaceAll(RegExp(r'[_\-]+'), ' '); // hyphens/underscores → space
  out = out.replaceAll(RegExp(r'\s+'), ' ');   // collapse spaces
  return out;
}

/// Returns true if `query` matches the canonical name or any alias.
bool matchesByNameOrAlias({
  required String query,
  required String name,
  required List<String> aliases,
}) {
  final q = normalizeName(query);
  if (normalizeName(name) == q) return true;
  for (final a in aliases) {
    if (normalizeName(a) == q) return true;
  }
  return false;
}
