// lib/features/catalogs/views/razors_page.dart
import 'package:flutter/material.dart';


import '../../../app/env.dart';
import '../models/razor.dart';
import '../data/razor_repository.dart';
import '../data/memory_razor_repository.dart';
import '../data/firestore_razor_repository.dart';

class RazorsPage extends StatefulWidget {
  const RazorsPage({super.key});

  @override
  State<RazorsPage> createState() => _RazorsPageState();
}

class _RazorsPageState extends State<RazorsPage> {
  late final RazorRepository repo;
  RazorType? filter; // null = All

  @override
  void initState() {
    super.initState();
    repo = useFirestore ? FirestoreRazorRepository() : MemoryRazorRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razors'),
        actions: [
          PopupMenuButton<RazorType?>(
            tooltip: 'Filter',
            onSelected: (v) => setState(() => filter = v),
            itemBuilder: (_) => <PopupMenuEntry<RazorType?>>[
              const PopupMenuItem(value: null, child: Text('All')),
              ...RazorType.values.map((t) => PopupMenuItem(value: t, child: Text(t.name))),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: StreamBuilder<List<Razor>>(
        stream: repo.watchAll(typeFilter: filter),
        builder: (context, snap) {
          final items = snap.data ?? const <Razor>[];
          if (items.isEmpty) {
            return const Center(child: Text('No razors'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = items[i];
              return ListTile(
                leading: const Icon(Icons.safety_divider),
                title: Text(r.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: [Chip(label: Text(r.razorType.name))],
                    ),
                    if (r.aliases.isNotEmpty) const SizedBox(height: 4),
                    if (r.aliases.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: r.aliases
                            .map((a) => Chip(label: Text(a), visualDensity: VisualDensity.compact))
                            .toList(),
                      ),
                  ],
                ),
                onTap: () {
                  // later: push to Razor detail page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Razor: ${r.name}')),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: useFirestore
          ? null
          : FloatingActionButton(
              heroTag: 'fab-razors',
              onPressed: () async {
                final id = DateTime.now().microsecondsSinceEpoch.toString();
                await repo.add(Razor(
                  id: id,
                  name: 'Sample Razor $id',
                  razorType: RazorType.other,
                  aliases: const [],
                ));
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
