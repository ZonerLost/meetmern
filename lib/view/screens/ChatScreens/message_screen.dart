import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/chat_controller/message_screen_controller.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/view/screens/chatscreens/chat_detail_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class MessageScreen extends StatefulWidget {
  final Chat chat;
  const MessageScreen({required this.chat, super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late final MessageController _c;
  late final String _controllerTag;

  @override
  void initState() {
    super.initState();
    _controllerTag = widget.chat.id ?? 'local_${widget.hashCode}';
    if (Get.isRegistered<MessageController>(tag: _controllerTag)) {
      _c = Get.find<MessageController>(tag: _controllerTag);
    } else {
      _c = Get.put(MessageController(), tag: _controllerTag);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.init(widget.chat));
  }

  @override
  void dispose() {
    if (Get.isRegistered<MessageController>(tag: _controllerTag)) {
      Get.delete<MessageController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const strings = Strings();

    return GetBuilder<MessageController>(
      tag: _controllerTag,
      init: _c,
      builder: (c) {
        final customThemeData =
            ThemeHelper(appThemeName: strings.lightCode).themeData;
        final styles = CustomButtonStyles(
            apppTheme: Theme.of(context), theme: customThemeData);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: appTheme.coreWhite,
            appBar: _buildAppBar(context, c, strings),
            body: SafeArea(
              bottom: false,
              child: c.isLoading && c.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: ListView.builder(
                            controller: c.scrollController,
                            padding: EdgeInsets.only(
                                top: dimension.d8, bottom: dimension.d92),
                            itemCount: c.messages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _buildStatusHeader(c, strings);
                              }
                              final msg = c.messages[index - 1];
                              if (msg.messageType == 'meetup_request') {
                                return _buildRequestCard(
                                    context, c, msg, styles, strings);
                              }
                              if (msg.messageType == 'system') {
                                return _buildSystemMessage(msg);
                              }
                              return _buildMessageBubble(context, msg);
                            },
                          ),
                        ),
                        Positioned(
                          left: dimension.d0,
                          right: dimension.d0,
                          bottom: dimension.d0,
                          child: _buildComposer(context, c, styles, strings),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, MessageController c, Strings strings) {
    final displayChat = c.chat ?? widget.chat;
    final avatarWidget = displayChat.avatarUrl.isNotEmpty
        ? CircleAvatar(
            radius: dimension.d18,
            backgroundImage: NetworkImage(displayChat.avatarUrl))
        : CircleAvatar(
            radius: dimension.d18,
            backgroundColor: appTheme.neutral_400,
            child: Text(
              displayChat.name
                  .split(' ')
                  .where((s) => s.isNotEmpty)
                  .map((s) => s[0])
                  .take(2)
                  .join()
                  .toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: dimension.d12,
                  color: appTheme.coreWhite),
            ),
          );

    return AppBar(
      backgroundColor: appTheme.coreWhite,
      elevation: dimension.d0,
      scrolledUnderElevation: dimension.d0,
      surfaceTintColor: appTheme.blacktransparent,
      toolbarHeight: dimension.d72,
      automaticallyImplyLeading: false,
      leadingWidth: dimension.d56,
      titleSpacing: dimension.d0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: appTheme.black90001, size: dimension.d22),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            avatarWidget,
            SizedBox(width: dimension.d10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayChat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: strings.fontFamily,
                          fontSize: dimension.d18,
                          height: dimension.d1,
                          color: appTheme.neutral_800,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: dimension.d3),
                  Text(
                    '${displayChat.type}${displayChat.time.isNotEmpty ? ' ${strings.dotSeparator} ' : ''}${displayChat.time}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: strings.fontFamily,
                        fontSize: dimension.d13,
                        height: dimension.d1,
                        color: appTheme.neutral_600,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: dimension.d8),
          child: IconButton(
            icon: Icon(Icons.info_outline,
                color: appTheme.neutral_700, size: dimension.d22),
            onPressed: () => context.navigateToScreen(
              ChatsDetailsScreen(
                  chat: displayChat, onDeleteConversation: c.clearConversation),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader(MessageController c, Strings strings) {
    if (c.statusText.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: dimension.d14, bottom: dimension.d12),
      child: Row(
        children: [
          Expanded(
              child: Container(
                  height: dimension.d1,
                  color: appTheme.neutral_400.withValues(alpha: 0.25))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dimension.d10),
            child: Text(c.statusText,
                style: TextStyle(
                    color: appTheme.neutral_400,
                    fontSize: dimension.d12,
                    fontWeight: FontWeight.w600,
                    fontFamily: strings.fontFamily)),
          ),
          Expanded(
              child: Container(
                  height: dimension.d1,
                  color: appTheme.neutral_400.withValues(alpha: 0.25))),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    MessageController c,
    ChatMessageItem msg,
    CustomButtonStyles styles,
    Strings strings,
  ) {
    String reqStatus = msg.requestStatus ?? 'requested';
    if (msg.meetupRequestId != null &&
        msg.meetupRequestId == c.latestRequestId) {
      final chatStatus = c.effectiveChatStatus;
      if (chatStatus == 'accepted' ||
          chatStatus == 'rejected' ||
          chatStatus == 'completed' ||
          chatStatus == 'cancelled') {
        reqStatus = chatStatus;
      }
    }
    if (reqStatus == 'pending') reqStatus = 'requested';
    final cardText = msg.text.isNotEmpty
        ? msg.text
        : (msg.isMe
            ? 'You sent a meetup request'
            : 'Sent you a meetup request');
    Color statusColor;
    String statusLabel;
    switch (reqStatus) {
      case 'accepted':
        statusColor = appTheme.accentsgreen;
        statusLabel = strings.acceptedLabel;
        break;
      case 'rejected':
        statusColor = appTheme.red;
        statusLabel = strings.rejectedLabel;
        break;
      case 'completed':
        statusColor = appTheme.accentsgreen;
        statusLabel = 'Completed';
        break;
      case 'cancelled':
        statusColor = appTheme.neutral_400;
        statusLabel = 'Cancelled';
        break;
      default:
        statusColor = appTheme.b_400;
        statusLabel = strings.requestedLabel;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: dimension.d16, vertical: dimension.d8),
      child: Container(
        padding: EdgeInsets.all(dimension.d16),
        decoration: BoxDecoration(
          color: appTheme.infieldColor,
          borderRadius: BorderRadius.circular(dimension.d16),
          border: Border.all(color: appTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    cardText,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: dimension.d14,
                        color: appTheme.neutral_800),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: dimension.d10, vertical: dimension.d4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(dimension.d20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                        color: appTheme.coreWhite,
                        fontSize: dimension.d12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (c.canRespondToLatestRequest &&
                msg.meetupRequestId == c.latestRequestId &&
                reqStatus == 'requested') ...[
              SizedBox(height: dimension.d12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await c.rejectRequest();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: appTheme.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(dimension.d28)),
                      ),
                      child: Text(strings.declineLabel,
                          style: TextStyle(color: appTheme.red)),
                    ),
                  ),
                  SizedBox(width: dimension.d10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await c.acceptRequest();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appTheme.b_Primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(dimension.d28)),
                      ),
                      child: Text(strings.acceptAndChatLabel,
                          style: TextStyle(color: appTheme.coreWhite)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessageItem message) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: dimension.d16, vertical: dimension.d8),
      child: Row(
        children: [
          Expanded(
              child: Container(
                  height: dimension.d1,
                  color: appTheme.neutral_400.withValues(alpha: 0.25))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dimension.d10),
            child: Text(
              message.text,
              style: TextStyle(
                  color: appTheme.neutral_400,
                  fontSize: dimension.d12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
              child: Container(
                  height: dimension.d1,
                  color: appTheme.neutral_400.withValues(alpha: 0.25))),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessageItem message) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: dimension.d6, horizontal: dimension.d12),
        padding: EdgeInsets.symmetric(
            horizontal: dimension.d14, vertical: dimension.d12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width > dimension.d900
                ? dimension.d520
                : dimension.d280),
        decoration: BoxDecoration(
          color: isMe ? appTheme.b_Primary : appTheme.neutral_200,
          borderRadius: BorderRadius.circular(dimension.d16),
        ),
        child: Text(message.text,
            style: TextStyle(
                color: isMe ? appTheme.infieldColor : appTheme.neutral_700,
                fontSize: dimension.d14)),
      ),
    );
  }

  bool _chatStatusIsCompleted(MessageController c) {
    return c.effectiveChatStatus == 'completed' ||
        c.effectiveChatStatus == 'closed';
  }

  Widget _buildComposer(BuildContext context, MessageController c,
      CustomButtonStyles styles, Strings strings) {
    if (!c.messagingAllowed) {
      final blockedText = c.blockedConversationText;
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              dimension.d16, dimension.d0, dimension.d16, dimension.d16),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: dimension.d14, vertical: dimension.d14),
            decoration: BoxDecoration(
              color: appTheme.infieldColor,
              borderRadius: BorderRadius.circular(dimension.d28),
              border: Border.all(color: appTheme.borderColor),
            ),
            child: Text(
              c.isBlockedConversation
                  ? blockedText
                  : c.isLatestRequestReceiver
                      ? (_chatStatusIsCompleted(c)
                          ? 'Meetup completed. Send a new request to chat again.'
                          : 'Accept the request to start chatting')
                      : (_chatStatusIsCompleted(c)
                          ? 'Meetup completed. Send a new request to chat again.'
                          : 'Waiting for the host to accept your request'),
              style: TextStyle(
                  color: appTheme.neutral_400, fontSize: dimension.d14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            dimension.d16, dimension.d0, dimension.d16, dimension.d16),
        child: CustomTextFormField(
          maxLines: 10,
          contentPadding: EdgeInsets.symmetric(
              horizontal: dimension.d14, vertical: dimension.d14),
          textAlignVertical: TextAlignVertical.center,
          inputDecoration: styles.messagefInputDecoration.copyWith(
            hintText: strings.typeYourMessageHint,
            hintStyle: styles.dateFieldTextStyle
                .copyWith(color: appTheme.neutral_400, fontSize: dimension.d14),
          ),
          controller: c.messageController,
          focusNode: c.focusNode,
          textInputAction: TextInputAction.send,
          onFieldSubmitted: (_) => c.sendMessage(),
          suffixConstraints: BoxConstraints.tightFor(
              width: dimension.d48, height: dimension.d48),
          suffix: Center(
            child: GestureDetector(
              onTap: c.canSend ? c.sendMessage : null,
              child: Container(
                width: dimension.d40,
                height: dimension.d40,
                decoration: BoxDecoration(
                  color: c.canSend
                      ? appTheme.b_Primary
                      : appTheme.b_Primary.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.send,
                    color: appTheme.coreWhite, size: dimension.d18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
