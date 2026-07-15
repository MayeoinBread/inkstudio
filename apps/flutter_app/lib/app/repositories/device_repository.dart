import 'package:inkstudio/app/data/database/database_service.dart';

class DeviceRepository {
  final db = DatabaseService.instance;

  Future<void> createDevice(String serial) async {
    final database = await db.database;

    await database.transaction((txn) async {
      await txn.insert(
        'devices',
        {
          'serial': serial,
          'last_connected': DateTime.now().millisecondsSinceEpoch
        }
      );

      for (int slot=1; slot<=700; slot++) {
        await txn.insert(
          'device_slots',
          {
            'device_serial': serial,
            'slot': slot,
            'device_hash': null
          }
        );
      }
    });
  }

  Future<bool> exists(String serial) async {
    final database = await db.database;

    final rows = await database.query(
      'devices',
      where: 'serial = ?',
      whereArgs: [serial]
    );

    return rows.isNotEmpty;
  }

  Future<void> ensureExists(String serial) async {
    if (await exists(serial)) return;

    await createDevice(serial);
  }

  Future<void> updateLastConnected(String serial) async {
    final database = await db.database;

    await database.update(
      'devices',
      {
        'last_connected': DateTime.now().millisecondsSinceEpoch
      },
      where: 'serial = ?',
      whereArgs: [serial]
    );
  }
}