# WSKB (Flutter)
- Path: C:\Users\james\wskb\wskb_app
- Flutter: 3.35.x (web on Chrome)
- Router: go_router
- Toggle: lib/app/env.dart → useFirestore = false|true
- Repos (memory + firestore stubs): brands, razors, inventory, diary, memos
- Importer: Razors CSV at /features/catalogs/views/razor_import_page.dart
  - accepts: name, razorType, form, brandId/brandID, brandName, aliases, specs.*, maker, specs_json
  - creates brands on-the-fly (BrandRepository.ensure)
  - creates makers (MemoryMakerRepository.ensureByName)
- Current focus: Straight razors import; expand to DE next
- Next up: Makers UI, Firestore brand/maker repos, delete-confirm/undo
# WSKB — Project Notes

**Path:** `C:\Users\james\wskb\wskb_app`  
**Flutter:** 3.35.x (web: Chrome)  
**Router:** go_router  
**Toggle:** `lib/app/env.dart` → `useFirestore = false|true`

## Repos
- Brands (BrandRepository with ensure/create)
- Razors (Memory + Firestore stubs)
- Makers (Memory ensureByName)
- Inventory / Diary / Memos

## Importer
- File: `features/catalogs/views/razor_import_page.dart`
- CSV columns: `name, razorType, form, brandId/brandID, brandName, aliases, specs.*, maker, specs_json`
- Auto-creates brands (ensure) and makers (ensureByName)

## Run
```powershell
flutter analyze
flutter run -d chrome --web-port 5617
