import 'package:flutter/material.dart';
import '../../repos/personal_process_repo.dart';
import '../../models/personal_process.dart';
import 'process_editor_page.dart';

class ProcessListPage extends StatelessWidget {
  final PersonalProcessRepo repo;
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
            MaterialPageRoute(builder: (_) => ProcessEditorPage(repo: repo)),
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
          if (items.isEmpty) return const Center(child: Text('No processes yet'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              final subtitleBits = <String>[];
              if (p.passPlan.isNotEmpty) {
                subtitleBits.add('${p.passPlan.length} pass${p.passPlan.length == 1 ? '' : 'es'}');
              }
              if (p.isFavorite) subtitleBits.add('★ favorite');

              return ListTile(
                title: Text(p.name),
                subtitle: subtitleBits.isEmpty ? null : Text(subtitleBits.join(' • ')),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProcessEditorPage(repo: repo, initial: p)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
