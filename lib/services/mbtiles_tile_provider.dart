import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sqflite/sqflite.dart';

class MBTilesTileProvider extends TileProvider {
  final Database db;
  MBTilesTileProvider(this.db);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final z = coordinates.z.toInt();
    final x = coordinates.x.toInt();
    // MBTiles uses TMS (Y axis flipped compared to XYZ/OSM)
    final y = (1 << z) - 1 - coordinates.y.toInt();
    return _MBTilesImageProvider(db: db, z: z, x: x, y: y);
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }
}

class _MBTilesImageProvider extends ImageProvider<_MBTilesImageProvider> {
  final Database db;
  final int z, x, y;

  const _MBTilesImageProvider({
    required this.db,
    required this.z,
    required this.x,
    required this.y,
  });

  @override
  Future<_MBTilesImageProvider> obtainKey(ImageConfiguration config) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
      _MBTilesImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadCodec(),
      scale: 1.0,
      informationCollector: () =>
          [DiagnosticsProperty('tile', '$z/$x/$y')],
    );
  }

  Future<ui.Codec> _loadCodec() async {
    final rows = await db.query(
      'tiles',
      columns: ['tile_data'],
      where: 'zoom_level = ? AND tile_column = ? AND tile_row = ?',
      whereArgs: [z, x, y],
    );
    if (rows.isEmpty) throw Exception('Offline tile not found: $z/$x/$y');

    final bytes = rows.first['tile_data'] as Uint8List;
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return ui.instantiateImageCodecFromBuffer(buffer);
  }

  @override
  bool operator ==(Object other) =>
      other is _MBTilesImageProvider &&
      z == other.z &&
      x == other.x &&
      y == other.y;

  @override
  int get hashCode => Object.hash(z, x, y);
}
