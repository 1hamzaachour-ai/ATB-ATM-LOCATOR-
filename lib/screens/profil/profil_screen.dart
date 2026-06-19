import 'package:flutter/material.dart';
import '../../theme.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: ATBTheme.primary,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ATBTheme.primary, ATBTheme.primaryDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white24,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              child: const Text('S',
                                  style: TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                  color: ATBTheme.green, shape: BoxShape.circle),
                              child: const Icon(Icons.check, size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text('Sami Ben Ali',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const Text('sami.benali@atb.com.tn',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Badge(Icons.star_outline, 'Client VIP'),
                          const SizedBox(width: 8),
                          _Badge(Icons.verified_outlined, 'Compte Vérifié'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Informations Personnelles'),
                  _MenuItem(Icons.person_outline, 'Coordonnées',
                      'Modifier vos données de contact'),
                  _MenuItem(Icons.account_balance_outlined, 'Mes Comptes',
                      'Gérer vos comptes courants & épargne'),
                  _MenuItem(Icons.credit_card_outlined, 'Mes Cartes',
                      'Gérer vos cartes de crédit et DAB'),
                  const SizedBox(height: 8),
                  _SectionTitle('Préférences & Sécurité'),
                  _MenuItem(Icons.shield_outlined, 'Sécurité',
                      'Mot de passe, biométrie et 2FA'),
                  _MenuItem(Icons.notifications_outlined, 'Notifications',
                      'Alertes de solde et activités'),
                  _MenuItem(Icons.language_outlined, 'Langue',
                      'Français (Tunisie)'),
                  const SizedBox(height: 8),
                  _SectionTitle('Assistance'),
                  _MenuItem(Icons.help_outline, 'Aide & Support',
                      'FAQ et centre d\'assistance'),
                  _MenuItem(Icons.info_outline, 'Mentions Légales',
                      'Conditions d\'utilisation'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, color: ATBTheme.primary),
                      label: const Text('Se déconnecter',
                          style: TextStyle(color: ATBTheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ATBTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ATBTheme.textSecondary)),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _MenuItem(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ATBTheme.divider),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ATBTheme.chipBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ATBTheme.primary, size: 20),
          ),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle,
              style:
                  const TextStyle(fontSize: 12, color: ATBTheme.textSecondary)),
          trailing: const Icon(Icons.chevron_right,
              color: ATBTheme.textSecondary, size: 20),
          onTap: () {},
        ),
      );
}
