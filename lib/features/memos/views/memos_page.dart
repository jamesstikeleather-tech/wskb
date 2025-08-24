import 'package:flutter/material.dart';
import '../../../app/env.dart';
import '../data/personal_memo_repository.dart';
import '../data/memory_personal_memo_repository.dart';
import '../data/firestore_personal_memo_repository.dart';
import '../models/personal_memo_entry.dart';

class MemosPage extends StatefulWidget {
  final String ownerUserId;
  const MemosPage({super.key, required this.ownerUserId});

  @override
  State<MemosPage> createState() => _MemosPageState();
}

class _MemosPageState extends State<MemosPage> {
  late final PersonalMemoRepository repo;

  @override
  void initState() {
    super.initState();
    repo = useFirestore
        ? FirestorePersonalMemoRepository(widget.ownerUserId)
        : MemoryPersonalMemoRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Memos')),
      body: StreamBuilder<List<PersonalMemoEntry>>(
        stream: repo.watchAll(ownerUserId: widget.ownerUserId),
        builder: (context, snap) {
          final items = snap.data ?? const <PersonalMemoEntry>[];
          if (items.isEmpty) {
            return const Center(child: Text('No personal memos yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final m = items[i];
              return ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: Text(m.name),
                subtitle: Text(
                  'Type: ${m.entityType.name} — Status: ${m.status.name}'
                  '${m.canonicalEntityId != null ? '\nLinked: ${m.canonicalEntityId}' : ''}',
                ),
                isThreeLine: m.canonicalEntityId != null,
              );
            },
          );
        },
      ),
    );
  }
}
