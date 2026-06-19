import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class OfflineRegion {
  final String name;
  final double minLat, maxLat, minLon, maxLon;
  final int minZoom, maxZoom;

  const OfflineRegion({
    required this.name,
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
    required this.minZoom,
    required this.maxZoom,
  });

  int estimateTileCount() {
    int total = 0;
    for (int z = minZoom; z <= maxZoom; z++) {
      final xMin = _lonToTile(minLon, z);
      final xMax = _lonToTile(maxLon, z);
      final yMin = _latToTile(maxLat, z);
      final yMax = _latToTile(minLat, z);
      total += (xMax - xMin + 1) * (yMax - yMin + 1);
    }
    return total;
  }

  String estimatedSize() {
    final mb = (estimateTileCount() * 15) / 1024;
    return mb < 1024
        ? '${mb.toStringAsFixed(0)} MB'
        : '${(mb / 1024).toStringAsFixed(1)} GB';
  }
}

// Predefined regions for Tunisia
class TunisiaRegions {
  static const grandTunis = OfflineRegion(
    name: 'grand_tunis',
    minLat: 36.70, maxLat: 36.95,
    minLon: 10.05, maxLon: 10.30,
    minZoom: 10, maxZoom: 15,
  );

  static const sfax = OfflineRegion(
    name: 'sfax',
    minLat: 34.65, maxLat: 34.85,
    minLon: 10.65, maxLon: 10.85,
    minZoom: 10, maxZoom: 15,
  );

  static const allTunisia = OfflineRegion(
    name: 'all_tunisia',
    minLat: 30.0, maxLat: 37.5,
    minLon: 7.5, maxLon: 11.6,
    minZoom: 5, maxZoom: 11,
  );
}

class OfflineMapService {
  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _userAgent = 'ATBBankingApp/1.0 (offline-map-download)';

  static Future<void> downloadRegion({
    required OfflineRegion region,
    required void Function(int done, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await _mapsDir();
    final dbPath = '${dir.path}/${region.name}.mbtiles';
    final db = await _initMBTiles(dbPath);

    final dio = Dio(BaseOptions(
      headers: {'User-Agent': _userAgent},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    final tiles = _generateTileList(region);
    int done = 0;

    for (final (z, x, y) in tiles) {
      if (cancelToken?.isCancelled == true) break;

      // Skip already downloaded tiles (resume support)
      final tmsY = (1 << z) - 1 - y;
      final exists = await db.query(
        'tiles',
        columns: ['zoom_level'],
        where: 'zoom_level=? AND tile_column=? AND tile_row=?',
        whereArgs: [z, x, tmsY],
      );
      if (exists.isNotEmpty) {
        done++;
        onProgress(done, tiles.length);
        continue;
      }

      try {
        final url = _tileUrl
            .replaceAll('{z}', '$z')
            .replaceAll('{x}', '$x')
            .replaceAll('{y}', '$y');

        final resp = await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
          cancelToken: cancelToken,
        );

        if (resp.data != null) {
          await db.insert(
            'tiles',
            {
              'zoom_level': z,
              'tile_column': x,
              'tile_row': tmsY,
              'tile_data': resp.data,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      } catch (_) {
        // Skip failed tiles silently
      }

      done++;
      onProgress(done, tiles.length);
      // Respect OSM rate limit
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await db.close();
  }

  static List<(int, int, int)> _generateTileList(OfflineRegion r) {
    final list = <(int, int, int)>[];
    for (int z = r.minZoom; z <= r.maxZoom; z++) {
      final xMin = _lonToTile(r.minLon, z);
      final xMax = _lonToTile(r.maxLon, z);
      final yMin = _latToTile(r.maxLat, z);
      final yMax = _latToTile(r.minLat, z);
      for (int x = xMin; x <= xMax; x++) {
        for (int y = yMin; y <= yMax; y++) {
          list.add((z, x, y));
        }
      }
    }
    return list;
  }

  static Future<bool> regionExists(String name) async {
    final dir = await _mapsDir();
    return File('${dir.path}/$name.mbtiles').exists();
  }

  static Future<Database?> openRegion(String name) async {
    final dir = await _mapsDir();
    final path = '${dir.path}/$name.mbtiles';
    if (!await File(path).exists()) return null;
    return openDatabase(path, readOnly: true);
  }

  static Future<void> deleteRegion(String name) async {
    final dir = await _mapsDir();
    final file = File('${dir.path}/$name.mbtiles');
    if (await file.exists()) await file.delete();
  }

  static Future<String> regionFileSize(String name) async {
    final dir = await _mapsDir();
    final file = File('${dir.path}/$name.mbtiles');
    if (!await file.exists()) return '0 MB';
    final bytes = await file.length();
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  static Future<Directory> _mapsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/offline_maps');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Database> _initMBTiles(String path) async {
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tiles (
            zoom_level  INTEGER NOT NULL,
            tile_column INTEGER NOT NULL,
            tile_row    INTEGER NOT NULL,
            tile_data   BLOB    NOT NULL,
            PRIMARY KEY (zoom_level, tile_column, tile_row)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS metadata (
            name  TEXT,
            value TEXT
          )
        ''');
        await db.insert('metadata', {'name': 'format', 'value': 'png'});
      },
    );
  }
}

int _lonToTile(double lon, int z) =>
    ((lon + 180) / 360 * (1 << z)).floor().clamp(0, (1 << z) - 1);

int _latToTile(double lat, int z) {
  final rad = lat * pi / 180;
  return ((1 - log(tan(rad) + 1 / cos(rad)) / pi) / 2 * (1 << z))
      .floor()
      .clamp(0, (1 << z) - 1);
}
