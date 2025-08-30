// lib/features/diary/views/process_list_page.dart
import 'package:flutter/material.dart';

import '../../diary/data/personal_process_repository.dart';
import '../../../models/personal_process.dart';
import 'process_editor_page.dart';

class ProcessListPage extends StatelessWidget {
  final PersonalProcessRepository repo;
  const ProcessListPage({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Processes')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProcessEditorPage(repo: repo),
            ),
          );
          if (created != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Process saved')),
            );
          }
        },
      ),
      body: StreamBuilder<List<PersonalProcess>>(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No processes yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = items[i];
              final meta = <String>[];
              if (p.passPlan.isNotEmpty) {
                meta.add('${p.passPlan.length} pass${p.passPlan.length == 1 ? '' : 'es'}');
              }
              if (p.isFavorite) meta.add('★ favorite');
              if (!p.isActive) meta.add('inactive');

              return ListTile(
                title: Text(p.name),
                subtitle: meta.isEmpty ? null : Text(meta.join(' • ')),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProcessEditorPage(repo: repo, initial: p),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => repo.delete(p.id),
                  tooltip: 'Delete',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
