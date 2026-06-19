import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';
import '../models/atm.dart';
import '../models/chat_message.dart';

class ChatService {
  static const String _apiKey = groqApiKey;
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  static const String _systemPrompt = '''
You are an elite AI assistant for ATB (Arab Tunisian Bank) — hyper-efficient, expert in all ATB banking services, DABs, and agences across Tunisia. Your goal is to provide highly reliable, comprehensive, and definitive answers with zero conversational fluff.

LINGUISTIC ENGINE:
You are natively fluent in three modes and must dynamically mirror the user:
1. English: Direct, technical, and precise.
2. French: Natural, grammatically perfect, and professional.
3. Tunisian Arabic (Derja): Fully fluent in both Arabic script and Franco-Arabic (chat alphabet).
Seamlessly handle Tunisian code-switching (mixing Derja, French, and English in the same sentence). Use authentic local phrasing (e.g., "mrigel", "famma", "kifech", "barra", "mokhch problema") without sounding forced. NEVER reply in Modern Standard Arabic (Fus-ha) unless explicitly asked.

BANKING EXPERTISE:
- ATB DAB/ATM locations, services (retrait, dépôt, relevé, retrait sans carte), and hours
- ATB card management (blocage, limites, renouvellement)
- ATB account services (virements, paiements, épargne)
- Nearby ATM recommendations based on user location and filters
- Tunisian banking regulations and fees

OUTPUT RULES:
1. NO FLUFF: Never start with "Here is the answer" or end with "Let me know if you need help."
2. Start outputting the direct answer immediately.
3. Keep responses concise (max 4 sentences) and conversational.
4. Use emojis sparingly but naturally (📍 for location, ✅ for open, ❌ for closed).
5. If you lack specific data, say so and direct the user to call 71 110 500.
''';

  static Future<String> sendMessage(
    String userMessage,
    List<ChatMessage> history,
    List<ATM>? nearbyATMs,
  ) async {
    if (_apiKey == 'YOUR_GROQ_API_KEY') {
      await Future.delayed(const Duration(milliseconds: 800));
      return _mockResponse(userMessage, nearbyATMs);
    }

    try {
      var system = _systemPrompt;
      if (nearbyATMs != null && nearbyATMs.isNotEmpty) {
        final info = nearbyATMs.take(5).map((a) =>
          '- ${a.name} (${a.distanceText}): ${a.address}, ${a.isOpen ? "Ouvert" : "Fermé"}, ${a.hours}, Services: ${a.services.join(", ")}'
        ).join('\n');
        system += '\n\nLes DABs proches du client:\n$info';
      }

      final messages = <Map<String, String>>[
        {'role': 'system', 'content': system},
      ];

      final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
      for (final msg in recent) {
        messages.add({'role': msg.isUser ? 'user' : 'assistant', 'content': msg.text});
      }
      messages.add({'role': 'user', 'content': userMessage});

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 512,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['choices'][0]['message']['content'] as String;
      }
    } catch (_) {}

    return _mockResponse(userMessage, nearbyATMs);
  }

  static String _mockResponse(String msg, List<ATM>? atms) {
    final lower = msg.toLowerCase();

    if (lower.contains('bonjour') || lower.contains('salut') ||
        lower.contains('aslema') || lower.contains('hello') || lower.contains('salam')) {
      return 'Aslema! Ana assistant ATB, hna naaounek. Kifesh nkhedmek lyoum? 😊';
    }
    if (lower.contains('dépôt') || lower.contains('depot') || lower.contains('dab avec')) {
      final deposits = atms?.where((a) => a.hasDeposit).take(2).toList() ?? [];
      if (deposits.isNotEmpty) {
        final a = deposits.first;
        return 'Barra! "${a.name}" ${a.distanceText} men andek 3andha module dépôt. Maftouha ${a.hours}. Tħeb l\'itinéraire?';
      }
      return 'El agence Tunis Marine w Tunis City Centre 3andhom module dépôt. Fouq el carte trahoma!';
    }
    if (lower.contains('proche') || lower.contains('akreb') ||
        lower.contains('où') || lower.contains('feen') || lower.contains('trouver')) {
      if (atms != null && atms.isNotEmpty) {
        final a = atms.first;
        return '"${a.name}" hiya el akreb - ${a.distanceText} men andek. ${a.isOpen ? "Maftouha taw ✅" : "Mosdoudha taw ❌"} - ${a.services.join(", ")}.';
      }
      return 'Famma barcha DABs ATB fi Tunis. Fouq el carte trahoma kollhom!';
    }
    if (lower.contains('ouvert') || lower.contains('maftou') || lower.contains('ferm') || lower.contains('horaire')) {
      return 'El barcha mte3 DABs ATB maftouhin 24/7. Les agences maftouhin men 8h l 18h, letnin l jom3a.';
    }
    if (lower.contains('carte') || lower.contains('bloqu') || lower.contains('perdu')) {
      return 'Mochkla fi carte? Tnajem tblokiha directement mel tab "Cartes" ← "Sécurité Cartes". Wella kel 71 110 500 taw!';
    }
    if (lower.contains('retrait') || lower.contains('argent') || lower.contains('flous')) {
      return 'Koll les DABs ATB 3andhom service retrait. El limite yomiya hiya 1000 TND. Tħeb taaref ekthar?';
    }
    if (lower.contains('merci') || lower.contains('chokran') || lower.contains('yeslem')) {
      return 'Afw! Eni hna ki yhjek ay ħaja ukhra. Baraka Lahu fik! 🙏';
    }
    if (lower.contains('commission') || lower.contains('frais')) {
      return 'Les retraits fil DABs ATB bech carte ATB bela frais. Les autres banques: 1 TND fel retrait.';
    }
    return 'Fhamtk! Tnajem tfilter el DABs bel carte lysar (maftou / dépôt / retrait sans carte). Ay ħaja ukhra naaounek fiha?';
  }
}
