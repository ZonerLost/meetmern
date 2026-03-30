import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/utils/extensions/snackbar_extensions.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_drop_down_button.dart';
import 'package:meetmern/utils/widgets/custom_elevated_button.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _selectedRadius = const Strings().radiusOptions.first;

  final TextEditingController _locationCtrl =
      TextEditingController(text: 'Berlin, Mitte');

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  void _updateLocation() {
    const strings = Strings();
    final newLocation = _locationCtrl.text.trim();

    if (newLocation.isEmpty) {
      context.showSnackbar(strings.locationRequiredText);

      return;
    }

    context.showCustomSnackBar(
      '${strings.locationUpdatedPrefixText}$newLocation',
    );

    Navigator.of(context).pop();
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: appTheme.neutral_800,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: dimension.d14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: dimension.d8.h),
                      Text(
                        strings.locationScreenTitle,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      Text(
                        strings.locationScreenSubtitle,
                        style: customButtonandTextStyles.subtitleTextStyle,
                      ),
                      SizedBox(height: dimension.d20.h),
                      Text(
                        strings.currentLocationLabel,
                        style: customButtonandTextStyles.emailLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
                        controller: _locationCtrl,
                        readOnly: false,
                        textInputType: TextInputType.streetAddress,
                        hintText: strings.descriptionHintText,
                        textAlignVertical: TextAlignVertical.top,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: dimension.d14,
                          vertical: dimension.d14,
                        ),
                        inputDecoration: customButtonandTextStyles
                            .feedbackfInputDecoration
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
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: dimension.d15.h),
                      Text(
                        strings.discoveryRadiusLabel,
                        style: customButtonandTextStyles.emailLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      CustomDropdownButton(
                        decoration:
                            customButtonandTextStyles.feedbackfInputDecoration,
                        hint: strings.selectRadiusHintText,
                        items: strings.radiusOptions,
                        value: _selectedRadius,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _selectedRadius = v);
                        },
                        itemHeight: dimension.d48.h,
                        menuMaxHeight: dimension.d200.h,
                        menuMaxWidth: dimension.d320.w,
                        alignMenuRight: true,
                      ),
                      SizedBox(height: dimension.d24.h),
                      CustomElevatedButton(
                        onPressed: _updateLocation,
                        buttonStyle:
                            customButtonandTextStyles.deleteButtonStyle,
                        text: strings.updateLocationButtonText,
                        buttonTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
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
  }
}
