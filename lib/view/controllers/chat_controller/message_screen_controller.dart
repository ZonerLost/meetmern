import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/chat_model.dart';

class ChatMessageItem {
  final String text;
  final bool isMe;

  const ChatMessageItem({required this.text, required this.isMe});
}

class MessageController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final List<ChatMessageItem> messages = <ChatMessageItem>[];

  Chat? chat;
  bool canSend = false;

  void init(Chat initialChat, {String? incoming, String? outgoing}) {
    chat = initialChat;
    messages
      ..clear()
      ..add(ChatMessageItem(text: incoming ?? 'Hi, nice to connect with you.', isMe: false))
      ..add(ChatMessageItem(text: outgoing ?? 'Great, looking forward to meetup.', isMe: true));

    messageController.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    update();
  }

  String get statusText {
    switch (chat?.status) {
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.requested:
        return 'Request Pending';
      case RequestStatus.none:
      default:
        return '';
    }
  }

  void _onTextChanged() {
    final hasText = messageController.text.trim().isNotEmpty;
    if (hasText != canSend) {
      canSend = hasText;
      update();
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    }
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messages.add(ChatMessageItem(text: text, isMe: true));
    messageController.clear();
    if (!focusNode.hasFocus) focusNode.requestFocus();
    update();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  void clearConversation() {
    messages.clear();
    update();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;
    try {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } catch (_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  @override
  void onClose() {
    messageController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
