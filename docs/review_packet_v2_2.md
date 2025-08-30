# Wet Shaving Knowledge Base (WSKB) – Review Packet v2_2

## 1. Project Overview
WSKB is a system for wet shaving enthusiasts to catalog, inventory, and log shaving gear and experiences.  
It uses Flutter + Dart, with Firestore for persistence (toggled via `env.dart`).  

**Core concepts:**
- **Catalogs:** Global reference data (Razors, Blades, Brushes, Soaps, Companies, Brands, Makers/Artisans, Materials, Scents, Themes/Moods).
- **Inventories:** Personal instances of catalog items owned by a user (with price paid, purchase date, storage location, etc.).
- **Memos:** Temporary user-submitted additions awaiting admin approval to enter the Catalog.
- **Shaver Profile:** Environment + user variables (water type, skin type, allergies).
- **Diary:** Personal shave log.  
- **Processes:** User-defined “templates” for a shave routine (prep, lather, passes, post).

**Architectural pattern:** Repository-driven, with models in `lib/models` and feature-oriented folders in `lib/features/*`.

---

## 2. Current Milestone: v2_2
- ✅ UI working in-memory for:
  - **Catalogs** (razors, blades, brushes, etc.)
  - **Inventories**
  - **Diary**
  - **Personal Processes** (create, list, edit)
- ✅ Firestore integration works (flag in `lib/app/env.dart`):
  ```dart
  // Flip this to true when ready to use Firestore
  const bool useFirestore = false;
✅ Image handling pipeline working (to move to Cloud Storage).

✅ Security: Firebase Web API key rotated, restricted, scrubbed from history.

✅ GitHub push protection enabled.

🔎 Known issues:

Preloaded process seed not visible until user adds a process (repo watchAll initial emission).

Minor Razor schema mismatch (to revisit).

🔮 Next:

Expand Razor model to cover all types (DE, SE, shavette, straight).

Build Shaver profile UI.

Transition to Firestore + Cloud Storage full-time.

3. Key Files to Prioritize
lib/app/repositories.dart – composition root, all repos wired here.

lib/models/personal_process.dart – complex model, enums + nested defaults.

lib/features/diary/data/personal_process_repository.dart – repo logic.

lib/features/diary/views/process_list_page.dart – list + navigation.

lib/features/diary/views/process_editor_page.dart – editor form.

docs/schema/wskb_master_schema_v2_2.json – master schema definition.

4. Review Goals
Codex/human reviewers should focus on:

Dart & Flutter Best Practices
Null safety coverage.

Immutability (const where possible).

Async/await vs sync constructors.

Idiomatic use of Streams and StreamBuilder.

Architecture
Consistency across repositories (naming, patterns).

Proper layering: models vs data vs views.

Avoid drift between schema (wskb_master_schema_v2_2.json) and models.

Performance
Check StreamBuilder usage for rebuild efficiency.

Avoid rebuilding entire lists unnecessarily.

Watch for nested FutureBuilder/StreamBuilder.

Security & Hygiene
Confirm API keys excluded (firebase_options.dart auto-generated, restricted).

.gitignore excludes secrets/build.

CSV import validation (prevent malformed entries).

5. Known Issues for Reviewer Awareness
Seed bug: Process seed doesn’t appear until first user add. Suspect repo stream not emitting initial data.

Minor Razor schema mismatch to be resolved later.

Windows environment had Realtek 8821CE Wi-Fi burst issues (not code-related, but impacted dev streaming tests).

6. Questions for Reviewer
Are repo patterns consistent and idiomatic in Dart?

Any refactor suggestions for personal_process.dart (lots of nested defaults)?

Should StreamBuilder in process list/editor preload data (initialData) instead of relying on repo emissions?

Any API/DTO mismatch with schema v2_2?

Security: is the Firebase key setup correct for a public repo?

Prepared for external review by Codex / maintainers, WSKB Milestone v2_2.

yaml
Copy code

---

👉 Next step: save this as  
`/docs/review_packet_v2_2.md` in your repo, commit, and push.  

Then in Codex sidebar you can say:  
*“Please start by reading `docs/review_packet_v2_2.md` in the WSKB repo, then review the project for Dart best practices, repo consistency, performance, and security hygiene.”*  

Do you want me to also prep a **Codex prompt template** you can paste so it knows *exactly* how to start the review?





Ask ChatGPT
