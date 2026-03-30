import 'package:flutter/material.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/presentation/screens/ChatScreens/chat_detail_screen.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class MessageScreen extends StatefulWidget {
  final Chat chat;

  const MessageScreen({
    required this.chat,
    super.key,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _strings = const Strings();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late final List<_ChatMessage> _messages;

  bool _canSend = false;

  @override
  void initState() {
    super.initState();

    _messages = [
      _ChatMessage(text: _strings.sampleIncomingMessage, isMe: false),
      _ChatMessage(text: _strings.sampleOutgoingMessage, isMe: true),
    ];

    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _handleTextChange() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _canSend) {
      setState(() {
        _canSend = hasText;
      });
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);

    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _statusText {
    switch (widget.chat.status) {
      case RequestStatus.accepted:
        return _strings.acceptedLabel;
      case RequestStatus.rejected:
        return _strings.rejectedLabel;
      case RequestStatus.requested:
        return _strings.requestPendingLabel;
      case RequestStatus.none:
      default:
        return '';
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true));
    });

    _controller.clear();
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _clearConversation() {
    setState(() {
      _messages.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } catch (_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Widget _buildStatusHeader() {
    if (_statusText.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: dimension.d14, bottom: dimension.d12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: dimension.d1,
              color: appTheme.neutral_400.withOpacity(0.25),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dimension.d10),
            child: Text(
              _statusText,
              style: TextStyle(
                color: appTheme.neutral_400,
                fontSize: dimension.d12,
                fontWeight: FontWeight.w600,
                fontFamily: _strings.fontFamily,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: dimension.d1,
              color: appTheme.neutral_400.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
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
              : dimension.d280,
        ),
        decoration: BoxDecoration(
          color: isMe ? appTheme.b_Primary : appTheme.neutral_200,
          borderRadius: BorderRadius.circular(dimension.d16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? appTheme.infieldColor : appTheme.neutral_700,
            fontSize: dimension.d14,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final chat = widget.chat;

    final avatarWidget = chat.avatarUrl.isNotEmpty
        ? CircleAvatar(
            radius: dimension.d18,
            backgroundImage: NetworkImage(chat.avatarUrl),
          )
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
                color: appTheme.coreWhite,
              ),
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
        icon: Icon(
          Icons.arrow_back,
          color: appTheme.black90001,
          size: dimension.d22,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(),
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
                    Text(
                      chat.name,
                      maxLines: constant.s1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: _strings.fontFamily,
                        fontSize: dimension.d18,
                        height: dimension.d1,
                        color: appTheme.neutral_800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: dimension.d3),
                    Text(
                      '${chat.type ?? ''}${chat.time.isNotEmpty ? ' ${_strings.dotSeparator} ' : ''}${chat.time}',
                      maxLines: constant.s1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: _strings.fontFamily,
                        fontSize: dimension.d13,
                        height: dimension.d1,
                        color: appTheme.neutral_600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: dimension.d8),
          child: IconButton(
            icon: Icon(
              Icons.info_outline,
              color: appTheme.neutral_700,
              size: dimension.d22,
            ),
            onPressed: () {
              context.navigateToScreen(
                ChatsDetailsScreen(
                  chat: widget.chat,
                  onDeleteConversation: _clearConversation,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComposer() {
    final customThemeData =
        ThemeHelper(appThemeName: _strings.lightCode).themeData;

    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            dimension.d16, dimension.d0, dimension.d16, dimension.d16),
        child: CustomTextFormField(
          maxLines: 10,
          contentPadding: EdgeInsets.symmetric(
            horizontal: dimension.d14,
            vertical: dimension.d14,
          ),
          textAlignVertical: TextAlignVertical.center,
          inputDecoration:
              customButtonandTextStyles.messagefInputDecoration.copyWith(
            hintText: _strings.typeYourMessageHint,
            hintStyle: customButtonandTextStyles.dateFieldTextStyle.copyWith(
              color: appTheme.neutral_400,
              fontSize: dimension.d14,
            ),
          ),
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.send,
          onFieldSubmitted: (_) => _sendMessage(),
          suffixConstraints: BoxConstraints.tightFor(
            width: dimension.d48,
            height: dimension.d48,
          ),
          suffix: Center(
            child: GestureDetector(
              onTap: _canSend ? _sendMessage : null,
              child: Container(
                width: dimension.d40,
                height: dimension.d40,
                decoration: BoxDecoration(
                  color: _canSend
                      ? appTheme.b_Primary
                      : appTheme.b_Primary.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.send,
                  color: appTheme.coreWhite,
                  size: dimension.d18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: appTheme.coreWhite,
        appBar: _buildAppBar(),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: dimension.d8,
                    bottom: dimension.d92,
                  ),
                  itemCount: _messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == dimension.d0) {
                      return _buildStatusHeader();
                    }
                    return _buildMessageBubble(_messages[index - 1]);
                  },
                ),
              ),
              Positioned(
                left: dimension.d0,
                right: dimension.d0,
                bottom: dimension.d0,
                child: _buildComposer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;

  const _ChatMessage({
    required this.text,
    required this.isMe,
  });
}
