import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/atm.dart';
import 'location_service.dart';

class ATMService {
  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';

  static final List<ATM> _fallbackATMs = [
    ATM(id: '1', name: 'Agence Tunis Marine', address: 'Avenue Habib Bourguiba, Tunis', lat: 36.8188, lon: 10.1657, isOpen: true, hasDeposit: true, hours: '08:00 - 18:00', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'ATB'),
    ATM(id: '2', name: 'Agence Tunis City Centre', address: '15 Rue de Marseille, 1000 Tunis', lat: 36.8147, lon: 10.1797, isOpen: true, hasDeposit: true, hours: '24h/24 et 7j/7', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'ATB'),
    ATM(id: '3', name: 'Agence Lac 1', address: 'Les Berges du Lac, Tunis', lat: 36.8378, lon: 10.2284, isOpen: true, hasDeposit: false, hours: '24h/24 et 7j/7', services: ['Retrait', 'Relevé'], bank: 'ATB'),
    ATM(id: '4', name: 'Agence Montplaisir', address: 'Avenue de Paris, Tunis', lat: 36.8300, lon: 10.1700, isOpen: true, hasDeposit: false, hours: '08:00 - 20:00', services: ['Retrait', 'Relevé'], bank: 'ATB'),
    ATM(id: '5', name: 'Agence La Marsa', address: 'Avenue de la République, La Marsa', lat: 36.8786, lon: 10.3251, isOpen: false, hasDeposit: true, hours: '08:00 - 18:00', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'ATB'),
    ATM(id: '6', name: 'Agence Sfax Centre', address: 'Avenue Hedi Chaker, Sfax', lat: 34.7398, lon: 10.7600, isOpen: true, hasDeposit: true, hours: '24h/24 et 7j/7', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'ATB'),
    ATM(id: '7', name: 'Agence Sousse Corniche', address: 'Avenue du 14 Janvier, Sousse', lat: 35.8245, lon: 10.6369, isOpen: true, hasDeposit: false, hours: '24h/24 et 7j/7', services: ['Retrait', 'Relevé'], bank: 'ATB'),
    ATM(id: '8', name: 'Agence Ariana', address: 'Avenue de la Bouzaïa, Ariana', lat: 36.8625, lon: 10.1956, isOpen: true, hasDeposit: false, hours: '08:00 - 18:00', services: ['Retrait', 'Relevé'], bank: 'ATB'),
    ATM(id: '9', name: 'Agence Ben Arous', address: 'Route de Zaghouan, Ben Arous', lat: 36.7533, lon: 10.2283, isOpen: true, hasDeposit: true, hours: '24h/24 et 7j/7', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'ATB'),
    ATM(id: '10', name: 'Agence Nabeul', address: 'Avenue Habib Bourguiba, Nabeul', lat: 36.4524, lon: 10.7352, isOpen: true, hasDeposit: false, hours: '08:00 - 18:00', services: ['Retrait', 'Relevé'], bank: 'ATB'),
    ATM(id: '11', name: 'Agence Monastir', address: 'Avenue de l\'Indépendance, Monastir', lat: 35.7643, lon: 10.8113, isOpen: true, hasDeposit: true, hours: '24h/24 et 7j/7', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'ATB'),
    ATM(id: '12', name: 'Agence Gabès', address: 'Avenue Farhat Hached, Gabès', lat: 33.8838, lon: 10.0982, isOpen: true, hasDeposit: false, hours: '08:00 - 18:00', services: ['Retrait', 'Relevé'], bank: 'ATB'),
    ATM(id: '13', name: 'Agence Kairouan', address: 'Avenue de la République, Kairouan', lat: 35.6744, lon: 10.0963, isOpen: true, hasDeposit: false, hours: '08:00 - 18:00', services: ['Retrait', 'Relevé'], bank: 'ATB'),
    ATM(id: '14', name: 'STB Tunis Centre', address: 'Rue Hedi Nouira, Tunis', lat: 36.8200, lon: 10.1750, isOpen: true, hasDeposit: true, hours: '24h/24 et 7j/7', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'STB'),
    ATM(id: '15', name: 'BNA Avenue', address: 'Avenue Mohamed V, Tunis', lat: 36.8165, lon: 10.1730, isOpen: true, hasDeposit: false, hours: '24h/24 et 7j/7', services: ['Retrait', 'Relevé'], bank: 'BNA'),
    ATM(id: '16', name: 'BIAT Lafayette', address: 'Avenue de Paris, Tunis', lat: 36.8280, lon: 10.1810, isOpen: true, hasDeposit: true, hours: '24h/24 et 7j/7', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'BIAT'),
    ATM(id: '17', name: 'Zitouna Bank Menzah', address: 'Menzah 6, Tunis', lat: 36.8450, lon: 10.1850, isOpen: true, hasDeposit: false, hours: '08:00 - 20:00', services: ['Retrait', 'Relevé'], bank: 'Zitouna'),
    ATM(id: '18', name: 'UIB Carthage', address: 'Route de Carthage, Tunis', lat: 36.8548, lon: 10.3286, isOpen: true, hasDeposit: false, hours: '24h/24 et 7j/7', services: ['Retrait', 'Relevé'], bank: 'UIB'),
    ATM(id: '19', name: 'Amen Bank Ennasr', address: 'Ennasr 2, Ariana', lat: 36.8710, lon: 10.1900, isOpen: true, hasDeposit: true, hours: '24h/24 et 7j/7', services: ['Retrait', 'Dépôt', 'Relevé'], bank: 'Amen Bank'),
    ATM(id: '20', name: 'ATB El Aouina', address: 'Route de l\'Aéroport, Tunis', lat: 36.8508, lon: 10.2270, isOpen: true, hasDeposit: false, hours: '24h/24 et 7j/7', services: ['Retrait', 'Relevé'], bank: 'ATB'),
  ];

  static Future<List<ATM>> fetchNearbyATMs({
    double? lat,
    double? lon,
    double radiusKm = 50,
  }) async {
    try {
      final centerLat = lat ?? 36.8188;
      final centerLon = lon ?? 10.1657;
      final radiusM = (radiusKm * 1000).round();

      final query =
          '[out:json][timeout:25];node["amenity"="atm"](around:$radiusM,$centerLat,$centerLon);out body;';

      final response = await http
          .post(Uri.parse(_overpassUrl), body: query)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final elements = data['elements'] as List<dynamic>;

        List<ATM> atms =
            elements.map((e) => ATM.fromOverpass(e as Map<String, dynamic>)).toList();

        if (atms.isEmpty) return _withDistances(_fallbackATMs, lat, lon);

        atms = _withDistances(atms, lat, lon);
        atms.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
        return atms;
      }
    } catch (_) {}

    return _withDistances(_fallbackATMs, lat, lon);
  }

  static List<ATM> _withDistances(List<ATM> atms, double? lat, double? lon) {
    if (lat == null || lon == null) return atms;
    final result = atms.map((a) {
      final d = LocationService.distanceBetween(lat, lon, a.lat, a.lon);
      return a.copyWith(distance: d);
    }).toList();
    result.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    return result;
  }

  static List<ATM> get fallbackATMs => _fallbackATMs;
}
