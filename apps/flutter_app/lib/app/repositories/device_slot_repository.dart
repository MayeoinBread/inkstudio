import 'package:inkstudio/app/data/database/database_service.dart';

class DeviceSlotRepository {
  final db = DatabaseService.instance;

  Future<void> saveSlot({
    required String deviceSerial,
    required int slot,
    required String? deviceHash
  }) async {
    final database = await db.database;

    await database.update(
      'device_slots',
      {
        'device_hash': deviceHash
      },
      where: 'device_serial = ? AND slot = ?',
      whereArgs: [deviceSerial, slot]
    );
  }

  Future<String?> getSlotHash({
    required String deviceSerial,
    required int slot
  }) async {
    final database = await db.database;

    final slotRows = await database.query(
      'device_slots',
      columns: ['device_hash'],
      where: 'device_serial = ? AND slot = ?',
      whereArgs: [deviceSerial, slot]
    );

    if (slotRows.isEmpty) return null;

    return slotRows.first['device_hash'] as String?;
  }

  Future<Map<int, String?>> getDeviceSlotHashes(String deviceSerial) async {
    final database = await db.database;

    final rows = await database.query(
      'device_slots',
      columns: ['slot', 'device_hash'],
      where: 'device_serial = ?',
      whereArgs: [deviceSerial]
    );

    return {
      for (final row in rows)
        row['slot'] as int: row['device_hash'] as String?
    };
  }
}