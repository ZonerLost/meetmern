import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/data/models/app_notification_model.dart';
import 'package:meetmern/view/controllers/userprofile_controller/NotificationScreens/notification_controller.dart';

const _strings = Strings();
final _dimension = DimensionResource();
final _appTheme = ThemeHelper(appThemeName: _strings.lightCode).themeColor;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final styles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: ThemeHelper(appThemeName: _strings.lightCode).themeData,
    );

    return GetBuilder<NotificationController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: _appTheme.coreWhite,
          appBar: AppBar(
            backgroundColor: _appTheme.coreWhite,
            title: Text(
              _strings.notificationsText,
              style:
                  styles.titleTextStyle.copyWith(fontSize: _dimension.d22.sp),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            ),
            actions: [
              if (controller.unreadCount > 0)
                TextButton(
                      onPressed: controller.markAllAsRead,
                      child: Text(
                        'Mark all read',
                        style: TextStyle(
                      color: _appTheme.b_Primary,
                      fontWeight: FontWeight.w600,
                      fontSize: _dimension.d13.sp,
                        ),
                      ),
                    ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.loadNotifications,
          child: _buildBody(controller, styles),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    NotificationController controller,
    CustomButtonStyles styles,
  ) {
    if (controller.isLoading && controller.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null && controller.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(_dimension.d16.w),
          child: Text(
            controller.error!,
            style: styles.locationTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (controller.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: _dimension.d160.h),
          Center(
            child: Text(
              'No notifications yet.',
              style: styles.locationTextStyle,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
        _dimension.d12.w,
        _dimension.d10.h,
        _dimension.d12.w,
        _dimension.d16.h,
      ),
      itemCount: controller.notifications.length,
      separatorBuilder: (_, __) => SizedBox(height: _dimension.d8.h),
      itemBuilder: (_, index) {
        final item = controller.notifications[index];
        return _NotificationTile(
          item: item,
          onTap: () => controller.openNotification(item),
          onMarkRead: item.isRead
              ? null
              : () => controller.markAsRead(item.id),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
    this.onMarkRead,
  });

  final AppNotification item;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    final styles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: ThemeHelper(appThemeName: _strings.lightCode).themeData,
    );
    final createdAtLabel = _formatDateTime(item.createdAt.toLocal());

    return Material(
      color: item.isRead ? _appTheme.coreWhite : _appTheme.infieldColor,
      borderRadius: BorderRadius.circular(_dimension.d12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(_dimension.d12.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_dimension.d12.r),
            border: Border.all(color: _appTheme.borderColor),
          ),
          padding: EdgeInsets.all(_dimension.d12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title.trim().isNotEmpty ? item.title : 'Notification',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.dobLabelTextStyle.copyWith(
                        fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!item.isRead)
                    Container(
                      width: _dimension.d8.w,
                      height: _dimension.d8.w,
                      decoration: BoxDecoration(
                        color: _appTheme.b_Primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              SizedBox(height: _dimension.d6.h),
              Text(
                item.body.trim().isNotEmpty ? item.body : '-',
                style: styles.locationTextStyle,
              ),
              SizedBox(height: _dimension.d10.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      createdAtLabel,
                      style: styles.locationTextStyle.copyWith(
                        color: _appTheme.neutral_400,
                        fontSize: _dimension.d12.sp,
                      ),
                    ),
                  ),
                  if (onMarkRead != null)
                    TextButton(
                      onPressed: onMarkRead,
                      child: Text(
                        'Mark read',
                        style: TextStyle(
                          color: _appTheme.b_Primary,
                          fontWeight: FontWeight.w600,
                          fontSize: _dimension.d12.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
