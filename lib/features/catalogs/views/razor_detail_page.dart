import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/env.dart';
import '../models/razor.dart';
import '../data/razor_repository.dart';
import '../data/memory_razor_repository.dart';
import '../data/firestore_razor_repository.dart';

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
                  Chip(label: Text(r.razorType.name)),
                  if (r.brandId != null)
                    ActionChip(
                      label: const Text('View Brand'),
                      onPressed: () => context.push('/brand/${r.brandId}'),
                    ),
                ],
              ),

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
            ],
          );
        },
      ),
    );
  }
}

class _SpecsTable extends StatelessWidget {
  final Map<String, dynamic> specs;
  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final entries = specs.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
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
