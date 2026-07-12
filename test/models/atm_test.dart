import 'package:flutter_test/flutter_test.dart';
import 'package:atb_banking_app/models/atm.dart';

void main() {
  group('ATM.fromOverpass', () {
    test('parses a fully-tagged Overpass node', () {
      final atm = ATM.fromOverpass({
        'id': 123456,
        'lat': 36.8188,
        'lon': 10.1657,
        'tags': {
          'name': 'ATB Tunis Marine',
          'operator': 'ATB',
          'opening_hours': '24/7',
          'cash_in': 'yes',
          'cardless': 'yes',
          'phone': '+216 71 110 500',
          'addr:housenumber': '15',
          'addr:street': 'Avenue Habib Bourguiba',
          'addr:city': 'Tunis',
        },
      });

      expect(atm.id, '123456');
      expect(atm.name, 'ATB Tunis Marine');
      expect(atm.bank, 'ATB');
      expect(atm.lat, 36.8188);
      expect(atm.lon, 10.1657);
      expect(atm.hours, '24/7');
      expect(atm.hasDeposit, isTrue);
      expect(atm.hasCardless, isTrue);
      expect(atm.phone, '+216 71 110 500');
      expect(atm.address, '15, Avenue Habib Bourguiba, Tunis');
      expect(atm.services, containsAll(['Retrait', 'Dépôt', 'Relevé']));
    });

    test('falls back to safe defaults when tags are missing', () {
      final atm = ATM.fromOverpass({'id': 1, 'lat': 36.0, 'lon': 10.0});

      expect(atm.name, 'DAB');
      expect(atm.bank, 'Banque');
      expect(atm.address, 'Tunisie');
      expect(atm.hours, '08:00 - 18:00');
      expect(atm.hasDeposit, isFalse);
      expect(atm.hasCardless, isFalse);
      expect(atm.services, ['Retrait', 'Relevé']);
    });
  });

  group('ATM.copyWith', () {
    test('updates distance and keeps every other field', () {
      const original = ATM(
        id: '1',
        name: 'Agence Lac 1',
        address: 'Les Berges du Lac, Tunis',
        lat: 36.8378,
        lon: 10.2284,
        hasDeposit: true,
        bank: 'ATB',
      );

      final updated = original.copyWith(distance: 500);

      expect(updated.distance, 500);
      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.hasDeposit, original.hasDeposit);
      expect(updated.bank, original.bank);
    });
  });

  group('ATM.distanceText', () {
    ATM atmWithDistance(double? d) => ATM(
          id: '1',
          name: 'Test',
          address: 'Tunis',
          lat: 0,
          lon: 0,
          distance: d,
        );

    test('formats meters below 1 km', () {
      expect(atmWithDistance(320).distanceText, '320m');
    });

    test('formats kilometers with one decimal above 1 km', () {
      expect(atmWithDistance(1532).distanceText, '1.5km');
    });

    test('returns an empty string when distance is unknown', () {
      expect(atmWithDistance(null).distanceText, '');
    });
  });
}
