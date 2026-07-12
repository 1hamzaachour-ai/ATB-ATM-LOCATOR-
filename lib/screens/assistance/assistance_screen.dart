import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/atm.dart';
import '../../models/chat_message.dart';
import '../../services/atm_service.dart';
import '../../services/chat_service.dart';
import '../../services/location_service.dart';
import '../../theme.dart';
import '../atm_detail/atm_detail_screen.dart';

class AssistanceScreen extends StatefulWidget {
  const AssistanceScreen({super.key});

  @override
  State<AssistanceScreen> createState() => _AssistanceScreenState();
}

class _AssistanceScreenState extends State<AssistanceScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  List<ATM> _nearbyATMs = [];
  bool _typing = false;

  final _suggestions = [
    'Où se trouve le DAB le plus proche ?',
    'DAB avec service de dépôt ?',
    'Est-ce qu\'il est ouvert ?',
    'Les commissions de retrait ?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Aslema! Ana assistant ATB. Kifesh naaounek lyoum? 😊',
      isUser: false,
    ));
    _loadATMs();
  }

  Future<void> _loadATMs() async {
    final pos = await LocationService.getCurrentPosition();
    final atms = await ATMService.fetchNearbyATMs(
      lat: pos?.latitude,
      lon: pos?.longitude,
      radiusKm: 20,
    );
    if (mounted) setState(() => _nearbyATMs = atms);
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _typing = true;
    });
    _scrollToBottom();

    final reply = await ChatService.sendMessage(text, _messages, _nearbyATMs);

    // Check if reply mentions an ATM
    ATM? mentionedATM;
    if (_nearbyATMs.isNotEmpty) {
      for (final atm in _nearbyATMs) {
        if (reply.contains(atm.name)) {
          mentionedATM = atm;
          break;
        }
      }
    }

    if (mounted) {
      setState(() {
        _typing = false;
        _messages.add(ChatMessage(text: reply, isUser: false, atmCard: mentionedATM));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assistance IA'),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF4CAF50)),
                    SizedBox(width: 4),
                    Text('En ligne pour vous aider',
                        style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Text('S',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, i) {
                if (_typing && i == _messages.length) {
                  return _TypingIndicator();
                }
                return _MessageBubble(
                  msg: _messages[i],
                  onATMTap: (atm) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ATMDetailScreen(atm: atm)),
                  ),
                );
              },
            ),
          ),
          // Suggestion chips (only show when few messages)
          if (_messages.length <= 2)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestions.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _send(_suggestions[i]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ATBTheme.chipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ATBTheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(_suggestions[i],
                        style: const TextStyle(
                            fontSize: 12, color: ATBTheme.primary)),
                  ),
                ),
              ),
            ),
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.psychology_outlined,
                    size: 16, color: ATBTheme.primary),
                const SizedBox(width: 6),
                _quickChip('DAB Ouverts', () => _send('Quels DABs sont ouverts maintenant?')),
                const SizedBox(width: 6),
                _quickChip('Retrait sans carte', () => _send('Y\'a-t-il des DABs avec retrait sans carte?')),
                const SizedBox(width: 6),
                _quickChip('Commissions', () => _send('Quelles sont les commissions de retrait?')),
              ],
            ),
          ),
          // Input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _send,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      prefixIcon: const Icon(Icons.psychology_outlined,
                          color: ATBTheme.primary, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(_controller.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: ATBTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: ATBTheme.chipBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ATBTheme.primary.withValues(alpha: 0.2)),
          ),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 11, color: ATBTheme.primary)),
        ),
      );
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final void Function(ATM) onATMTap;
  const _MessageBubble({required this.msg, required this.onATMTap});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: ATBTheme.chipBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: ATBTheme.primary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? ATBTheme.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : ATBTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (msg.atmCard != null) ...[
                  const SizedBox(height: 8),
                  _ATMCard(atm: msg.atmCard!, onTap: () => onATMTap(msg.atmCard!)),
                ],
                const SizedBox(height: 2),
                Text(
                  '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: ATBTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: ATBTheme.primary,
              child: Text('S',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ATMCard extends StatelessWidget {
  final ATM atm;
  final VoidCallback onTap;
  const _ATMCard({required this.atm, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ATBTheme.divider),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ATBTheme.chipBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: ATBTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(atm.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(atm.address,
                            style: const TextStyle(
                                fontSize: 11, color: ATBTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(
                            'https://www.google.com/maps/dir/?api=1&destination=${atm.lat},${atm.lon}');
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                      icon: const Icon(Icons.navigation_outlined, size: 14),
                      label: const Text('Itinéraire', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ATBTheme.primary,
                        side: const BorderSide(color: ATBTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.phone_outlined, size: 14),
                      label: const Text('Appeler', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ATBTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  color: ATBTheme.chipBg, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy, color: ATBTheme.primary, size: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, _) => Row(
                  children: List.generate(3, (i) {
                    final t = (_anim.value - i * 0.2).clamp(0.0, 1.0);
                    final y = -4 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                    return Transform.translate(
                      offset: Offset(0, y),
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: const BoxDecoration(
                            color: ATBTheme.primary, shape: BoxShape.circle),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
}
