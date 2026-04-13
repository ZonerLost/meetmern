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

class MessageScreen extends StatelessWidget {
  final Chat chat;

  const MessageScreen({required this.chat, super.key});

  @override
  Widget build(BuildContext context) {
    const strings = Strings();

    return GetBuilder<MessageController>(
      initState: (_) => Get.find<MessageController>().init(chat),
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ListView.builder(
                      controller: c.scrollController,
                      padding: EdgeInsets.only(
                          top: dimension.d8, bottom: dimension.d92),
                      itemCount: c.messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildStatusHeader(c, strings);
                        final msg = c.messages[index - 1];
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
    final avatarWidget = chat.avatarUrl.isNotEmpty
        ? CircleAvatar(
            radius: dimension.d18,
            backgroundImage: NetworkImage(chat.avatarUrl))
        : CircleAvatar(
            radius: dimension.d18,
            backgroundColor: appTheme.neutral_400,
            child: Text(
              chat.name
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
                  Text(chat.name,
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
                    '${chat.type ?? ''}${chat.time.isNotEmpty ? ' ${strings.dotSeparator} ' : ''}${chat.time}',
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
                  chat: chat, onDeleteConversation: c.clearConversation),
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

  Widget _buildComposer(BuildContext context, MessageController c,
      CustomButtonStyles styles, Strings strings) {
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
