import 'package:flutter/material.dart';

import '../../../app/env.dart';
import '../../inventory/models/inventory_item.dart';
import '../data/inventory_repository.dart';
import '../data/memory_inventory_repository.dart';
import '../data/firestore_inventory_repository.dart';
import '../../memos/utils/type_mapping.dart';


// Personal memo additions
import '../../memos/data/personal_memo_repository.dart';
import '../../memos/data/memory_personal_memo_repository.dart';
import '../../memos/data/firestore_personal_memo_repository.dart';
import '../../memos/models/personal_memo_entry.dart';


class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late final InventoryRepository repo;
  late final PersonalMemoRepository memos;
  final String currentUserId = 'local'; // swap to real auth uid later



  @override
void initState() {
  super.initState();

  // Inventory repository (memory vs Firestore)
  repo = useFirestore
      ? FirestoreInventoryRepository()
      : MemoryInventoryRepository();

  // Personal memos repository (memory vs Firestore)
  memos = useFirestore
      ? FirestorePersonalMemoRepository(currentUserId)
      : MemoryPersonalMemoRepository();
}


  Future<void> _addItemDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    InventoryType type = InventoryType.razor;
    String? notes;
    bool isPersonal = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Inventory Item'),
        content: Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (ctx, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<InventoryType>(
                    initialValue: type, // (value is deprecated)
                    items: InventoryType.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                        .toList(),
                    onChanged: (v) => type = v ?? InventoryType.other,
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    onChanged: (v) => notes = v,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: isPersonal,
                    onChanged: (v) => setInnerState(() => isPersonal = v ?? false),
                    title: const Text('Personal (not in catalog yet)'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      String? personalMemoId;

      if (isPersonal) {
        final memoId = 'pm_$id';
        final now = DateTime.now();
        final memo = PersonalMemoEntry(
          id: memoId,
          ownerUserId: currentUserId,
          entityType: curTypeForInventory(type),
          name: nameCtrl.text.trim(),
          fields: {'inventoryType': type.name},
          status: PersonalMemoStatus.active,
          canonicalEntityId: null,
          createdAt: now,
          updatedAt: now,
        );
        await memos.add(memo);
        personalMemoId = memoId;
      }

      await repo.add(InventoryItem(
        id: id,
        type: type,
        name: nameCtrl.text.trim(),
        notes: notes,
        isPersonal: isPersonal,
        personalMemoId: personalMemoId,
      ));
    }
  }

Future<bool> _confirmDelete(String label) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete item?'),
      content: Text('Are you sure you want to delete $label?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
      ],
    ),
  );
  return result ?? false;
}

void _showUndoSnackBar({
  required String message,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
      duration: const Duration(seconds: 5),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <InventoryItem>[];
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inventory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('No items yet'))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final it = items[i];
                            return ListTile(
                              leading: const Icon(Icons.inventory_2),
                              title: Text(it.name),
                              subtitle: Text(
                                '${it.type.name}'
                                '${it.notes != null ? " — ${it.notes}" : ""}'
                                '${it.isPersonal ? "  (Personal)" : ""}',
                              ),
                              trailing: IconButton(
  icon: const Icon(Icons.delete_outline),
  onPressed: () async {
    final ok = await _confirmDelete('“${it.name}” from Inventory');
    if (!ok) return;

    // Keep a copy for undo.
    final deleted = it;
    await repo.remove(it.id);

    _showUndoSnackBar(
      message: 'Deleted “${deleted.name}”.',
      onUndo: () {
        // Re-add the exact same item (same id).
        repo.add(deleted);
      },
    );
  },
),

                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab-inventory',
            onPressed: _addItemDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
