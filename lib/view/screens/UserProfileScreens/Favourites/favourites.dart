import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/userprofile_controller/Favourites/favourites_controller.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_rounded_tile.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final FavouritesController _controller = Get.find<FavouritesController>();

  @override
  void initState() {
    super.initState();
    _controller.loadFavourites();
  }

  ImageProvider _imageProvider(String? image) {
    if (image == null || image.trim().isEmpty) {
      return const AssetImage('assets/images/img9.jpg');
    }

    final trimmed = image.trim();
    final isNetwork =
        trimmed.startsWith('http://') || trimmed.startsWith('https://');

    return isNetwork ? NetworkImage(trimmed) : AssetImage(trimmed);
  }

  void _showRemoveDialog(Meetup meetup) {
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
            backgroundImage: _imageProvider(meetup.image),
          ),
          showCloseButton: true,
          title:
              '${strings.removeFromFavouritesTitlePrefixText} ${meetup.title}?',
          subtitle: strings.removeFromFavouritesSubtitleText,
          titleTextStyle: customButtonandTextStyles.emailLabelTextStyle,
          subtitleTextStyle: customButtonandTextStyles.locationTextStyle,
          primaryLabel: strings.yesRemoveText,
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

            _controller.setFavorite(meetup.id, false);

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  strings.removedFromFavouritesSnackText.replaceFirst(
                    '{name}',
                    meetup.title,
                  ),
                ),
                action: SnackBarAction(
                  label: strings.undoText,
                  onPressed: () {
                    _controller.setFavorite(meetup.id, true);
                  },
                ),
              ),
            );
          },
          onSecondary: () => Navigator.of(ctx).pop(),
        );
      },
    );
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
              strings.favoritesText,
              style: customButtonandTextStyles.emailLabelTextStyle.copyWith(
                fontSize: dimension.d20.sp,
              ),
            ),
            SizedBox(height: dimension.d16.h),
            Expanded(
              child: GetBuilder<FavouritesController>(
                builder: (controller) {
                  if (controller.isLoading) {
                    return Center(
                      child: SizedBox(
                        width: dimension.d28.w,
                        height: dimension.d28.h,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }

                  final favourites = controller.favourites;

                  if (favourites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: dimension.d60.h,
                            color: appTheme.neutral_300,
                          ),
                          SizedBox(height: dimension.d12.h),
                          Text(
                            strings.noFavouritesYetText,
                            style: TextStyle(
                              fontSize: dimension.d16.sp,
                              fontWeight: FontWeight.w600,
                              color: appTheme.black90001,
                            ),
                          ),
                          SizedBox(height: dimension.d6.h),
                          Text(
                            strings.tapStarToAddFavouriteText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: dimension.d14.sp,
                              color: appTheme.neutral_700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: favourites.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: dimension.d12.h),
                    itemBuilder: (context, index) {
                      final meetup = favourites[index];

                      return CustomRoundedTile(
                        title: meetup.title,
                        subtitle: '${meetup.hostName} - ${meetup.location}',
                        leadingImage: meetup.image,
                        trailingIcon: Icons.favorite_rounded,
                        onTap: () => _showRemoveDialog(meetup),
                        backgroundColor: appTheme.infieldColor,
                        borderColor: appTheme.borderColor,
                        borderWidth: dimension.d1.w,
                        borderRadius: BorderRadius.circular(dimension.d100.r),
                        iconBackgroundColor: appTheme.b_Primary,
                        iconColor: appTheme.coreWhite,
                        titletextStyle:
                            customButtonandTextStyles.dobLabelTextStyle,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
