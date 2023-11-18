import 'package:hive/hive.dart';
import 'package:flutter/widgets.dart';

part 'chat_model.g.dart'; // Hive generiert diesen Teil

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String? text;

  @HiveField(1)
  final ChatMessageType chatMessageType;

  @HiveField(2)
  final bool isTemporary;

  // Optional: Wenn Sie Informationen über das Widget speichern müssen,
  // verwenden Sie stattdessen einen Enum oder String
  // @HiveField(3)
  // final String widgetType;

  ChatMessage({
    this.text,
    required this.chatMessageType,
    this.isTemporary = false,
  });
}

enum ChatMessageType {
  @HiveField(0)
  user,
  @HiveField(1)
  bot
}