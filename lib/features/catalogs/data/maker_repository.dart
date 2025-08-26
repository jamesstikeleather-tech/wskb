import '../models/maker.dart';

abstract class MakerRepository {
  /// Ensure a Maker exists by name (case-insensitive). Returns the makerId.
  Future<String> ensureByName(String name);

  /// Optional: list all makers (for future UI).
  List<Maker> all();
}
