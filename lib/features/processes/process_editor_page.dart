// lib/features/processes/process_editor_page.dart
// A minimal, production-friendly Process Template Editor using a Stepper.
// Integrate with your repository by implementing PersonalProcessRepository.

import 'package:flutter/material.dart';
import '../../models/personal_process.dart';

abstract class PersonalProcessRepository {
  Future<void> upsert(PersonalProcess process);
}

class ProcessEditorPage extends StatefulWidget {
  final PersonalProcess? initial;
  final PersonalProcessRepository repository;
  final String ownerUserId;

  const ProcessEditorPage({
    super.key,
    required this.repository,
    required this.ownerUserId,
    this.initial,
  });

  @override
  State<ProcessEditorPage> createState() => _ProcessEditorPageState();
}

class _ProcessEditorPageState extends State<ProcessEditorPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Basics
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController(); // comma-separated
  final _useCasesCtrl = TextEditingController(); // comma-separated
  final _timeCtrl = TextEditingController();
  bool _isActive = true;
  bool _isFavorite = false;

  // Lather
  LatherStyle? _latherStyle = LatherStyle.bowl;
  final _waterAdjCtrl = TextEditingController();

  // Post
  bool? _useAlum = null;
  RinseTemp? _rinseTemp = RinseTemp.cool;
  final _postNotesCtrl = TextEditingController();

  // Pass plan (start with one)
  final List<PassPlan> _passes = [
    const PassPlan(order: 1, direction: PassDirection.WTG),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description ?? '';
      _tagsCtrl.text = p.tags.join(', ');
      _useCasesCtrl.text = p.useCases.join(', ');
      _timeCtrl.text = p.timeEstimateMin?.toString() ?? '';
      _isActive = p.isActive;
      _isFavorite = p.isFavorite;
      _latherStyle = p.defaults.lather.style ?? LatherStyle.bowl;
      _waterAdjCtrl.text = p.defaults.lather.waterAdjustment ?? '';
      _useAlum = p.defaults.post.alum;
      _rinseTemp = p.defaults.post.rinseTemp ?? RinseTemp.cool;
      _postNotesCtrl.text = p.defaults.post.notes ?? '';
      if (p.passPlan.isNotEmpty) {
        _passes
          ..clear()
          ..addAll(p.passPlan);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    _useCasesCtrl.dispose();
    _timeCtrl.dispose();
    _waterAdjCtrl.dispose();
    _postNotesCtrl.dispose();
    super.dispose();
  }

  List<Step> _buildSteps(BuildContext context) {
    return [
      Step(
        title: const Text('Basics'),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _useCasesCtrl,
                decoration: const InputDecoration(labelText: 'Use Cases (comma-separated)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeCtrl,
                decoration: const InputDecoration(labelText: 'Time Estimate (min)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Favorite'),
                      value: _isFavorite,
                      onChanged: (v) => setState(() => _isFavorite = v),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.editing,
      ),
      Step(
        title: const Text('Prep & Lather'),
        content: Column(
          children: [
            DropdownButtonFormField<LatherStyle>(
              value: _latherStyle,
              onChanged: (v) => setState(() => _latherStyle = v),
              items: LatherStyle.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Lather Style'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _waterAdjCtrl,
              decoration: const InputDecoration(labelText: 'Water Adjustment'),
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.editing,
      ),
      Step(
        title: const Text('Pass Plan'),
        content: Column(
          children: [
            ..._passes.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text('${p.order}'),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<PassDirection>(
                        value: p.direction,
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
                        items: PassDirection.values
                            .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                            .toList(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _passes.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  final nextOrder = (_passes.isEmpty ? 0 : _passes.last.order) + 1;
                  setState(() {
                    _passes.add(PassPlan(order: nextOrder, direction: PassDirection.XTG));
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Pass'),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.editing,
      ),
      Step(
        title: const Text('Post'),
        content: Column(
          children: [
            DropdownButtonFormField<RinseTemp>(
              value: _rinseTemp,
              onChanged: (v) => setState(() => _rinseTemp = v),
              items: RinseTemp.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Rinse Temp'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Use Alum'),
              value: _useAlum ?? false,
              onChanged: (v) => setState(() => _useAlum = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _postNotesCtrl,
              decoration: const InputDecoration(labelText: 'Post-shave Notes'),
              maxLines: 2,
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.editing,
      ),
      Step(
        title: const Text('Review & Save'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tap Save to persist your template.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _onSave,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Template'),
            )
          ],
        ),
        isActive: _currentStep >= 4,
        state: StepState.editing,
      ),
    ];
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }
    final tags = _tagsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final uses = _useCasesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final timeMin = int.tryParse(_timeCtrl.text);

    final process = PersonalProcess(
      id: widget.initial?.id ?? '',
      schemaVersion: 1,
      ownerUserId: widget.ownerUserId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      tags: tags,
      useCases: uses,
      timeEstimateMin: timeMin,
      isActive: _isActive,
      isFavorite: _isFavorite,
      defaults: ProcessDefaults(
        lather: LatherDefaults(style: _latherStyle, waterAdjustment: _waterAdjCtrl.text.trim().isEmpty ? null : _waterAdjCtrl.text.trim()),
        post: PostDefaults(alum: _useAlum, rinseTemp: _rinseTemp, notes: _postNotesCtrl.text.trim().isEmpty ? null : _postNotesCtrl.text.trim()),
      ),
      passPlan: _passes,
    );

    await widget.repository.upsert(process);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Process Template Editor')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () => setState(() => _currentStep = (_currentStep + 1).clamp(0, steps.length - 1)),
        onStepCancel: () => setState(() => _currentStep = (_currentStep - 1).clamp(0, steps.length - 1)),
        steps: steps,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              ElevatedButton(onPressed: details.onStepContinue, child: const Text('Next')),
              const SizedBox(width: 12),
              TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
            ],
          );
        },
      ),
    );
  }
}
