import '../../inventory/models/inventory_item.dart';
import '../models/catalog_update_request.dart' show CurEntityType;

/// Try to look up a CurEntityType by its name; fall back to `.other` if missing.
CurEntityType _safeByName(String name) {
  try {
    return CurEntityType.values.byName(name); // works if your enum has that name
  } catch (_) {
    return CurEntityType.other;               // graceful fallback
  }
}

/// Map InventoryType -> CurEntityType by string names to avoid compile errors
/// when the CurEntityType enum uses different labels.
CurEntityType curTypeForInventory(InventoryType t) {
  switch (t) {
    case InventoryType.razor:
      return _safeByName('razor');
    case InventoryType.blade:
      return _safeByName('blade');
    case InventoryType.brush:
      return _safeByName('brush');
    case InventoryType.software:
      return _safeByName('software');
    case InventoryType.other:
      return CurEntityType.other;
  }
}
