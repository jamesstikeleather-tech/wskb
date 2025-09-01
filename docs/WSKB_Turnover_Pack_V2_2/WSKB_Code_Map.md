# WSKB Code Map (v2_2)

This file provides a quick reference for where things live in the repo.  
It should be updated whenever new features or directories are added.

---

## Entrypoint
- **`lib/main.dart`**
  - App root, GoRouter routes, navigation setup.
  - Must use `package:wskb_app/...` imports (no `../` relative imports).

- **`lib/app/env.dart`**
  - Environment switch: `useFirestore = false` → in-memory; `true` → Firestore.

- **`lib/app/repositories.dart`**
  - Central export file for repositories.

---

## Features

### Catalogs
- `lib/features/catalogs/`
  - Data + views for Catalog entities (razors, brushes, blades, etc.).

### Inventory
- `lib/features/inventory/`
  - User inventory views and data connections.

### Memos
- `lib/features/memos/`
  - Personal memo overlays for items not yet in the catalog.

### Diary
- `lib/features/diary/data/personal_process_repository.dart`
  - In-memory repository for PersonalProcess.
- `lib/features/diary/views/diary_page.dart`
  - Main diary page.
- `lib/features/diary/views/process_list_page.dart`
  - Shows saved PersonalProcesses.
- `lib/features/diary/views/process_editor_page.dart`
  - Create/edit a PersonalProcess template.
- `lib/features/diary/diary_template_hook_snippet.dart`
  - Hook snippet for seeding processes.

---

## Models
- `lib/models/personal_process.dart`
  - Schema + serialization for PersonalProcess.
- `lib/models/diary_entry.dart`
  - Schema + serialization for DiaryEntry.
- Other domain models (razor, brush, blade, fragrance, etc.) are under `lib/models/`.

---

## Repositories
- `lib/repos/personal_process_repo.dart`
  - PersonalProcess repo wrapper.
- `lib/data/brand_repository.dart`
  - In-memory Brand repository.
- More repositories will be migrated to Firestore in later milestones.

---

## Known Helpers
- **Seeds**
  - `brand_repository.dart` → seeded brands.
  - `personal_process_repository.dart` → seeded processes.

---

## Next Steps (planned for v2_3+)
- Expand **Razor** entity (straight razor grind, steel, jimps, shoulder, shavette blade types).
- Migrate in-memory repos → Firestore.
- Add Firebase Auth handling.
- Connect image uploads to Firebase Cloud Storage.
