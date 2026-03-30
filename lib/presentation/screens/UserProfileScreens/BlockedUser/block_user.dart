import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/data_source/api_s.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_dialog_widget.dart';
import 'package:meetmern/utils/widgets/custom_rounded_tile.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<_BlockedUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    try {
      final List<Nearby> nearby = await MockApi.fetchNearbyPeople();

      final users = nearby
          .map(
            (item) => _BlockedUser(
              name: item.name,
              subtitle: '${item.favMeetupType} • ${item.locationShort}',
              avatar: item.image,
            ),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _users = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          icon: Icon(Icons.arrow_back, size: dimension.d22.sp),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dimension.d16.w,
          vertical: dimension.d12.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.blockedUsersText,
              style: customButtonandTextStyles.emailLabelTextStyle.copyWith(
                fontSize: dimension.d20.sp,
              ),
            ),
            SizedBox(height: dimension.d16.h),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: SizedBox(
                        width: dimension.d28.w,
                        height: dimension.d28.h,
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : _users.isEmpty
                      ? Center(
                          child: Text(
                            strings.noBlockedUsersText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: dimension.d16.sp,
                              color: appTheme.neutral_700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _users.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: dimension.d12.h),
                          itemBuilder: (context, index) {
                            final user = _users[index];

                            return CustomRoundedTile(
                              title: user.name,
                              subtitle: user.subtitle,
                              leadingImage: user.avatar ?? strings.img9,
                              trailingIcon: Icons.lock_open,
                              onTap: () => _showUnblockDialog(user, index),
                              backgroundColor: appTheme.infieldColor,
                              borderColor: appTheme.borderColor,
                              borderWidth: dimension.d1.w,
                              borderRadius:
                                  BorderRadius.circular(dimension.d100.r),
                              iconBackgroundColor: appTheme.b_Primary,
                              iconColor: appTheme.coreWhite,
                              titletextStyle:
                                  customButtonandTextStyles.dobLabelTextStyle,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockDialog(_BlockedUser user, int index) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return CustomModalDialog(
          centerHeaderTitle: true,
          showLeftIconBackground: false,
          topLeftIcon: CircleAvatar(
            radius: dimension.d20.r,
            backgroundImage: AssetImage(user.avatar ?? strings.img9),
          ),
          showCloseButton: true,
          title: '${strings.unblockUserTitlePrefixText} ${user.name}?',
          subtitle: strings.unblockUserSubtitleText,
          titleTextStyle: customButtonandTextStyles.emailLabelTextStyle,
          subtitleTextStyle: customButtonandTextStyles.locationTextStyle,
          primaryLabel: strings.yesUnblockText,
          primaryColor: appTheme.b_Primary,
          primaryTextStyle: customButtonandTextStyles.loginButtonTextStyle,
          primaryButtonStyle: customButtonandTextStyles.loginButtonStyle,
          secondaryLabel: strings.cancelLabel,
          secondaryTextStyle: customButtonandTextStyles.cancelButtonTextStyle,
          secondaryButtonStyle: customButtonandTextStyles.googleButtonStyle,
          padding: EdgeInsets.fromLTRB(
            dimension.d18.w,
            dimension.d18.h,
            dimension.d18.w,
            dimension.d18.h,
          ),
          borderRadius: dimension.d22.r,
          onPrimary: () {
            Navigator.of(ctx).pop();

            setState(() {
              _users.removeAt(index);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  strings.unblockedUserSnackText.replaceFirst(
                    '{name}',
                    user.name,
                  ),
                ),
              ),
            );
          },
          onSecondary: () => Navigator.of(ctx).pop(),
        );
      },
    );
  }
}

class _BlockedUser {
  final String name;
  final String subtitle;
  final String? avatar;

  const _BlockedUser({
    required this.name,
    required this.subtitle,
    this.avatar,
  });
}
