import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../../app/env.dart';
import '../models/razor.dart';
import '../data/razor_repository.dart';
import '../data/memory_razor_repository.dart';
import '../data/firestore_razor_repository.dart';
import '../utils/razor_format.dart';

class RazorDetailPage extends StatefulWidget {
  final String id;
  const RazorDetailPage({super.key, required this.id});

  @override
  State<RazorDetailPage> createState() => _RazorDetailPageState();
}

class _RazorDetailPageState extends State<RazorDetailPage> {
  late final RazorRepository repo;

  @override
  void initState() {
    super.initState();
    repo = useFirestore ? FirestoreRazorRepository() : MemoryRazorRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Razor Details')),
      body: StreamBuilder<Razor?>(
        stream: repo.watchOne(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final r = snapshot.data;
// DEBUG
debugPrint('Detail loaded: ${r?.name} with ${r?.images.length ?? 0} images');
// DEBUG

          if (r == null) {
            return const Center(child: Text('Razor not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(r.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(prettyRazorType(r.razorType))),
                  if (r.form != null) Chip(label: Text(prettyRazorForm(r.form!))),
                  if (r.brandId != null)
                    ActionChip(
                      label: const Text('View Brand'),
                      onPressed: () => context.push('/brand/${r.brandId}'),
                    ),
                ],
              ),
              if ((r.specs['barTypes'] is List) &&
                  (r.specs['barTypes'] as List).isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: (r.specs['barTypes'] as List)
                      .map((t) => Chip(label: Text(prettyBarType(t.toString()))))
                      .cast<Widget>()
                      .toList(),
                ),
              ],

// --- IMAGES: begin ---
if (r.images.isNotEmpty) ...[
  const SizedBox(height: 16),
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: r.images.map((p) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(width: 260, child: _RazorImageThumb(p)),
        );
      }).toList(),
    ),
  ),
],
// --- IMAGES: end ---


              if (r.aliases.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Also known as', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: -8,
                  children: r.aliases
                      .map((a) => Chip(label: Text(a), visualDensity: VisualDensity.compact))
                      .toList(),
                ),
              ],
              if (r.specs.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Specs', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _SpecsTable(specs: r.specs),
              ],
              if (r.specs['plates'] is List) ...[
                const SizedBox(height: 16),
                const Text('Plates', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _PlatesTable(
                  plates: (r.specs['plates'] as List).cast<Map<String, dynamic>>(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}


class _RazorImageThumb extends StatelessWidget {
  final String path;
  const _RazorImageThumb(this.path);

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget placeholder(String label) => Container(
          color: bg,
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );

    Widget child;
    if (path.startsWith('asset:')) {
      final p = 'assets/${path.substring(6)}';
      child = Image.asset(
        p,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => placeholder('Asset not found'),
      );
    } else if (path.startsWith('http')) {
      child = Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => placeholder('Image failed to load'),
      );
    } else {
      child = placeholder(path.isEmpty ? 'No preview' : path);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: child,
      ),
    );
  }
}

class _SpecsTable extends StatelessWidget {
  final Map<String, dynamic> specs;
  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final entries = specs.entries
        .where((e) => e.key != 'plates' && e.key != 'barTypes') // shown elsewhere
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: entries.map((e) {
            final v = e.value;
            final text = v is List ? v.join(', ') : '$v';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PlatesTable extends StatelessWidget {
  final List<Map<String, dynamic>> plates;
  const _PlatesTable({required this.plates});

  @override
  Widget build(BuildContext context) {
    final rows = plates.map((p) {
      final name = p['name'] ?? '';
      final barTypes = (p['barTypes'] as List?)?.cast<String>();
      final barLabel = (barTypes != null && barTypes.isNotEmpty)
          ? barTypes.map(prettyBarType).join(' + ')
          : (p['guard'] ?? ''); // legacy fallback
      final gap = p['gap_mm'];
      final exposure = p['exposure'] ?? '';
      final gapStr = (gap is num) ? '${gap.toStringAsFixed(2)} mm' : (gap?.toString() ?? '');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Text('$name', style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 12),
            SizedBox(width: 120, child: Text(barLabel)),
            const SizedBox(width: 12),
            SizedBox(width: 80, child: Text(gapStr)),
            const SizedBox(width: 12),
            Expanded(child: Text('$exposure')),
          ],
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: const [
                SizedBox(width: 64, child: Text('Plate', style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 12),
                SizedBox(width: 120, child: Text('Bar(s)', style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 12),
                SizedBox(width: 80, child: Text('Gap', style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 12),
                Expanded(child: Text('Exposure', style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }
}
