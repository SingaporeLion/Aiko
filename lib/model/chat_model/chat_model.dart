import 'package:flutter/widgets.dart';

enum ChatMessageType { user, bot }

class ChatMessage {
  ChatMessage({
    this.text,
    this.widget,
    required this.chatMessageType,
  });

  final String? text;
  final Widget? widget;
  final ChatMessageType chatMessageType;
}