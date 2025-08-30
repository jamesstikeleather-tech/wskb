// lib/features/diary/diary_template_hook_snippet.dart
// Example: add a template selector to your Diary form controller / UI.

import 'package:flutter/material.dart';
import '../../models/personal_process.dart';
import '../../models/diary_entry.dart';

class DiaryTemplateDropdown extends StatelessWidget {
  final List<PersonalProcess> templates;
  final ValueChanged<PersonalProcess> onSelected;

  const DiaryTemplateDropdown({
    super.key,
    required this.templates,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const SizedBox.shrink();
    }
    return DropdownButtonFormField<PersonalProcess>(
      decoration: const InputDecoration(labelText: 'Choose Process'),
      items: templates
          .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.name),
              ))
          .toList(),
      onChanged: (p) {
        if (p != null) onSelected(p);
      },
    );
  }
}

// Example controller hook:
class DiaryFormController {
  DiaryEntry entry;
  DiaryFormController(this.entry);

  void applyTemplate(PersonalProcess process) {
    entry = entry.applyingProcess(process);
    // TODO: bind updated refs into UI controllers if using text/controllers.
  }
}
