import 'package:flutter/material.dart';
import '../../theme.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _filter = 0;
  final _filters = ['Tous', 'Banque', 'Sécurité', 'Contacts'];

  final _messages = const [
    _Msg('ATB – Service Client', 'Virement reçu',
        'Votre virement de 450,000 TND a été crédité sur votre compte courant.',
        '10:45', true, false, Icons.account_balance),
    _Msg('Sami (Père)', 'Dépôt au DAB',
        'J\'ai déposé les documents pour le renouvellement de ma carte bancaire ce matin.',
        '09:12', true, true, Icons.person_outline),
    _Msg('ATB – Service Client', 'Alerte Sécurité',
        'Une nouvelle connexion à votre espace client a été détectée depuis Tunis.',
        'Hier', false, false, Icons.account_balance),
    _Msg('Assistance ATB', 'Réponse à votre demande',
        'Votre demande concernant le blocage de carte a été traitée avec succès.',
        'Hier', false, false, Icons.account_balance),
    _Msg('Mme. Ben Ali', 'Projet Immobilier',
        'Pouvez-vous me confirmer la date d\'ouverture du crédit pour le projet...',
        'Hier', false, true, Icons.person_outline),
    _Msg('ATB – Service Client', 'Échéance crédit',
        'Votre prochaine échéance de crédit de 320 TND est due le 15/06/2026.',
        'Lun', false, false, Icons.account_balance),
    _Msg('Ahmed (Frère)', 'Virement',
        'Est-ce que tu peux m\'envoyer 50 TND? Merci.',
        'Dim', false, true, Icons.person_outline),
  ];

  List<_Msg> get _filtered {
    if (_filter == 0) return _messages;
    if (_filter == 1) return _messages.where((m) => !m.isContact).toList();
    if (_filter == 2) return _messages.where((m) => m.subtitle.contains('Sécurité') || m.subtitle.contains('Alerte')).toList();
    return _messages.where((m) => m.isContact).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Messages'),
            Text('Vos notifications bancaires',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: ATBTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: List.generate(_filters.length, (i) {
                final sel = i == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        if (sel) ...[
                          const Icon(Icons.check, size: 14, color: ATBTheme.primary),
                          const SizedBox(width: 4),
                        ],
                        Text(_filters[i],
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sel ? ATBTheme.primary : Colors.white)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: _buildGrouped(),
      ),
    );
  }

  List<Widget> _buildGrouped() {
    final today = _filtered.where((m) => m.time.contains(':')).toList();
    final yesterday = _filtered.where((m) => m.time == 'Hier').toList();
    final older = _filtered.where((m) => m.time == 'Lun' || m.time == 'Dim').toList();

    final widgets = <Widget>[];
    if (today.isNotEmpty) {
      widgets.add(_groupHeader("Aujourd'hui"));
      widgets.addAll(today.map(_buildTile));
    }
    if (yesterday.isNotEmpty) {
      widgets.add(_groupHeader('Hier'));
      widgets.addAll(yesterday.map(_buildTile));
    }
    if (older.isNotEmpty) {
      widgets.add(_groupHeader('Cette semaine'));
      widgets.addAll(older.map(_buildTile));
    }
    return widgets;
  }

  Widget _groupHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ATBTheme.textSecondary)),
      );

  Widget _buildTile(_Msg m) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: m.isUnread ? ATBTheme.primary.withOpacity(0.2) : ATBTheme.divider),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: m.isContact ? const Color(0xFFF0F0F0) : ATBTheme.primary,
            child: Icon(m.icon,
                color: m.isContact ? ATBTheme.textSecondary : Colors.white, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(m.sender,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: m.isUnread ? FontWeight.bold : FontWeight.w500)),
              ),
              Text(m.time,
                  style: TextStyle(
                      fontSize: 11,
                      color: m.isUnread ? ATBTheme.primary : ATBTheme.textSecondary)),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (m.isUnread)
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                          color: ATBTheme.primary, shape: BoxShape.circle),
                    ),
                  Text(m.subtitle,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: ATBTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 2),
              Text(m.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: ATBTheme.textSecondary)),
            ],
          ),
        ),
      );
}

class _Msg {
  final String sender;
  final String subtitle;
  final String body;
  final String time;
  final bool isUnread;
  final bool isContact;
  final IconData icon;
  const _Msg(this.sender, this.subtitle, this.body, this.time, this.isUnread,
      this.isContact, this.icon);
}
