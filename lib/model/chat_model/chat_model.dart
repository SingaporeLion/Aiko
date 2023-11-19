import 'package:hive/hive.dart';
import 'package:flutter/widgets.dart';

part 'chat_model.g.dart'; // Hive generiert diesen Teil

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String? text;

  // Speichern des Enum-Werts als String
  @HiveField(1)
  final String chatMessageTypeString;

  @HiveField(2)
  final bool isTemporary;

  ChatMessageType get chatMessageType => ChatMessageType.values.firstWhere(
        (e) => e.toString() == 'ChatMessageType.$chatMessageTypeString',
    orElse: () => ChatMessageType.user, // Setzen Sie Ihren Standard-Enum-Wert hier
  );

  ChatMessage({
    this.text,
    required ChatMessageType chatMessageType,
    this.isTemporary = false,
  }) : chatMessageTypeString = chatMessageType.toString().split('.').last;
}

enum ChatMessageType {
  user,
  bot
}