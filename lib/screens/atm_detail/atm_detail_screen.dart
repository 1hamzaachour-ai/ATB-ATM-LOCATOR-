import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/atm.dart';
import '../../theme.dart';

class ATMDetailScreen extends StatelessWidget {
  final ATM atm;
  const ATMDetailScreen({super.key, required this.atm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: ATBTheme.primary,
            title: const Text('Détails du DAB'),
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(atm.lat, atm.lon),
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.atb.banking',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(atm.lat, atm.lon),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ATBTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 6)
                          ],
                        ),
                        child: const Icon(Icons.local_atm, color: Colors.white, size: 20),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(atm.name,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: atm.isOpen ? ATBTheme.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    atm.isOpen ? 'Ouvert actuellement' : 'Fermé actuellement',
                                    style: TextStyle(
                                        color: atm.isOpen ? ATBTheme.green : Colors.red,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (atm.distanceText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ATBTheme.chipBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(atm.distanceText,
                                style: const TextStyle(
                                    color: ATBTheme.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(Icons.location_on_outlined, 'Adresse', atm.address),
                  _InfoRow(Icons.access_time_outlined, 'Horaires', atm.hours),
                  _InfoRow(Icons.payment_outlined, 'Services disponibles',
                      atm.services.join(', ')),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _ActionButton(
                          icon: Icons.directions_outlined,
                          label: 'Obtenir l\'itinéraire',
                          onTap: () => _openMaps(atm.lat, atm.lon, atm.name),
                        ),
                        const SizedBox(height: 10),
                        _ActionButton(
                          icon: Icons.phone_outlined,
                          label: 'Contacter l\'agence',
                          onTap: () {
                            if (atm.phone != null) {
                              launchUrl(Uri.parse('tel:${atm.phone}'));
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _ActionButton(
                          icon: Icons.chat_outlined,
                          label: 'Demander de l\'assistance',
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ATBTheme.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: ATBTheme.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ce distributeur est équipé de la technologie Chip & PIN.',
                              style: const TextStyle(
                                  fontSize: 12, color: ATBTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMaps(double lat, double lon, String label) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ATBTheme.chipBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: ATBTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: ATBTheme.textSecondary)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ATBTheme.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ATBTheme.chipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: ATBTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const Icon(Icons.chevron_right,
                  color: ATBTheme.textSecondary, size: 20),
            ],
          ),
        ),
      );
}
