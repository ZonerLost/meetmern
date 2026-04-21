import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';

class ChatMessageItem {
  final String id;
  final String text;
  final bool isMe;
  final String messageType; // 'text' | 'meetup_request' | 'system'
  final String? requestStatus; // 'pending' | 'accepted' | 'rejected'
  final String? meetupRequestId;

  const ChatMessageItem({
    required this.id,
    required this.text,
    required this.isMe,
    this.messageType = 'text',
    this.requestStatus,
    this.meetupRequestId,
  });
}

class MessageController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final List<ChatMessageItem> messages = <ChatMessageItem>[];

  Chat? chat;
  bool canSend = false;
  bool isLoading = false;

  // Supabase-backed state
  String? _chatId;
  String? _chatStatus;   // 'pending' | 'accepted' | 'rejected'
  String? _chatType;     // 'meetup' | 'direct'
  String? _requestId;
  String? _requestMessageId;

  String? get currentUserId => AuthService.currentUser?.id;

  /// True when the current user is the meetup owner for this chat.
  bool get isOwner {
    final uid = currentUserId;
    if (uid == null || chat == null) return false;
    return chat!.userOne == uid;
  }

  /// True when normal messaging is allowed.
  bool get messagingAllowed {
    if (_chatType == 'meetup') return _chatStatus == 'accepted';
    return true;
  }

  String get statusText {
    switch (_chatStatus) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Request Pending';
      default:
        // Fallback to enum-based status for mock chats
        switch (chat?.status) {
          case RequestStatus.accepted:
            return 'Accepted';
          case RequestStatus.rejected:
            return 'Rejected';
          case RequestStatus.requested:
            return 'Request Pending';
          default:
            return '';
        }
    }
  }

  /// The special meetup_request message, if present.
  ChatMessageItem? get requestCardMessage {
    for (final m in messages) {
      if (m.messageType == 'meetup_request') return m;
    }
    return null;
  }

  Future<void> init(Chat initialChat,
      {String? incoming, String? outgoing}) async {
    chat = initialChat;
    _chatId = initialChat.id;
    _chatStatus = initialChat.dbStatus;
    _chatType = initialChat.chatType;

    messageController.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);

    if (_chatId != null) {
      await _loadFromSupabase();
    } else {
      // Mock / local chat
      messages
        ..clear()
        ..add(ChatMessageItem(
            id: '1',
            text: incoming ?? 'Hi, nice to connect with you.',
            isMe: false))
        ..add(ChatMessageItem(
            id: '2',
            text: outgoing ?? 'Great, looking forward to meetup.',
            isMe: true));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    update();
  }

  Future<void> _loadFromSupabase() async {
    if (_chatId == null) return;
    isLoading = true;
    update();

    try {
      // Refresh chat status from DB
      final chatRow = await MeetupService.getChatById(_chatId!);
      if (chatRow != null) {
        _chatStatus = chatRow['status']?.toString();
        _chatType = chatRow['chat_type']?.toString();
        // Sync back to chat object
        chat = Chat.fromSupabase(
          chatRow,
          otherUserName: chat?.name ?? '',
          otherUserAvatar: chat?.avatarUrl ?? '',
          lastMessage: chat?.message ?? '',
        );
      }

      // Load request metadata
      final reqRow = await MeetupService.getRequestForChat(_chatId!);
      _requestId = reqRow?['id']?.toString();

      final reqMsg = await MeetupService.getRequestMessage(_chatId!);
      _requestMessageId = reqMsg?['id']?.toString();

      // Load all messages
      final rows = await MeetupService.fetchMessages(_chatId!);
      final uid = currentUserId ?? '';
      messages
        ..clear()
        ..addAll(rows.map((r) => ChatMessageItem(
              id: r['id']?.toString() ?? '',
              text: r['text']?.toString() ?? '',
              isMe: r['sender_id']?.toString() == uid,
              messageType: r['message_type']?.toString() ?? 'text',
              requestStatus: r['request_status']?.toString(),
              meetupRequestId: r['meetup_request_id']?.toString(),
            )));
    } catch (_) {
      // Keep empty messages on error
    }

    isLoading = false;
    update();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  void _onTextChanged() {
    final hasText =
        messageController.text.trim().isNotEmpty && messagingAllowed;
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

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || !messagingAllowed) return;

    final uid = currentUserId;

    if (_chatId != null && uid != null) {
      // Persist to Supabase
      try {
        await MeetupService.sendTextMessage(
          chatId: _chatId!,
          senderId: uid,
          text: text,
          chatStatus: _chatStatus ?? 'pending',
        );
        messageController.clear();
        await _loadFromSupabase();
      } catch (_) {
        // Optimistic fallback
        messages.add(ChatMessageItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: text,
            isMe: true));
        messageController.clear();
        update();
      }
    } else {
      // Mock chat
      messages.add(ChatMessageItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isMe: true));
      messageController.clear();
      update();
    }

    if (!focusNode.hasFocus) focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  Future<void> acceptRequest() async {
    if (_chatId == null || _requestId == null || _requestMessageId == null) {
      return;
    }
    try {
      await MeetupService.acceptRequest(
        requestId: _requestId!,
        chatId: _chatId!,
        requestMessageId: _requestMessageId!,
      );
      _chatStatus = 'accepted';
      // Update the request card message locally
      final idx =
          messages.indexWhere((m) => m.messageType == 'meetup_request');
      if (idx != -1) {
        messages[idx] = ChatMessageItem(
          id: messages[idx].id,
          text: messages[idx].text,
          isMe: messages[idx].isMe,
          messageType: 'meetup_request',
          requestStatus: 'accepted',
          meetupRequestId: messages[idx].meetupRequestId,
        );
      }
      update();
    } catch (_) {}
  }

  Future<void> rejectRequest() async {
    if (_chatId == null || _requestId == null || _requestMessageId == null) {
      return;
    }
    try {
      await MeetupService.rejectRequest(
        requestId: _requestId!,
        chatId: _chatId!,
        requestMessageId: _requestMessageId!,
      );
      _chatStatus = 'rejected';
      final idx =
          messages.indexWhere((m) => m.messageType == 'meetup_request');
      if (idx != -1) {
        messages[idx] = ChatMessageItem(
          id: messages[idx].id,
          text: messages[idx].text,
          isMe: messages[idx].isMe,
          messageType: 'meetup_request',
          requestStatus: 'rejected',
          meetupRequestId: messages[idx].meetupRequestId,
        );
      }
      update();
    } catch (_) {}
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
