import 'package:flutter_test/flutter_test.dart';
import 'package:atb_banking_app/services/offline_map_service.dart';

void main() {
  group('OfflineRegion.estimateTileCount', () {
    test('counts slippy-map tiles for the whole world at low zoom', () {
      // Zoom 0 has exactly 1 tile, zoom 1 has 2x2 = 4 tiles.
      const world = OfflineRegion(
        name: 'world',
        minLat: -85.0,
        maxLat: 85.0,
        minLon: -180.0,
        maxLon: 180.0,
        minZoom: 0,
        maxZoom: 1,
      );

      expect(world.estimateTileCount(), 5);
    });

    test('a wider zoom range never yields fewer tiles', () {
      const narrow = OfflineRegion(
        name: 'tunis',
        minLat: 36.70,
        maxLat: 36.95,
        minLon: 10.05,
        maxLon: 10.30,
        minZoom: 10,
        maxZoom: 12,
      );
      const wide = OfflineRegion(
        name: 'tunis',
        minLat: 36.70,
        maxLat: 36.95,
        minLon: 10.05,
        maxLon: 10.30,
        minZoom: 10,
        maxZoom: 15,
      );

      expect(wide.estimateTileCount(), greaterThan(narrow.estimateTileCount()));
    });
  });

  group('OfflineRegion.estimatedSize', () {
    test('reports megabytes for small regions', () {
      expect(TunisiaRegions.grandTunis.estimatedSize(), endsWith('MB'));
    });
  });

  group('TunisiaRegions', () {
    test('predefined regions have coherent bounding boxes', () {
      for (final region in [
        TunisiaRegions.grandTunis,
        TunisiaRegions.sfax,
        TunisiaRegions.allTunisia,
      ]) {
        expect(region.minLat, lessThan(region.maxLat));
        expect(region.minLon, lessThan(region.maxLon));
        expect(region.minZoom, lessThanOrEqualTo(region.maxZoom));
        expect(region.estimateTileCount(), greaterThan(0));
      }
    });
  });
}
