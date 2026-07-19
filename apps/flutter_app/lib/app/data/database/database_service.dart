import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    sqfliteFfiInit();

    final dir = await getApplicationSupportDirectory();

    final dbPath = join(dir.path, 'inkstudio.db');

    _db = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE devices(
              serial TEXT PRIMARY KEY,
              last_connected INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE device_slots(
              device_serial TEXT NOT NULL,
              slot INTEGER NOT NULL,
              device_hash TEXT,

              PRIMARY KEY(device_serial, slot),

              FOREIGN KEY(device_serial)
                REFERENCES devices(serial)
                ON DELETE CASCADE
            )
          ''');
          
          await db.execute(
            '''
            CREATE TABLE images(
              id TEXT PRIMARY KEY,
              original_path TEXT NOT NULL,
              thumbnail_path TEXT NOT NULL,
              processed_path TEXT NOT NULL,
              source_hash TEXT NOT NULL,
              device_hash TEXT NOT NULL
            )
            '''
          );

          await db.execute(
            '''
            CREATE TABLE albums(
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL
            )
            '''
          );

          await db.execute(
            '''
            CREATE TABLE slots(
              album_id TEXT NOT NULL,
              slot INTEGER NOT NULL,
              image_id TEXT,
              metadata_json TEXT NOT NULL,

              PRIMARY KEY (album_id, slot),

              FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE
            )
            '''
          );

          for (int i=1; i<=700; i++) {
            await db.insert(
              'slots',
              {
                'album_id': 'default',
                'slot': i,
                'image_id': null,
                'metadata_json': '{}'
              }
            );
          }

          await db.insert(
            'albums',
            {
              'id': 'default',
              'name': 'Default'
            }
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE devices(
                serial TEXT PRIMARY KEY,
                last_connected INTEGER NOT NULL
              )
            ''');

            await db.execute('''
              CREATE TABLE device_slots(
                device_serial TEXT NOT NULL,
                slot INTEGER NOT NULL,
                device_hash TEXT,

                PRIMARY KEY(device_serial, slot),

                FOREIGN KEY(device_serial)
                  REFERENCES devices(serial)
                  ON DELETE CASCADE
              )
            ''');
          }
          
          if (oldVersion < 3) {
            final albums = await db.query(
              'albums', columns: ['id']
            );

            for (final album in albums) {
              final albumId = album['id'] as String;

              final res = await db.rawQuery('SELECT MAX(slot) AS max_slot FROM slots WHERE album_id = ?', [albumId]);
              final maxSlot = (res.first['max_slot'] as int?) ?? 0;

              // Expand existing albums to 700 slots
              for (int i=maxSlot + 1; i<=700; i++) {
                await db.insert(
                  'slots',
                  {
                    'album_id': albumId,
                    'slot': i,
                    'image_id': null,
                    'metadata_json': '{}'
                  }
                );
              }
            }
          }
        }
      )
    );

    return _db!;
  }
}