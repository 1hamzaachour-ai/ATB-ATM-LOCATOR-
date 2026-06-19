class ATM {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final bool isOpen;
  final bool hasDeposit;
  final bool hasCardless;
  final String? phone;
  final String hours;
  final List<String> services;
  final double? distance;
  final String bank;

  const ATM({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    this.isOpen = true,
    this.hasDeposit = false,
    this.hasCardless = false,
    this.phone,
    this.hours = '08:00 - 18:00',
    this.services = const ['Retrait'],
    this.distance,
    this.bank = 'ATB',
  });

  ATM copyWith({double? distance}) => ATM(
        id: id,
        name: name,
        address: address,
        lat: lat,
        lon: lon,
        isOpen: isOpen,
        hasDeposit: hasDeposit,
        hasCardless: hasCardless,
        phone: phone,
        hours: hours,
        services: services,
        distance: distance ?? this.distance,
        bank: bank,
      );

  factory ATM.fromOverpass(Map<String, dynamic> json) {
    final tags = (json['tags'] as Map<String, dynamic>?) ?? {};
    final rawName = tags['name'] ?? tags['operator'] ?? 'DAB';
    final name = rawName is String ? rawName : 'DAB';
    final rawOperator = tags['operator'] ?? 'Banque';
    final operator = rawOperator is String ? rawOperator : 'Banque';
    final opening = tags['opening_hours'] as String?;
    final isOpen24 = opening == '24/7';

    final services = <String>['Retrait'];
    if (tags['cash_in'] == 'yes') services.add('Dépôt');
    services.add('Relevé');

    return ATM(
      id: json['id'].toString(),
      name: name,
      address: _buildAddress(tags),
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      isOpen: true,
      hasDeposit: tags['cash_in'] == 'yes',
      hasCardless: tags['cardless'] == 'yes',
      phone: tags['phone'] as String?,
      hours: opening ?? (isOpen24 ? '24h/24 et 7j/7' : '08:00 - 18:00'),
      services: services,
      bank: operator,
    );
  }

  static String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber'] as String);
    if (tags['addr:street'] != null) parts.add(tags['addr:street'] as String);
    if (tags['addr:city'] != null) parts.add(tags['addr:city'] as String);
    return parts.isNotEmpty ? parts.join(', ') : 'Tunisie';
  }

  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1000) return '${distance!.round()}m';
    return '${(distance! / 1000).toStringAsFixed(1)}km';
  }
}
