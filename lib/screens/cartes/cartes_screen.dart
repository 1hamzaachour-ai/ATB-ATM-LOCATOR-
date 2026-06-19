import 'package:flutter/material.dart';
import '../../theme.dart';

class CartesScreen extends StatefulWidget {
  const CartesScreen({super.key});

  @override
  State<CartesScreen> createState() => _CartesScreenState();
}

class _CartesScreenState extends State<CartesScreen> {
  int _selectedCard = 0;

  final _cards = const [
    _CardData('**** **** **** 4242', 'SAMI BEN ALI', '12/26', 'VISA'),
    _CardData('**** **** **** 7891', 'SAMI BEN ALI', '08/28', 'MASTERCARD'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mes Cartes'),
            Text('Gestion des moyens de paiement',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 190,
              child: PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.85),
                itemCount: _cards.length,
                onPageChanged: (i) => setState(() => _selectedCard = i),
                itemBuilder: (context, i) => Padding(
                  padding: EdgeInsets.only(
                      left: i == 0 ? 16 : 8, right: i == _cards.length - 1 ? 16 : 8),
                  child: _BankCard(_cards[i], isSelected: i == _selectedCard),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _cards.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _selectedCard ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _selectedCard ? ATBTheme.primary : const Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Mes services associés',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: const [
                  _ServiceTile('Paiement Mobile', Icons.phone_android_outlined),
                  _ServiceTile('Sécurité Cartes', Icons.shield_outlined),
                  _ServiceTile('Historique', Icons.history_outlined),
                  _ServiceTile('Limites', Icons.tune_outlined),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  final String number;
  final String holder;
  final String expiry;
  final String network;
  const _CardData(this.number, this.holder, this.expiry, this.network);
}

class _BankCard extends StatelessWidget {
  final _CardData card;
  final bool isSelected;
  const _BankCard(this.card, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.96,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ATBTheme.primary, Color(0xFF4A0E1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: ATBTheme.primary.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
                ),
                Text(card.network,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ],
            ),
            const Spacer(),
            Text(card.number,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, letterSpacing: 2)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TITULAIRE',
                        style: TextStyle(color: Colors.white54, fontSize: 9)),
                    Text(card.holder,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EXPIRATION',
                        style: TextStyle(color: Colors.white54, fontSize: 9)),
                    Text(card.expiry,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ServiceTile(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ATBTheme.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ATBTheme.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ATBTheme.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
