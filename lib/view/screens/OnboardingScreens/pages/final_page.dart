import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/view/screens/HomeScreens/CreateMeetupScreen/create_meetup.dart';
import 'package:meetmern/view/screens/HomeScreens/ExploreScreen/explore_meetups_screen.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_model.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';

const strings = Strings();

class FinalPage extends StatelessWidget {
  final OnboardingModel model;
  final VoidCallback? onFinish;

  const FinalPage({super.key, required this.model, this.onFinish});

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(dimension.d20.w, dimension.d20.h,
              dimension.d20.w, dimension.d28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: dimension.d8.h),
              Center(
                child: Image.asset(strings.img7,
                    width: dimension.d366.w, height: dimension.d367.h),
              ),
              SizedBox(height: dimension.d20.h),
              Text(strings.readyTitle,
                  style: customButtonandTextStyles.titleTextStyle),
              SizedBox(height: dimension.d8.h),
              Text(strings.readySubtitle,
                  style: customButtonandTextStyles.subtitleTextStyle),
              SizedBox(height: dimension.d150.h),
              SizedBox(
                child: CustomOutlinedButton(
                  onPressed: () {
                    context.navigateToScreen(const CreateMeetupScreen());
                  },
                  text: strings.createMeetupText,
                  buttonStyle: customButtonandTextStyles.googleButtonStyle,
                  buttonTextStyle:
                      customButtonandTextStyles.googleButtonTextStyle,
                ),
              ),
              SizedBox(height: dimension.d20.h),
              SizedBox(
                child: CustomElevatedButton(
                  onPressed: () {
                    context.navigateToScreen(const ExploreMeetupsScreen());
                  },
                  buttonStyle: customButtonandTextStyles.loginButtonStyle,
                  text: strings.exploreMeetupsText,
                  buttonTextStyle:
                      customButtonandTextStyles.loginButtonTextStyle,
                ),
              ),
              SizedBox(height: dimension.d20.h),
            ],
          ),
        ),
      ),
    );
  }
}
