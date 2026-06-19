import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/atm.dart';
import '../../services/atm_service.dart';
import '../../services/location_service.dart';
import '../../services/offline_map_service.dart';
import '../../services/mbtiles_tile_provider.dart';
import '../../theme.dart';
import '../atm_detail/atm_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  List<ATM> _atms = [];
  Position? _userPos;
  bool _loading = true;
  bool _filterOpen = false;
  bool _filterDeposit = false;
  bool _filterCardless = false;
  String _search = '';
  ATM? _selected;

  // Offline map state
  Database? _offlineDb;
  bool _isOffline = false;

  static const _tunisCenter = LatLng(36.8188, 10.1657);

  @override
  void initState() {
    super.initState();
    _loadOfflineDb();
    _loadData();
  }

  Future<void> _loadOfflineDb() async {
    final db = await OfflineMapService.openRegion('grand_tunis');
    if (db != null && mounted) {
      setState(() {
        _offlineDb = db;
        _isOffline = true;
      });
    }
  }

  Future<void> _loadData() async {
    final pos = await LocationService.getCurrentPosition();
    final atms = await ATMService.fetchNearbyATMs(
      lat: pos?.latitude,
      lon: pos?.longitude,
    );
    if (mounted) {
      setState(() {
        _userPos = pos;
        _atms = atms;
        _loading = false;
      });
      if (pos != null) {
        _mapController.move(LatLng(pos.latitude, pos.longitude), 13);
      }
    }
  }

  List<ATM> get _filtered {
    var list = _atms;
    if (_filterOpen) list = list.where((a) => a.isOpen).toList();
    if (_filterDeposit) list = list.where((a) => a.hasDeposit).toList();
    if (_filterCardless) list = list.where((a) => a.hasCardless).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((a) =>
          a.name.toLowerCase().contains(q) ||
          a.address.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _offlineDb?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cartes et DAB'),
            Text('Arab Tunisian Bank',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isOffline ? Icons.wifi_off : Icons.download_outlined,
              color: _isOffline ? Colors.greenAccent : Colors.white,
            ),
            tooltip: _isOffline
                ? 'Carte hors-ligne active'
                : 'Télécharger carte hors-ligne',
            onPressed: _showOfflineDialog,
          ),
          IconButton(
              icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Text('S',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _tunisCenter,
              initialZoom: 12,
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.atb.banking',
                tileProvider: _offlineDb != null
                    ? MBTilesTileProvider(_offlineDb!)
                    : NetworkTileProvider(),
                errorTileCallback: (tile, error, stack) {},
              ),
              if (_userPos != null)
                MarkerLayer(markers: [
                  Marker(
                    point:
                        LatLng(_userPos!.latitude, _userPos!.longitude),
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26, blurRadius: 6)
                        ],
                      ),
                    ),
                  ),
                ]),
              MarkerLayer(
                markers: _filtered.map((atm) {
                  final isSelected = _selected?.id == atm.id;
                  return Marker(
                    point: LatLng(atm.lat, atm.lon),
                    width: isSelected ? 48 : 36,
                    height: isSelected ? 48 : 36,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selected = atm);
                        _mapController.move(
                            LatLng(atm.lat, atm.lon), 15);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: atm.isOpen
                              ? ATBTheme.primary
                              : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.amber
                                : Colors.white,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (atm.isOpen
                                      ? ATBTheme.primary
                                      : Colors.grey)
                                  .withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(Icons.local_atm,
                            color: Colors.white,
                            size: isSelected ? 24 : 18),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Search bar
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8)
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: const InputDecoration(
                        hintText: 'Chercher un DAB ou une agen...',
                        prefixIcon: Icon(Icons.search,
                            color: ATBTheme.textSecondary),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8)
                      ],
                    ),
                    child:
                        const Icon(Icons.tune, color: ATBTheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // Offline banner
          if (_isOffline)
            Positioned(
              top: 72,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text('Carte hors-ligne',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),

          // Location FAB
          Positioned(
            bottom: _selected != null ? 180 : 80,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'location',
              onPressed: () {
                if (_userPos != null) {
                  _mapController.move(
                      LatLng(_userPos!.latitude, _userPos!.longitude),
                      15);
                } else {
                  _loadData();
                }
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location,
                  color: ATBTheme.primary),
            ),
          ),

          if (_loading)
            const Center(
                child:
                    CircularProgressIndicator(color: ATBTheme.primary)),

          if (_selected != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ATMBottomCard(
                atm: _selected!,
                onDetail: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ATMDetailScreen(atm: _selected!)),
                ),
                onClose: () => setState(() => _selected = null),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _FilterBar(
        filterOpen: _filterOpen,
        filterDeposit: _filterDeposit,
        filterCardless: _filterCardless,
        onToggleOpen: () =>
            setState(() => _filterOpen = !_filterOpen),
        onToggleDeposit: () =>
            setState(() => _filterDeposit = !_filterDeposit),
        onToggleCardless: () =>
            setState(() => _filterCardless = !_filterCardless),
      ),
    );
  }

  Future<void> _showOfflineDialog() async {
    final region = TunisiaRegions.grandTunis;
    final alreadyDownloaded =
        await OfflineMapService.regionExists(region.name);

    if (!mounted) return;

    if (alreadyDownloaded) {
      final fileSize =
          await OfflineMapService.regionFileSize(region.name);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.wifi_off, color: ATBTheme.primary),
              SizedBox(width: 10),
              Text('Carte Hors-Ligne'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.check_circle,
                  'Grand Tunis téléchargé', Colors.green),
              _infoRow(Icons.storage, 'Taille : $fileSize',
                  ATBTheme.textSecondary),
              _infoRow(Icons.zoom_in, 'Zoom : niveaux 10–15',
                  ATBTheme.textSecondary),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await OfflineMapService.deleteRegion(region.name);
                _offlineDb?.close();
                if (mounted) {
                  setState(() {
                    _offlineDb = null;
                    _isOffline = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Carte hors-ligne supprimée')),
                  );
                }
              },
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ATBTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download_outlined, color: ATBTheme.primary),
            SizedBox(width: 10),
            Text('Télécharger la carte'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.map, 'Zone : Grand Tunis',
                ATBTheme.textSecondary),
            _infoRow(Icons.zoom_in, 'Zoom : niveaux 10–15',
                ATBTheme.textSecondary),
            _infoRow(
                Icons.grid_on,
                'Tuiles : ~${region.estimateTileCount()}',
                ATBTheme.textSecondary),
            _infoRow(Icons.storage,
                'Taille estimée : ${region.estimatedSize()}',
                Colors.orange),
            const SizedBox(height: 8),
            const Text(
              'La carte sera disponible sans connexion internet.',
              style: TextStyle(
                  fontSize: 12, color: ATBTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ATBTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    _startDownload(region);
  }

  void _startDownload(OfflineRegion region) {
    final cancelToken = CancelToken();
    int done = 0;
    int total = region.estimateTileCount();
    // flag ensures download starts only once, not on every StatefulBuilder rebuild
    bool started = false;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          if (!started) {
            started = true;
            OfflineMapService.downloadRegion(
              region: region,
              cancelToken: cancelToken,
              onProgress: (d, t) {
                if (ctx.mounted) setS(() { done = d; total = t; });
              },
            ).then((_) async {
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              await _loadOfflineDb();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Carte téléchargée — disponible hors-ligne ✅'),
                    ]),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }).catchError((_) {
              if (ctx.mounted) Navigator.pop(ctx);
            });
          }

          final progress = total > 0 ? done / total : 0.0;
          final pct = (progress * 100).toInt();

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.download_outlined,
                        color: ATBTheme.primary),
                    const SizedBox(width: 10),
                    const Text('Téléchargement en cours…',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('$pct%',
                        style: const TextStyle(
                            color: ATBTheme.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        ATBTheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text('$done / $total tuiles',
                    style: const TextStyle(
                        fontSize: 12,
                        color: ATBTheme.textSecondary)),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    cancelToken.cancel();
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.red),
                  label: const Text('Annuler',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(text,
                style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      );

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.tune, color: ATBTheme.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Filtrer',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20),
              _FilterOption(
                'DAB Ouvert',
                'Afficher uniquement les DABs ouverts',
                _filterOpen,
                (v) {
                  setS(() => _filterOpen = v);
                  setState(() {});
                },
              ),
              _FilterOption(
                'DAB avec Dépôt',
                'Afficher les DABs avec module de dépôt',
                _filterDeposit,
                (v) {
                  setS(() => _filterDeposit = v);
                  setState(() {});
                },
              ),
              _FilterOption(
                'Retrait sans carte',
                'Afficher les DABs sans carte bancaire',
                _filterCardless,
                (v) {
                  setS(() => _filterCardless = v);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _FilterOption(
      this.title, this.subtitle, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: ATBTheme.textSecondary)),
        trailing: Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: ATBTheme.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
        ),
      );
}

class _FilterBar extends StatelessWidget {
  final bool filterOpen;
  final bool filterDeposit;
  final bool filterCardless;
  final VoidCallback onToggleOpen;
  final VoidCallback onToggleDeposit;
  final VoidCallback onToggleCardless;

  const _FilterBar({
    required this.filterOpen,
    required this.filterDeposit,
    required this.filterCardless,
    required this.onToggleOpen,
    required this.onToggleDeposit,
    required this.onToggleCardless,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            _chip('DAB Ouverts', filterOpen, onToggleOpen),
            const SizedBox(width: 8),
            _chip('Avec Dépôt', filterDeposit, onToggleDeposit),
            const SizedBox(width: 8),
            _chip('Sans Carte', filterCardless, onToggleCardless),
          ],
        ),
      );

  Widget _chip(String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? ATBTheme.chipBg : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? ATBTheme.primary
                  : const Color(0xFFDDDDDD),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active) ...[
                const Icon(Icons.check,
                    size: 14, color: ATBTheme.primary),
                const SizedBox(width: 4),
              ],
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: active
                          ? ATBTheme.primary
                          : ATBTheme.textSecondary)),
            ],
          ),
        ),
      );
}

class _ATMBottomCard extends StatelessWidget {
  final ATM atm;
  final VoidCallback onDetail;
  final VoidCallback onClose;
  const _ATMBottomCard(
      {required this.atm, required this.onDetail, required this.onClose});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ATBTheme.chipBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on_outlined,
                      color: ATBTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(atm.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      Text(atm.address,
                          style: const TextStyle(
                              fontSize: 12,
                              color: ATBTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onClose),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=${atm.lat},${atm.lon}');
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    icon: const Icon(Icons.navigation_outlined,
                        size: 16),
                    label: const Text('Itinéraire'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ATBTheme.primary,
                      side: const BorderSide(color: ATBTheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ATBTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Détails'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
