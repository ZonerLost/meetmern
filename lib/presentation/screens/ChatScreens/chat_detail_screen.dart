import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/presentation/screens/ChatScreens/user_meetup_info_screen.dart';
import 'package:meetmern/presentation/screens/HomeScreens/MeetupUserProfileScreen/meetup_user_profile_screen.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/utils/dimension_resource/dimension_resource.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_dialog_widget.dart';
import 'package:meetmern/utils/widgets/custom_drop_down_button.dart';
import 'package:meetmern/utils/widgets/custom_rounded_tile.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

import '../../../utils/theme/theme.dart';

class ChatsDetailsScreen extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onDeleteConversation;

  const ChatsDetailsScreen({
    super.key,
    required this.chat,
    this.onDeleteConversation,
  });

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final dimension = DimensionResource();

    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    final meetupFromChat = chat.toMeetup();

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.black90001),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(dimension.d16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.chatDetailsTitle,
                style: customButtonandTextStyles.titleTextStyle,
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.userInfoTitle,
                subtitle: strings.userInfoSubtitle,
                leadingIcon: Icons.info_outline,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.sp,
                borderRadius: BorderRadius.circular(dimension.d100.h),
                iconBackgroundColor: appTheme.coreWhite,
                iconBoxHeight: dimension.d44.h,
                iconBoxWidth: dimension.d44.w,
                iconColor: appTheme.b_Primary,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                subtitleStyle: customButtonandTextStyles.locationTextStyle,
                onTap: () {
                  context.navigateToScreen(
                    MeetupUserProfileScreen(
                      meetup: meetupFromChat,
                      showRequestButton: false,
                    ),
                  );
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.meetupInfoTitle,
                subtitle: strings.meetupInfoSubtitle,
                leadingIcon: Icons.person,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.sp,
                borderRadius: BorderRadius.circular(dimension.d100.h),
                iconBackgroundColor: appTheme.coreWhite,
                iconBoxHeight: dimension.d44.h,
                iconBoxWidth: dimension.d44.w,
                iconColor: appTheme.b_Primary,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                subtitleStyle: customButtonandTextStyles.locationTextStyle,
                onTap: () {
                  context.navigateToScreen(
                    UserMeetupInfoScreen(
                      meetup: meetupFromChat,
                    ),
                  );
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.blockUserTitle,
                subtitle: strings.blockUserSubtitle,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                subtitleStyle: customButtonandTextStyles.locationTextStyle,
                leadingIcon: Icons.block,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.sp,
                borderRadius: BorderRadius.circular(dimension.d100.h),
                iconBackgroundColor: appTheme.coreWhite,
                iconBoxHeight: dimension.d44.h,
                iconBoxWidth: dimension.d44.w,
                iconColor: appTheme.b_Primary,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      return CustomModalDialog(
                        showLeftIconBackground: false,
                        topRightIcon: IconButton(
                          icon: Icon(Icons.close, size: dimension.d20.sp),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        topLeftIcon: Icon(
                          Icons.block,
                          color: appTheme.b_Primary,
                          size: dimension.d20.sp,
                        ),
                        title: strings.blockUserDialogTitle,
                        titleTextStyle:
                            customButtonandTextStyles.emailLabelTextStyle,
                        subtitle: strings.blockUserDialogSubtitle
                            .replaceAll('{name}', chat.name),
                        subtitleHighlightedText: chat.name,
                        subtitleHighlightedTextStyle:
                            customButtonandTextStyles.locationTextStyle,
                        primaryLabel: strings.blockUserPrimaryLabel,
                        primaryButtonStyle:
                            customButtonandTextStyles.loginButtonStyle,
                        primaryTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
                        onPrimary: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                strings.blockedUserSnack
                                    .replaceAll('{name}', chat.name),
                              ),
                            ),
                          );
                        },
                        secondaryLabel: strings.cancelLabel,
                        secondaryButtonStyle:
                            customButtonandTextStyles.googleButtonStyle,
                        secondaryTextStyle:
                            customButtonandTextStyles.cancelButtonTextStyle,
                        onSecondary: () => Navigator.of(ctx).pop(),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.reportUserTitle,
                subtitle: strings.reportUserSubtitle,
                leadingIcon: Icons.flag_outlined,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.sp,
                borderRadius: BorderRadius.circular(dimension.d100.h),
                iconBackgroundColor: appTheme.coreWhite,
                iconBoxHeight: dimension.d44.h,
                iconBoxWidth: dimension.d44.w,
                iconColor: appTheme.b_Primary,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                subtitleStyle: customButtonandTextStyles.locationTextStyle,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      String? selectedReason;
                      final descCtrl = TextEditingController();

                      return CustomModalDialog(
                        showLeftIconBackground: false,
                        topRightIcon: IconButton(
                          icon: Icon(Icons.close, size: dimension.d20.sp),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        topLeftIcon: Icon(
                          Icons.flag_outlined,
                          color: appTheme.b_Primary,
                          size: dimension.d20.sp,
                        ),
                        title: strings.reportUserDialogTitle,
                        titleTextStyle:
                            customButtonandTextStyles.emailLabelTextStyle,
                        subtitle: strings.reportUserDialogSubtitle
                            .replaceAll('{name}', chat.name),
                        subtitleHighlightedText: chat.name,
                        subtitleHighlightedTextStyle: customButtonandTextStyles
                            .locationTextStyle
                            .copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        content: StatefulBuilder(
                          builder: (c, setState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.reasonLabel,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle,
                                ),
                                SizedBox(height: dimension.d8.h),
                                CustomDropdownButton(
                                  hint: strings.reasonLabel,
                                  items: OnboardingMockData.reportReason,
                                  value: selectedReason,
                                  onChanged: (v) {
                                    setState(() {
                                      selectedReason = v;
                                    });
                                  },
                                  decoration: customButtonandTextStyles
                                      .genderFInputDecoration,
                                  menuColor: appTheme.coreWhite,
                                  itemTextStyle: const TextStyle(fontSize: 14),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: dimension.d12.w,
                                    vertical: dimension.d12.h,
                                  ),
                                ),
                                SizedBox(height: dimension.d12.h),
                                Text(
                                  strings.discriptionLabel,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle,
                                ),
                                SizedBox(height: dimension.d8.h),
                                CustomTextFormField(
                                  hintText: strings.reportDescriptionHint,
                                  controller: descCtrl,
                                  maxLines: 10,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: dimension.d14,
                                    vertical: dimension.d14,
                                  ),
                                  inputDecoration: customButtonandTextStyles
                                      .messagefInputDecoration
                                      .copyWith(
                                    floatingLabelStyle: TextStyle(
                                      color: appTheme.black90001,
                                    ),
                                    hintStyle: customButtonandTextStyles
                                        .dateFieldTextStyle
                                        .copyWith(
                                      color: appTheme.neutral_400,
                                      fontSize: dimension.d14,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        primaryLabel: strings.reportPrimaryLabel,
                        primaryButtonStyle:
                            customButtonandTextStyles.loginButtonStyle,
                        primaryTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
                        onPrimary: () {
                          if (selectedReason == null ||
                              descCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(strings.reportValidationText),
                              ),
                            );
                            return;
                          }

                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.reportSubmittedSnack),
                            ),
                          );
                        },
                        secondaryLabel: strings.cancelLabel,
                        secondaryButtonStyle:
                            customButtonandTextStyles.googleButtonStyle,
                        secondaryTextStyle:
                            customButtonandTextStyles.cancelButtonTextStyle,
                        onSecondary: () => Navigator.of(ctx).pop(),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.deleteConversationTitle,
                subtitle: strings.deleteConversationSubtitle,
                leadingIcon: Icons.delete,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.sp,
                borderRadius: BorderRadius.circular(dimension.d100.h),
                iconBackgroundColor: appTheme.coreWhite,
                iconBoxHeight: dimension.d44.h,
                iconBoxWidth: dimension.d44.w,
                iconColor: appTheme.b_Primary,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                subtitleStyle: customButtonandTextStyles.locationTextStyle,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) {
                      return CustomModalDialog(
                        showLeftIconBackground: false,
                        topRightIcon: IconButton(
                          icon: Icon(Icons.close, size: dimension.d20.sp),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        topLeftIcon: Icon(
                          Icons.delete_outline,
                          color: appTheme.b_Primary,
                          size: dimension.d20.sp,
                        ),
                        title: strings.deleteConversationDialogTitle,
                        titleTextStyle:
                            customButtonandTextStyles.emailLabelTextStyle,
                        subtitle: strings.deleteConversationDialogSubtitle,
                        subtitleTextStyle:
                            customButtonandTextStyles.locationTextStyle,
                        primaryLabel: strings.deleteConversationPrimaryLabel,
                        primaryButtonStyle:
                            customButtonandTextStyles.loginButtonStyle,
                        primaryTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
                        onPrimary: () {
                          Navigator.of(ctx).pop();

                          onDeleteConversation?.call();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.conversationDeletedSnack),
                            ),
                          );

                          Navigator.of(context).pop();
                        },
                        secondaryLabel: strings.cancelLabel,
                        secondaryButtonStyle:
                            customButtonandTextStyles.googleButtonStyle,
                        secondaryTextStyle:
                            customButtonandTextStyles.cancelButtonTextStyle,
                        onSecondary: () => Navigator.of(ctx).pop(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
