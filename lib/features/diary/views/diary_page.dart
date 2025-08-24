import 'package:flutter/material.dart';

import '../../../app/env.dart';
import '../../memos/models/diary_transaction.dart';
import '../data/diary_repository.dart';
import '../data/memory_diary_repository.dart';
import '../data/firestore_diary_repository.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});
  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late final DiaryRepository repo;

  @override
  void initState() {
    super.initState();
    repo = useFirestore
        ? FirestoreDiaryRepository()
        : MemoryDiaryRepository();
  }

  Future<void> _addEntryDialog() async {
    final formKey = GlobalKey<FormState>();
    Likert5 satisfaction = Likert5.medium;
    String? notes;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Diary Entry'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Likert5>(
                initialValue: satisfaction, // (value is deprecated)
                items: Likert5.values
                    .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
                    .toList(),
                onChanged: (v) => satisfaction = v ?? Likert5.medium,
                decoration: const InputDecoration(labelText: 'Overall Satisfaction'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                onChanged: (v) => notes = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      await repo.add(DiaryTransaction(
        id: id,
        occurredAt: DateTime.now(),
        userId: 'local',
        overallSatisfaction: satisfaction,
        notes: notes,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DiaryTransaction>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <DiaryTransaction>[];
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Diary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('No entries yet'))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final it = items[i];
                            final when = it.occurredAt.toLocal().toString();
                            return ListTile(
                              leading: const Icon(Icons.event_note),
                              title: Text('Satisfaction: ${it.overallSatisfaction.name}'),
                              subtitle: Text('$when${it.notes != null ? "\n${it.notes}" : ""}'),
                              isThreeLine: it.notes != null,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => repo.remove(it.id),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab-diary',
            onPressed: _addEntryDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
