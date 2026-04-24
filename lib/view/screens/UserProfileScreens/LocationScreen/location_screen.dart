import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/extensions/snackbar_extensions.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/controllers/userprofile_controller/LocationScreen/location_screen_controller.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return GetBuilder<LocationScreenController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: appTheme.coreWhite,
          appBar: AppBar(
            backgroundColor: appTheme.coreWhite,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: appTheme.neutral_800),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: SafeArea(
            child: controller.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: appTheme.b_Primary))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: dimension.d14.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: dimension.d8.h),
                                Text(
                                  strings.locationScreenTitle,
                                  style:
                                      customButtonandTextStyles.titleTextStyle,
                                ),
                                SizedBox(height: dimension.d8.h),
                                Text(
                                  strings.locationScreenSubtitle,
                                  style: customButtonandTextStyles
                                      .subtitleTextStyle,
                                ),
                                SizedBox(height: dimension.d20.h),

                                // Error banner
                                if (controller.errorMessage != null) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(dimension.d12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius:
                                          BorderRadius.circular(dimension.d8.r),
                                      border: Border.all(
                                          color: Colors.red.shade200),
                                    ),
                                    child: Text(
                                      controller.errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: dimension.d13.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: dimension.d15.h),
                                ],

                                Text(
                                  strings.currentLocationLabel,
                                  style: customButtonandTextStyles
                                      .emailLabelTextStyle,
                                ),
                                SizedBox(height: dimension.d8.h),
                                // Use my location row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    controller.isLocating
                                        ? SizedBox(
                                            width: dimension.d16.w,
                                            height: dimension.d16.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: appTheme.b_Primary,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap:
                                                controller.getCurrentLocation,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.my_location,
                                                  size: dimension.d16.sp,
                                                  color: appTheme.b_Primary,
                                                ),
                                                SizedBox(width: dimension.d4.w),
                                                Text(
                                                  'Use my location',
                                                  style: TextStyle(
                                                    color: appTheme.b_Primary,
                                                    fontSize: dimension.d13.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                                SizedBox(height: dimension.d8.h),
                                CustomTextFormField(
                                  controller: controller.locationController,
                                  readOnly: false,
                                  textInputType: TextInputType.streetAddress,
                                  hintText: strings.currentLocationHintText,
                                  textAlignVertical: TextAlignVertical.top,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: dimension.d14,
                                    vertical: dimension.d14,
                                  ),
                                  inputDecoration: customButtonandTextStyles
                                      .feedbackfInputDecoration
                                      .copyWith(
                                    floatingLabelStyle:
                                        TextStyle(color: appTheme.black90001),
                                    hintStyle: customButtonandTextStyles
                                        .dateFieldTextStyle
                                        .copyWith(
                                      color: appTheme.neutral_400,
                                      fontSize: dimension.d14,
                                    ),
                                  ),
                                ),
                                SizedBox(height: dimension.d15.h),
                                Text(
                                  strings.discoveryRadiusLabel,
                                  style: customButtonandTextStyles
                                      .emailLabelTextStyle,
                                ),
                                SizedBox(height: dimension.d8.h),
                                CustomTextFormField(
                                  controller: controller.radiusController,
                                  textInputType: TextInputType.number,
                                  hintText: 'Enter radius in km',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  suffix: Padding(
                                    padding: EdgeInsets.only(
                                      right: dimension.d14.w,
                                      top: dimension.d14.h,
                                      bottom: dimension.d14.h,
                                    ),
                                    child: Text(
                                      strings.kmLabel,
                                      style: customButtonandTextStyles
                                          .dateFieldTextStyle
                                          .copyWith(
                                        color: appTheme.neutral_600,
                                        fontSize: dimension.d14.sp,
                                      ),
                                    ),
                                  ),
                                  suffixConstraints: BoxConstraints(
                                    minWidth: dimension.d40.w,
                                    minHeight: dimension.d40.h,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: dimension.d14,
                                    vertical: dimension.d14,
                                  ),
                                  inputDecoration: customButtonandTextStyles
                                      .feedbackfInputDecoration
                                      .copyWith(
                                    floatingLabelStyle:
                                        TextStyle(color: appTheme.black90001),
                                    hintStyle: customButtonandTextStyles
                                        .dateFieldTextStyle
                                        .copyWith(
                                      color: appTheme.neutral_400,
                                      fontSize: dimension.d14,
                                    ),
                                  ),
                                ),
                                SizedBox(height: dimension.d24.h),
                                controller.isSaving
                                    ? Center(
                                        child: CircularProgressIndicator(
                                            color: appTheme.b_Primary))
                                    : CustomElevatedButton(
                                        onPressed: controller.canSave
                                            ? () async {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                final success = await controller
                                                    .saveLocationAndRadius();
                                                if (!context.mounted) return;
                                                if (success) {
                                                  context.showCustomSnackBar(
                                                    '${strings.locationUpdatedPrefixText}${controller.locationController.text.trim()}',
                                                  );
                                                  Navigator.of(context).pop();
                                                } else {
                                                  context.showSnackbar(controller
                                                          .errorMessage ??
                                                      strings
                                                          .locationRequiredText);
                                                }
                                              }
                                            : null,
                                        buttonStyle: customButtonandTextStyles
                                            .deleteButtonStyle,
                                        text: strings.updateLocationButtonText,
                                        buttonTextStyle:
                                            customButtonandTextStyles
                                                .loginButtonTextStyle,
                                      ),
                                SizedBox(height: dimension.d24.h),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
