import 'package:hive/hive.dart';
import 'package:flutter/widgets.dart';

part 'chat_model.g.dart'; // Hive generiert diesen Teil

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String? text;

  @HiveField(1)
  final String chatMessageTypeString; // Stellen Sie sicher, dass dies vorhanden ist

  @HiveField(2)
  final bool isTemporary;

  @HiveField(3)
  final DateTime timestamp;

  ChatMessageType get chatMessageType => ChatMessageType.values.firstWhere(
        (e) => e.toString() == 'ChatMessageType.$chatMessageTypeString',
    orElse: () => ChatMessageType.user, // Setzen Sie Ihren Standard-Enum-Wert hier
  );

  ChatMessage({
    this.text,
    required ChatMessageType chatMessageType,
    this.isTemporary = false,
    required this.timestamp, // Hinzugefügter Konstruktor-Parameter für den Zeitstempel
  }) : chatMessageTypeString = chatMessageType.toString().split('.').last;
}

enum ChatMessageType {
  user,
  bot
}