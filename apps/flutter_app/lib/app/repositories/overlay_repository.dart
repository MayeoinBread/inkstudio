import 'dart:convert';

import 'package:inkstudio/app/data/database/database_service.dart';
import 'package:inkstudio_image/inkstudio_image.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OverlayRepository {
  final db = DatabaseService.instance;

  Future<void> saveOverlay({
    required String imageId,
    required ContentOverlay overlay
  }) async {
    final database = await db.database;

    await database.insert(
      'overlays',
      {
        'id': overlay.id,
        'image_id': imageId,
        'data': jsonEncode(overlay.toJson())
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<ContentOverlay?> getOverlay(String overlayId) async {
    final database = await db.database;

    final rows = await database.query(
      'overlays',
      where: 'id = >',
      whereArgs: [overlayId]
    );

    if (rows.isEmpty) return null;

    return _fromRow(rows.first);
  }

  Future<List<ContentOverlay>> getOverlays(String imageId) async {
    final database = await db.database;

    final rows = await database.query(
      'overlays',
      where: 'image_id = ?',
      whereArgs: [imageId]
    );

    return rows.map(_fromRow).toList();
  }

  Future<void> updateOverlay(ContentOverlay overlay) async {
    final database = await db.database;

    await database.update(
      'overlays',
      {
        'data': jsonEncode(overlay.toJson())
      },
      where: 'id = ?',
      whereArgs: [overlay.id]
    );
  }

  Future<void> deleteOverlay(String overlayId) async {
    final database = await db.database;

    await database.delete(
      'overlays',
      where: 'id = ?',
      whereArgs: [overlayId]
    );
  }

  Future<void> saveOverlays({
    required String? imageId,
    required List<ContentOverlay> overlays
  }) async {
    if (imageId == null) return;

    final database = await db.database;

    await database.transaction(
      (txn) async {
        // Get the IDs of all overlays currently stored
        // for this image
        final existingRows = await txn.query(
          'overlays',
          columns: ['id'],
          where: 'image_id = ?',
          whereArgs: [imageId]
        );

        final existingIds = existingRows.map((row) => row['id'] as String).toSet();

        // IDs of overlays that should exist after saving
        final currentIds = overlays.map((overlay) => overlay.id).toSet();

        // Delete overlays that were removed from the editor
        final deletedIds = existingIds.difference(currentIds);

        for (final id in deletedIds) {
          await txn.delete(
            'overlays', where: 'id = ? AND image_id = ?',
            whereArgs: [id, imageId]
          );
        }

        // Insert or update all current overlays
        for (final overlay in overlays) {
          await txn.insert(
            'overlays',
            {
              'id': overlay.id,
              'image_id': imageId,
              'data': jsonEncode(overlay.toJson())
            },
            conflictAlgorithm: ConflictAlgorithm.replace
          );
        }
      }
    );
  }

  ContentOverlay _fromRow(Map<String, Object?> row) {
    final json = jsonDecode(row['data'] as String) as Map<String, dynamic>;

    return ContentOverlay.fromJson(json);
  }
}