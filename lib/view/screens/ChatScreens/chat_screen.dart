import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_screen_controller.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/view/screens/chatscreens/message_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<ChatListController>(
      builder: (c) {
        final pendingItems = c.pendingRequestItems;
        final regularItems = c.regularItems;

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
            child: c.isLoading
                ? const Center(child: CircularProgressIndicator())
                : c.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.error!),
                            SizedBox(height: dimension.d12.h),
                            CustomElevatedButton(
                                onPressed: c.loadChats,
                                text: strings.retryText),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: c.loadChats,
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
                                  bottom: dimension.d6.h),
                              child: Text(strings.chatsTitle,
                                  style: styles.titleTextStyle),
                            ),
                            SizedBox(height: dimension.d6.h),
                            if (c.items.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: dimension.d16.w,
                                  vertical: dimension.d24.h,
                                ),
                                child: Text(
                                  'No chats yet.',
                                  style: styles.locationTextStyle,
                                ),
                              ),
                            if (pendingItems.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: dimension.d16.w,
                                  right: dimension.d16.w,
                                  bottom: dimension.d8.h,
                                ),
                                child: Text(
                                  strings.newMeetupRequestsText,
                                  style: styles.dobLabelTextStyle,
                                ),
                              ),
                            ...pendingItems.map((item) => _ChatListItem(
                                item: item, controller: c, styles: styles)),
                            if (pendingItems.isNotEmpty &&
                                regularItems.isNotEmpty)
                              SizedBox(height: dimension.d8.h),
                            ...regularItems.map((item) => _ChatListItem(
                                item: item, controller: c, styles: styles)),
                            SizedBox(height: dimension.d40.h),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final Chat item;
  final ChatListController controller;
  final CustomButtonStyles styles;

  const _ChatListItem(
      {required this.item, required this.controller, required this.styles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: dimension.d8.h, horizontal: dimension.d16.w),
      child: GestureDetector(
        onTap: () => context.navigateToScreen(MessageScreen(chat: item)),
        onLongPress: () {
          if (item.status == RequestStatus.requested) {
            _openAcceptDialog(context);
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(dimension.d14.w, dimension.d10.h,
              dimension.d20.w, dimension.d10.h),
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
                          style: styles.userNameTextStyle)
                      : null,
                ),
              ),
              SizedBox(width: dimension.d12.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: styles.dobLabelTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: dimension.d4.h),
                    Text(
                        item.subtitle.isNotEmpty ? item.subtitle : item.message,
                        style: styles.locationTextStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(width: dimension.d12.w),
              SizedBox(
                width: dimension.d100.w,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _StatusPill(status: item.status),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAcceptDialog(BuildContext context) async {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final dialogStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);
    final title =
        strings.acceptRequestTitlePattern.replaceFirst('{name}', item.name);
    final subtitle = strings.acceptRequestSubtitlePattern
        .replaceFirst('{name}', item.name)
        .replaceFirst('{time}', item.time.toString());

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomModalDialog(
        backgroundColor: appTheme.coreWhite,
        topLeftIcon: CircleAvatar(
          radius: dimension.d22.r,
          backgroundColor: appTheme.b_200,
          backgroundImage:
              item.avatarUrl.isNotEmpty ? NetworkImage(item.avatarUrl) : null,
          child: item.avatarUrl.isEmpty
              ? Text(
                  item.name
                      .split(' ')
                      .map((s) => s.isNotEmpty ? s[0] : '')
                      .take(2)
                      .join()
                      .toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: dimension.d14.sp,
                      color: appTheme.black90001))
              : null,
        ),
        topRightIcon: IconButton(
          icon: Icon(Icons.close,
              size: dimension.d20.r, color: appTheme.neutral_600),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        title: title,
        subtitle: subtitle,
        primaryLabel: strings.acceptAndChatLabel,
        primaryButtonStyle: dialogStyles.loginButtonStyle,
        primaryTextStyle: dialogStyles.acceptCahtButtonTextStyle,
        onPrimary: () async {
          final navigator = Navigator.of(ctx);
          await controller.acceptRequest(item);
          if (!navigator.mounted) return;
          navigator.pop();
          if (!context.mounted) return;
          context.navigateToScreen(MessageScreen(chat: item));
        },
        primaryBold: true,
        secondaryLabel: strings.declineLabel,
        secondaryButtonStyle: dialogStyles.googleButtonStyle,
        secondaryTextStyle: dialogStyles.googleButtonTextStyle,
        onSecondary: () {
          Navigator.of(ctx).pop();
          _openDeclineDialog(context);
        },
        showCloseButton: false,
      ),
    );
  }

  Future<void> _openDeclineDialog(BuildContext context) async {
    String? selectedReason;
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final dialogStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => CustomModalDialog(
          backgroundColor: appTheme.coreWhite,
          topLeftIcon: Icon(Icons.block,
              size: dimension.d20.r, color: appTheme.b_Primary),
          topRightIcon: IconButton(
            icon: Icon(Icons.close,
                size: dimension.d20.r, color: appTheme.neutral_600),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          title: strings.declineRequestTitlePattern
              .replaceFirst('{name}', item.name),
          titleTextStyle: dialogStyles.emailLabelTextStyle,
          subtitle: strings.declineRequestSubtitle,
          subtitleTextStyle: dialogStyles.locationTextStyle,
          text1: strings.reasonLabel,
          text1Style: dialogStyles.dobLabelTextStyle,
          primaryLabel: strings.declineRequestPrimaryLabel,
          primaryButtonStyle: dialogStyles.loginButtonStyle,
          primaryTextStyle: dialogStyles.acceptCahtButtonTextStyle,
          primaryBold: true,
          secondaryLabel: strings.cancelLabel,
          secondaryButtonStyle: dialogStyles.googleButtonStyle,
          secondaryTextStyle: dialogStyles.googleButtonTextStyle,
          onPrimary: selectedReason == null
              ? null
              : () {
                  controller.rejectRequest(item);
                  Navigator.of(ctx).pop();
                },
          onSecondary: () => Navigator.of(ctx).pop(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomDropdownButton(
                decoration: dialogStyles.genderFInputDecoration,
                hint: strings.selectReasonHint,
                items: strings.declineReasons,
                value: selectedReason,
                onChanged: (val) => setDialogState(() => selectedReason = val),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final RequestStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    switch (status) {
      case RequestStatus.accepted:
        return _pill(
            strings.acceptedLabel, appTheme.accentsgreen, appTheme.b_50);
      case RequestStatus.rejected:
        return _pill(strings.rejectedLabel, appTheme.red, appTheme.b_50);
      case RequestStatus.requested:
        return _pill(
            strings.requestedLabel, appTheme.b_400, appTheme.black90001);
      case RequestStatus.completed:
        return _pill('Completed', appTheme.accentsgreen, appTheme.b_50);
      case RequestStatus.cancelled:
        return _pill('Cancelled', appTheme.neutral_400, appTheme.coreWhite);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _pill(String label, Color bg, Color textColor) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: dimension.d10.w, vertical: dimension.d6.h),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(dimension.d20)),
        child: Text(label,
            style: TextStyle(
                color: textColor,
                fontSize: dimension.d12.sp,
                fontWeight: FontWeight.w600)),
      );
}
