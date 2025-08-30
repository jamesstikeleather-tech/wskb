// lib/features/diary/views/diary_page.dart
import 'package:flutter/material.dart';

import '../../../app/repositories.dart';              // exposes personalProcessRepo
import 'process_list_page.dart';                      // processes list/editor

/// DiaryPage
/// - Shows your diary content in the body (placeholder here).
/// - Shows a floating "Processes" button that opens the Personal Processes UI.
///   The FAB only appears when this page is active (i.e., on the Diary tab).
class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep your existing diary UI here. Replace the placeholder ListView with your actual content.
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            // TODO: Replace with your real diary entry list widget(s).
            SizedBox(height: 12),
            Text(
              'Diary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Your recent shaves will appear here.'),
          ],
        ),
      ),

      // This FAB only shows when this page is mounted (i.e., when you're on the Diary tab).
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-diary-processes', // avoid heroTag collisions with other FABs
        icon: const Icon(Icons.list_alt),
        label: const Text('Processes'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProcessListPage(repo: personalProcessRepo),
            ),
          );
        },
      ),
    );
  }
}
