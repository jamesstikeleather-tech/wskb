import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../repos/personal_process_repo.dart';
import '../../models/personal_process.dart';

class ProcessEditorPage extends StatefulWidget {
  final PersonalProcessRepo repo;
  final PersonalProcess? initial;
  const ProcessEditorPage({super.key, required this.repo, this.initial});

  @override
  State<ProcessEditorPage> createState() => _ProcessEditorPageState();
}

class _ProcessEditorPageState extends State<ProcessEditorPage> {
  final _uuid = const Uuid();
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _tags;
  late TextEditingController _useCases;
  bool _isActive = true;
  bool _isFavorite = false;

  // We’ll keep PassPlan editing simple: list + add/remove + reorder
  late List<PassPlan> _passes;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _tags = TextEditingController(text: (p?.tags ?? const []).join(', '));
    _useCases = TextEditingController(text: (p?.useCases ?? const []).join(', '));
    _isActive = p?.isActive ?? true;
    _isFavorite = p?.isFavorite ?? false;
    _passes = List.of(p?.passPlan ?? const []);
  }

  void _addPass() {
    final nextOrder = _passes.isEmpty ? 1 : (_passes.map((e) => e.order).reduce((a,b) => a > b ? a : b) + 1);
    setState(() {
      _passes.add(PassPlan(
        order: nextOrder,
        direction: PassDirection.WTG,
        areas: null,
        razorSetting: const RazorSetting(),
        angleCue: null,
        pressureCue: null,
      ));
    });
  }

  void _save() {
    List<String> _splitCsv(String s) =>
        s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final updated = PersonalProcess(
      id: widget.initial?.id ?? '',
      schemaVersion: widget.initial?.schemaVersion ?? 1,
      ownerUserId: widget.initial?.ownerUserId ?? 'local-demo', // replace with auth uid when ready
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      tags: _splitCsv(_tags.text),
      useCases: _splitCsv(_useCases.text),
      timeEstimateMin: widget.initial?.timeEstimateMin,
      isActive: _isActive,
      isFavorite: _isFavorite,
      defaults: widget.initial?.defaults ?? const ProcessDefaults(),
      passPlan: _passes
        ..sort((a, b) => a.order.compareTo(b.order)),
    );

    final saved = widget.repo.upsert(updated);
    if (mounted) Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'New Process' : 'Edit Process'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 8),
          TextField(controller: _tags, decoration: const InputDecoration(labelText: 'Tags (comma-separated)')),
          const SizedBox(height: 8),
          TextField(controller: _useCases, decoration: const InputDecoration(labelText: 'Use cases (comma-separated)')),
          const SizedBox(height: 8),
          SwitchListTile(value: _isActive, onChanged: (v) => setState(() => _isActive = v), title: const Text('Active')),
          SwitchListTile(value: _isFavorite, onChanged: (v) => setState(() => _isFavorite = v), title: const Text('Favorite')),

          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Pass plan', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(onPressed: _addPass, icon: const Icon(Icons.add), label: const Text('Add pass')),
          ]),

          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _passes.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _passes.removeAt(oldIndex);
                _passes.insert(newIndex, item);
                // resequence orders
                for (var i = 0; i < _passes.length; i++) {
                  _passes[i] = PassPlan(
                    order: i + 1,
                    direction: _passes[i].direction,
                    areas: _passes[i].areas,
                    razorSetting: _passes[i].razorSetting,
                    angleCue: _passes[i].angleCue,
                    pressureCue: _passes[i].pressureCue,
                  );
                }
              });
            },
            itemBuilder: (_, i) {
              final p = _passes[i];
              return Card(
                key: ValueKey('pass_${p.order}_${_uuid.v4()}'),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Row(children: [
                      Text('Pass ${p.order}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() => _passes.removeAt(i)),
                      ),
                    ]),
                    DropdownButtonFormField<PassDirection>(
                      value: p.direction,
                      decoration: const InputDecoration(labelText: 'Direction'),
                      items: PassDirection.values.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _passes[i] = PassPlan(
                            order: p.order,
                            direction: v,
                            areas: p.areas,
                            razorSetting: p.razorSetting,
                            angleCue: p.angleCue,
                            pressureCue: p.pressureCue,
                          );
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: p.areas ?? '',
                      decoration: const InputDecoration(labelText: 'Areas (optional)'),
                      onChanged: (v) => _passes[i] = PassPlan(
                        order: p.order,
                        direction: p.direction,
                        areas: v.isEmpty ? null : v,
                        razorSetting: p.razorSetting,
                        angleCue: p.angleCue,
                        pressureCue: p.pressureCue,
                      ),
                    ),
                    // Quick razor setting fields (optional)
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: p.razorSetting.plate ?? '',
                          decoration: const InputDecoration(labelText: 'Plate (optional)'),
                          onChanged: (v) => _passes[i] = PassPlan(
                            order: p.order,
                            direction: p.direction,
                            areas: p.areas,
                            razorSetting: RazorSetting(plate: v.isEmpty ? null : v, adjustableSetting: p.razorSetting.adjustableSetting),
                            angleCue: p.angleCue,
                            pressureCue: p.pressureCue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: p.razorSetting.adjustableSetting ?? '',
                          decoration: const InputDecoration(labelText: 'Adjustable (optional)'),
                          onChanged: (v) => _passes[i] = PassPlan(
                            order: p.order,
                            direction: p.direction,
                            areas: p.areas,
                            razorSetting: RazorSetting(
                              plate: p.razorSetting.plate,
                              adjustableSetting: v.isEmpty ? null : v,
                            ),
                            angleCue: p.angleCue,
                            pressureCue: p.pressureCue,
                          ),
                        ),
                      ),
                    ]),
                    TextFormField(
                      initialValue: p.angleCue ?? '',
                      decoration: const InputDecoration(labelText: 'Angle cue (optional)'),
                      onChanged: (v) => _passes[i] = PassPlan(
                        order: p.order,
                        direction: p.direction,
                        areas: p.areas,
                        razorSetting: p.razorSetting,
                        angleCue: v.isEmpty ? null : v,
                        pressureCue: p.pressureCue,
                      ),
                    ),
                    TextFormField(
                      initialValue: p.pressureCue ?? '',
                      decoration: const InputDecoration(labelText: 'Pressure cue (optional)'),
                      onChanged: (v) => _passes[i] = PassPlan(
                        order: p.order,
                        direction: p.direction,
                        areas: p.areas,
                        razorSetting: p.razorSetting,
                        angleCue: p.angleCue,
                        pressureCue: v.isEmpty ? null : v,
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
