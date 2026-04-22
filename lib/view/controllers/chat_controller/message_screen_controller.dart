import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/main.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_screen_controller.dart';

class ChatMessageItem {
  final String id;
  final String text;
  final bool isMe;
  final String messageType;
  final String? requestStatus;
  final String? meetupRequestId;
  final String? meetupId;

  const ChatMessageItem({
    required this.id,
    required this.text,
    required this.isMe,
    this.messageType = 'text',
    this.requestStatus,
    this.meetupRequestId,
    this.meetupId,
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
  bool _isBlockedConversation = false;
  String _blockedConversationText = '';

  // Supabase-backed state
  String? _chatId;
  String? _chatStatus; // 'pending' | 'accepted' | 'rejected'
  String? _chatType; // 'meetup' | 'direct'
  String? _requestId;
  String? _requestMessageId;
  StreamSubscription<List<Map<String, dynamic>>>? _chatSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;
  bool _isRealtimeReloadInProgress = false;
  bool _hasPendingRealtimeReload = false;

  String? get currentUserId => AuthService.currentUser?.id;

  /// True when the current user is the meetup owner for this chat.
  bool get isOwner {
    final uid = currentUserId;
    if (uid == null || chat == null) return false;
    return chat!.userOne == uid;
  }

  /// True when request action buttons should be shown.
  bool get canRespondToMeetupRequest {
    return isOwner && _chatType == 'meetup' && _chatStatus == 'pending';
  }

  /// True when normal messaging is allowed.
  bool get messagingAllowed {
    if (_isBlockedConversation) return false;
    if (_chatType == 'meetup') return _chatStatus == 'accepted';
    return true;
  }

  bool get isBlockedConversation => _isBlockedConversation;
  String get blockedConversationText => _blockedConversationText.isNotEmpty
      ? _blockedConversationText
      : 'You cannot message this user because one of you has blocked the other.';

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
      _startRealtimeListeners();
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

  void _startRealtimeListeners() {
    if (_chatId == null) return;

    _chatSubscription?.cancel();
    _messageSubscription?.cancel();

    _chatSubscription = supabase
        .from('chats')
        .stream(primaryKey: const ['id'])
        .eq('id', _chatId!)
        .listen((_) => _reloadFromRealtime());

    _messageSubscription = supabase
        .from('messages')
        .stream(primaryKey: const ['id'])
        .eq('chat_id', _chatId!)
        .listen((_) => _reloadFromRealtime());
  }

  Future<void> _reloadFromRealtime() async {
    if (_isRealtimeReloadInProgress) {
      _hasPendingRealtimeReload = true;
      return;
    }
    _isRealtimeReloadInProgress = true;
    try {
      await _loadFromSupabase(showLoader: false);
    } finally {
      _isRealtimeReloadInProgress = false;
      if (_hasPendingRealtimeReload) {
        _hasPendingRealtimeReload = false;
        _reloadFromRealtime();
      }
    }
  }

  Future<void> _loadFromSupabase({bool showLoader = true}) async {
    if (_chatId == null) return;
    if (showLoader) {
      isLoading = true;
      update();
    }

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

      await _refreshBlockState();

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
        ..addAll(rows.map((r) {
          final isMe = r['sender_id']?.toString() == uid;
          final messageType = r['message_type']?.toString() ?? 'text';
          String text = r['text']?.toString() ?? '';
          String? requestStatus = r['request_status']?.toString();

          if (messageType == 'meetup_request') {
            if ((requestStatus == null ||
                    requestStatus.isEmpty ||
                    requestStatus == 'pending') &&
                (_chatStatus == 'accepted' || _chatStatus == 'rejected')) {
              requestStatus = _chatStatus;
            }

            if (text.trim().toLowerCase() == 'sent you a meetup request') {
              text = isMe
                  ? 'You sent a meetup request'
                  : 'Sent you a meetup request';
            }
          }

          return ChatMessageItem(
            id: r['id']?.toString() ?? '',
            text: text,
            isMe: isMe,
            messageType: messageType,
            requestStatus: requestStatus,
            meetupRequestId: r['meetup_request_id']?.toString(),
            meetupId: r['meetup_id']?.toString(),
          );
        }));
    } catch (_) {
      // Keep empty messages on error
    }

    if (showLoader) {
      isLoading = false;
    }
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
        await _loadFromSupabase(showLoader: false);
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

  Future<void> _refreshBlockState() async {
    final uid = currentUserId;
    final c = chat;

    _isBlockedConversation = false;
    _blockedConversationText = '';

    if (uid == null || c == null) return;

    final otherId = c.userOne == uid ? c.userTwo : c.userOne;
    if (otherId == null || otherId.isEmpty) return;

    try {
      final blocked =
          await MeetupService.areUsersBlocked(userA: uid, userB: otherId);
      _isBlockedConversation = blocked;
      if (blocked) {
        _blockedConversationText =
            'You cannot message this user because one of you has blocked the other.';
      }
    } catch (_) {
      _isBlockedConversation = false;
    }

    canSend = messageController.text.trim().isNotEmpty && messagingAllowed;
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
      for (var i = 0; i < messages.length; i++) {
        if (messages[i].messageType != 'meetup_request') continue;
        final m = messages[i];
        messages[i] = ChatMessageItem(
          id: m.id,
          text: m.text,
          isMe: m.isMe,
          messageType: 'meetup_request',
          requestStatus: 'accepted',
          meetupRequestId: m.meetupRequestId,
          meetupId: m.meetupId,
        );
      }
      if (Get.isRegistered<ChatListController>()) {
        await Get.find<ChatListController>().loadChats(showLoader: false);
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
      for (var i = 0; i < messages.length; i++) {
        if (messages[i].messageType != 'meetup_request') continue;
        final m = messages[i];
        messages[i] = ChatMessageItem(
          id: m.id,
          text: m.text,
          isMe: m.isMe,
          messageType: 'meetup_request',
          requestStatus: 'rejected',
          meetupRequestId: m.meetupRequestId,
          meetupId: m.meetupId,
        );
      }
      if (Get.isRegistered<ChatListController>()) {
        await Get.find<ChatListController>().loadChats(showLoader: false);
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
    _chatSubscription?.cancel();
    _messageSubscription?.cancel();
    messageController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
