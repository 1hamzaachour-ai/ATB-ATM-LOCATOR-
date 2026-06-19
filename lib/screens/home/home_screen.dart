import 'package:flutter/material.dart';
import '../../theme.dart';
import '../map/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: ATBTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ATBTheme.primary, ATBTheme.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text('ATB',
                                        style: TextStyle(
                                            color: ATBTheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('Arab Tunisian Bank',
                                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined,
                                      color: Colors.white),
                                  onPressed: () {},
                                ),
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white24,
                                  child: Text('S',
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Bonjour, Sami !',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const Text('Compte courant · **** 4242',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
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
                  _balanceCard(),
                  const SizedBox(height: 20),
                  const Text('Actions rapides',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ATBTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _quickActions(context),
                  const SizedBox(height: 20),
                  const Text('Dernières transactions',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ATBTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _transactionList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ATBTheme.primary, ATBTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: ATBTheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solde disponible',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          const Text('4 250,000 TND',
              style: TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _balanceStat('Revenus', '+ 1 200 TND', Icons.arrow_downward),
              _balanceStat('Dépenses', '- 320 TND', Icons.arrow_upward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      ('Virement', Icons.send_outlined),
      ('Paiement', Icons.payment_outlined),
      ('DAB', Icons.location_on_outlined),
      ('Recharge', Icons.phone_android_outlined),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return GestureDetector(
          onTap: a.$1 == 'DAB'
              ? () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MapScreen()))
              : null,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ATBTheme.chipBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(a.$2, color: ATBTheme.primary, size: 24),
              ),
              const SizedBox(height: 6),
              Text(a.$1,
                  style: const TextStyle(fontSize: 12, color: ATBTheme.textSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _transactionList() {
    final transactions = [
      ('Carrefour Market', '- 45,300 TND', Icons.shopping_cart_outlined, '12 Juin'),
      ('Virement reçu', '+ 450,000 TND', Icons.arrow_downward, '12 Juin'),
      ('STEG Facture', '- 78,500 TND', Icons.flash_on_outlined, '11 Juin'),
      ('Restaurant Dar Zarrouk', '- 32,000 TND', Icons.restaurant_outlined, '10 Juin'),
      ('ATM Retrait', '- 200,000 TND', Icons.local_atm_outlined, '09 Juin'),
    ];
    return Column(
      children: transactions.map((t) {
        final isCredit = t.$2.startsWith('+');
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ATBTheme.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ATBTheme.chipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(t.$3, color: ATBTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.$1,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    Text(t.$4,
                        style: const TextStyle(
                            fontSize: 12, color: ATBTheme.textSecondary)),
                  ],
                ),
              ),
              Text(t.$2,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCredit ? ATBTheme.green : ATBTheme.textPrimary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
