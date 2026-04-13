import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/service/api_s.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/view/screens/ChatScreens/message_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Chat> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final chats = await MockApi.fetchChats();
      setState(() {
        _items = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = strings.failedToLoadChats;
      });
    }
  }

  Future<void> _openAcceptDialog(Chat item) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        const strings = Strings();
        final customThemeData =
            ThemeHelper(appThemeName: strings.lightCode).themeData;
        final customButtonandTextStyles = CustomButtonStyles(
          apppTheme: Theme.of(context),
          theme: customThemeData,
        );

        final title =
            strings.acceptRequestTitlePattern.replaceFirst('{name}', item.name);
        final subtitle = strings.acceptRequestSubtitlePattern
            .replaceFirst('{name}', item.name)
            .replaceFirst('{time}', item.time.toString());

        return CustomModalDialog(
          backgroundColor: appTheme.coreWhite,
          topLeftIcon: CircleAvatar(
            radius: dimension.d22.r,
            backgroundColor: appTheme.b_200,
            backgroundImage:
                item.avatarUrl.isNotEmpty ? NetworkImage(item.avatarUrl) : null,
            child: item.avatarUrl.isEmpty
                ? ClipOval(
                    child: SizedBox(
                      width: dimension.d44.r,
                      height: dimension.d44.r,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.name
                                .split(' ')
                                .map((s) => s.isNotEmpty ? s[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase(),
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: dimension.d14.sp,
                              color: appTheme.black90001,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          topRightIcon: IconButton(
            icon: Icon(
              Icons.close,
              size: dimension.d20.r,
              color: appTheme.neutral_600,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          title: title,
          subtitle: subtitle,
          primaryLabel: strings.acceptAndChatLabel,
          primaryButtonStyle: customButtonandTextStyles.loginButtonStyle,
          primaryTextStyle: customButtonandTextStyles.acceptCahtButtonTextStyle,
          onPrimary: () {
            setState(() {
              item.status = RequestStatus.accepted;
            });
            Navigator.of(ctx).pop();
          },
          primaryBold: true,
          secondaryLabel: strings.declineLabel,
          secondaryButtonStyle: customButtonandTextStyles.googleButtonStyle,
          secondaryTextStyle: customButtonandTextStyles.googleButtonTextStyle,
          onSecondary: () {
            context.maybePopScreen;
            _openDeclineDialog(item);
          },
          showCloseButton: false,
        );
      },
    );
  }

  Future<void> _openDeclineDialog(Chat item) async {
    String? selectedReason;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        const strings = Strings();
        final customThemeData =
            ThemeHelper(appThemeName: strings.lightCode).themeData;
        final customButtonandTextStyles = CustomButtonStyles(
          apppTheme: Theme.of(context),
          theme: customThemeData,
        );

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CustomModalDialog(
              backgroundColor: appTheme.coreWhite,
              topLeftIcon: Icon(
                Icons.block,
                size: dimension.d20.r,
                color: appTheme.b_Primary,
              ),
              topRightIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  size: dimension.d20.r,
                  color: appTheme.neutral_600,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              title: strings.declineRequestTitlePattern
                  .replaceFirst('{name}', item.name),
              titleTextStyle: customButtonandTextStyles.emailLabelTextStyle,
              subtitle: strings.declineRequestSubtitle,
              subtitleTextStyle: customButtonandTextStyles.locationTextStyle,
              text1: strings.reasonLabel,
              text1Style: customButtonandTextStyles.dobLabelTextStyle,
              primaryLabel: strings.declineRequestPrimaryLabel,
              primaryButtonStyle: customButtonandTextStyles.loginButtonStyle,
              primaryTextStyle:
                  customButtonandTextStyles.acceptCahtButtonTextStyle,
              primaryBold: true,
              secondaryLabel: strings.cancelLabel,
              secondaryButtonStyle: customButtonandTextStyles.googleButtonStyle,
              secondaryTextStyle:
                  customButtonandTextStyles.googleButtonTextStyle,
              onPrimary: selectedReason == null
                  ? null
                  : () {
                      setState(() {
                        item.status = RequestStatus.rejected;
                      });
                      Navigator.of(ctx).pop();
                    },
              onSecondary: () {
                Navigator.of(ctx).pop();
              },
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDropdownButton(
                    decoration:
                        customButtonandTextStyles.genderFInputDecoration,
                    hint: strings.selectReasonHint,
                    items: strings.declineReasons,
                    value: selectedReason,
                    onChanged: (val) {
                      setDialogState(() {
                        selectedReason = val;
                      });
                    },
                    width: double.infinity,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusPill(RequestStatus status) {
    const strings = Strings();

    switch (status) {
      case RequestStatus.accepted:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: dimension.d10.w,
            vertical: dimension.d6.h,
          ),
          decoration: BoxDecoration(
            color: appTheme.accentsgreen,
            borderRadius: BorderRadius.circular(dimension.d20),
            border: Border.all(color: appTheme.accentsgreen),
          ),
          child: Text(
            strings.acceptedLabel,
            style: TextStyle(
              color: appTheme.b_50,
              fontSize: dimension.d12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case RequestStatus.rejected:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: dimension.d10.w,
            vertical: dimension.d6.h,
          ),
          decoration: BoxDecoration(
            color: appTheme.red,
            borderRadius: BorderRadius.circular(dimension.d20),
          ),
          child: Text(
            strings.rejectedLabel,
            style: TextStyle(
              color: appTheme.b_50,
              fontSize: dimension.d12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case RequestStatus.requested:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: dimension.d10.w,
            vertical: dimension.d6.h,
          ),
          decoration: BoxDecoration(
            color: appTheme.b_400,
            borderRadius: BorderRadius.circular(dimension.d20),
          ),
          child: Text(
            strings.requestedLabel,
            style: TextStyle(
              color: appTheme.black90001,
              fontSize: dimension.d12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case RequestStatus.none:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _listItem(Chat item) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: dimension.d8.h,
        horizontal: dimension.d16.w,
      ),
      child: GestureDetector(
        onTap: () {
          switch (item.status) {
            case RequestStatus.requested:
              _openAcceptDialog(item);
              break;
            case RequestStatus.accepted:
            case RequestStatus.rejected:
            case RequestStatus.none:
              context.navigateToScreen(MessageScreen(chat: item));
              break;
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(
            dimension.d14.w,
            dimension.d10.h,
            dimension.d20.w,
            dimension.d10.h,
          ),
          width: double.infinity,
          constraints: BoxConstraints(minHeight: dimension.d65.h),
          decoration: BoxDecoration(
            color: appTheme.infieldColor,
            borderRadius: BorderRadius.circular(dimension.d100),
            border: Border.all(color: appTheme.borderColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: dimension.d44.w,
                height: dimension.d44.w,
                child: CircleAvatar(
                  radius: dimension.d22.r,
                  backgroundColor: appTheme.b_200,
                  backgroundImage: item.avatarUrl.isNotEmpty
                      ? NetworkImage(item.avatarUrl)
                      : null,
                  child: item.avatarUrl.isEmpty
                      ? Text(
                          item.name
                              .split(' ')
                              .map((s) => s.isNotEmpty ? s[0] : '')
                              .take(2)
                              .join(),
                          style: customButtonandTextStyles.userNameTextStyle,
                        )
                      : null,
                ),
              ),
              SizedBox(width: dimension.d12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.name} - ${strings.meetForPrefix} ${item.type}',
                      style: customButtonandTextStyles.dobLabelTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: dimension.d4.h),
                    Text(
                      item.message,
                      style: customButtonandTextStyles.locationTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: dimension.d12.w),
              SizedBox(
                width: dimension.d100.w,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: item.status == RequestStatus.requested
                        ? () => _openAcceptDialog(item)
                        : null,
                    borderRadius: BorderRadius.circular(dimension.d20.r),
                    child: _buildStatusPill(item.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.black90001),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        SizedBox(height: dimension.d12.h),
                        CustomElevatedButton(
                          onPressed: _loadChats,
                          text: strings.retryText,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadChats,
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: dimension.d12.h,
                        bottom: MediaQuery.of(context).padding.bottom +
                            dimension.d24.h,
                      ),
                      children: [
                        SizedBox(height: dimension.d8.h),
                        Padding(
                          padding: EdgeInsets.only(
                            left: dimension.d16.w,
                            bottom: dimension.d6.h,
                          ),
                          child: Text(
                            strings.chatsTitle,
                            style: customButtonandTextStyles.titleTextStyle,
                          ),
                        ),
                        SizedBox(height: dimension.d6.h),
                        ..._items.map(_listItem),
                        SizedBox(height: dimension.d40.h),
                      ],
                    ),
                  ),
      ),
    );
  }
}
