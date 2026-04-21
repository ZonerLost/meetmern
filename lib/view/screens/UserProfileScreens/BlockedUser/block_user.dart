import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_rounded_tile.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';

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
      final uid = AuthService.currentUser?.id;
      if (uid == null) {
        if (!mounted) return;
        setState(() {
          _users = [];
          _isLoading = false;
        });
        return;
      }

      final rows = await MeetupService.fetchBlockedUsers(uid);
      final users = rows
          .map(
            (item) => _BlockedUser(
              userId: (item['user_id'] ?? '').toString(),
              name: (item['name'] ?? 'User').toString(),
              subtitle: (item['reason']?.toString().trim().isNotEmpty ?? false)
                  ? 'Reason: ${item['reason']}'
                  : 'Blocked user',
              photoUrl: (item['photo_url'] ?? '').toString(),
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
                              leadingImage: user.photoUrl.isNotEmpty
                                  ? user.photoUrl
                                  : null,
                              leadingIcon:
                                  user.photoUrl.isEmpty ? Icons.person : null,
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
            backgroundColor: appTheme.b_200,
            backgroundImage:
                user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
            child: user.photoUrl.isEmpty
                ? Text(
                    user.name
                        .split(' ')
                        .where((s) => s.isNotEmpty)
                        .map((s) => s[0])
                        .take(2)
                        .join()
                        .toUpperCase(),
                    style: TextStyle(
                      color: appTheme.coreWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: dimension.d12.sp,
                    ),
                  )
                : null,
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
            _unblockUser(user, index);
          },
          onSecondary: () => Navigator.of(ctx).pop(),
        );
      },
    );
  }

  Future<void> _unblockUser(_BlockedUser user, int index) async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;

    try {
      await MeetupService.unblockUser(
        blockerId: uid,
        blockedId: user.userId,
      );

      if (!mounted) return;
      setState(() {
        _users.removeWhere((u) => u.userId == user.userId);
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unblock user: $e'),
        ),
      );
    }
  }
}

class _BlockedUser {
  final String userId;
  final String name;
  final String subtitle;
  final String photoUrl;

  const _BlockedUser({
    required this.userId,
    required this.name,
    required this.subtitle,
    required this.photoUrl,
  });
}
