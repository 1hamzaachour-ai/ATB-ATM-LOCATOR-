import 'atm.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final ATM? atmCard;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
    this.atmCard,
  }) : time = time ?? DateTime.now();
}
