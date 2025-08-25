import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/env.dart';
import '../models/razor.dart';
import '../data/razor_repository.dart';
import '../data/memory_razor_repository.dart';
import '../data/firestore_razor_repository.dart';
import '../utils/razor_format.dart';

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
          // Filter menu
          PopupMenuButton<RazorType?>(
            tooltip: 'Filter',
            initialValue: filter,
            onSelected: (v) => setState(() => filter = v),
            itemBuilder: (context) => <PopupMenuEntry<RazorType?>>[
              const PopupMenuItem<RazorType?>(value: null, child: Text('All')),
              ...RazorType.values.map(
                (t) => PopupMenuItem<RazorType?>(value: t, child: Text(prettyRazorType(t))),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          // Import CSV button
          IconButton(
            tooltip: 'Import CSV',
            icon: const Icon(Icons.file_upload),
            onPressed: () => context.push('/razors/import'),
          ),
        ],
      ),
      body: StreamBuilder<List<Razor>>(
        stream: repo.watchAll(typeFilter: filter),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Razor>[];
          if (items.isEmpty) {
            return const Center(child: Text('No razors'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = items[index];
              return ListTile(
                leading: const Icon(Icons.safety_divider),
                title: Text(r.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: [
                        Chip(label: Text(prettyRazorType(r.razorType))),
                        if (r.form != null) Chip(label: Text(prettyRazorForm(r.form!))),
                      ],
                    ),
                    if (r.aliases.isNotEmpty) const SizedBox(height: 4),
                    if (r.aliases.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: r.aliases
                            .map(
                              (a) => Chip(
                                label: Text(a),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
                onTap: () => context.push('/razors/${r.id}'),
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
                await repo.add(
                  Razor(
                    id: id,
                    name: 'Sample Razor $id',
                    razorType: RazorType.other,
                    aliases: const [],
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
