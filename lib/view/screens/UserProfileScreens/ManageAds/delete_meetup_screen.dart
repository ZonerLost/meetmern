import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ManageAds/delete_meetup_screen_controller.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';

class ViewMeetupDeleteScreen extends StatefulWidget {
  final Meetup meetup;
  const ViewMeetupDeleteScreen({required this.meetup, super.key});

  @override
  State<ViewMeetupDeleteScreen> createState() => _ViewMeetupDeleteScreenState();
}

class _ViewMeetupDeleteScreenState extends State<ViewMeetupDeleteScreen> {
  late final DeleteMeetupController _controller;
  final dimension = DimensionResource();
  final strings = const Strings();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DeleteMeetupController>();
    _controller.init(widget.meetup);
  }

  void _confirmDelete() {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomModalDialog(
        title: strings.deleteAdTitle,
        subtitle: strings.deleteAdSubtitle,
        primaryLabel: strings.deleteLabel,
        primaryButtonStyle: styles.deleteButtonStyle,
        primaryTextStyle: styles.loginButtonTextStyle,
        secondaryLabel: strings.cancelLabel,
        secondaryButtonStyle: styles.googleButtonStyle,
        secondaryTextStyle: styles.cancelButtonTextStyle,
        onPrimary: () async {
          Navigator.of(dialogContext).pop();
          final success = await _controller.deleteMeetup();
          if (!mounted) return;
          if (success) {
            Navigator.of(context)
                .pop({'action': 'delete', 'id': widget.meetup.id});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete. Try again.')),
            );
          }
        },
        onSecondary: () => Navigator.of(dialogContext).pop(),
        showCloseButton: true,
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeaderImage() {
    final img = widget.meetup.image;
    if (img.startsWith('http')) {
      return Image.network(
        img,
        width: double.infinity,
        height: dimension.d300.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    if (img.isNotEmpty) {
      return Image.asset(
        img,
        width: double.infinity,
        height: dimension.d300.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() => Image.asset(
        'assets/images/img9.jpg',
        width: double.infinity,
        height: dimension.d300.h,
        fit: BoxFit.cover,
      );

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<DeleteMeetupController>(
      builder: (c) => Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: appTheme.coreWhite,
        appBar: AppBar(
          backgroundColor: appTheme.blacktransparent,
          leading: SafeArea(
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: appTheme.coreWhite),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderImage(),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(dimension.d16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.meetup.title, style: styles.titleTextStyle),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.timeLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: dimension.d16.sp),
                        SizedBox(width: dimension.d6.w),
                        Text(c.formatMeetupTime(widget.meetup.time),
                            style: styles.userNameTextStyle),
                      ]),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.locationLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: dimension.d16.sp),
                        SizedBox(width: dimension.d6.w),
                        Expanded(
                          child: Text(widget.meetup.location,
                              style: styles.userNameTextStyle),
                        ),
                      ]),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.meetupTypeLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Text(widget.meetup.type, style: styles.userNameTextStyle),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.meetupStatusLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Text(
                        _formatStatus(widget.meetup.status),
                        style: styles.userNameTextStyle,
                      ),
                      SizedBox(height: dimension.d24.h),
                      CustomElevatedButton(
                        buttonStyle: styles.deleteButtonStyle,
                        buttonTextStyle: styles.loginButtonTextStyle,
                        onPressed: c.isDeleting ? null : _confirmDelete,
                        text: c.isDeleting
                            ? 'Deleting...'
                            : strings.deleteAdButton,
                      ),
                      SizedBox(height: dimension.d16.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'closed':
        return 'Closed';
      default:
        return status.isEmpty
            ? 'Active'
            : '${status[0].toUpperCase()}${status.substring(1)}';
    }
  }
}
