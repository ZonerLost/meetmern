import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/onboarding_controller/OnboardingScreen/onboarding_screen_controller.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/about_page.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/basics_page.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/final_page.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/interests_page.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/location_page.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/photo_page.dart';
import 'package:meetmern/core/constants/app_strings.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      builder: (controller) => Scaffold(
        backgroundColor: appTheme.coreWhite,
        body: SafeArea(
          child: Column(children: [
            OnboardingTopbar(
              current: controller.currentPage,
              total: OnboardingController.pages,
              onBack: controller.onBack,
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: controller.setCurrentPage,
                children: [
                  BasicsPage(
                    options: controller.options,
                    dobController: controller.dobController,
                    selectedGender: controller.selectedGender,
                    onGenderChanged: controller.setGender,
                    selectedEthnicity: controller.selectedEthnicity,
                    onEthnicityChanged: controller.setEthnicity,
                    selectedOrientation: controller.selectedOrientation,
                    onOrientationChanged: controller.setOrientation,
                    selectedLanguages: controller.selectedLanguages,
                    onLanguageChanged: controller.setLanguages,
                    showErrors: controller.showErrors,
                    onNext: controller.onNextPressed,
                    stepValid: controller.isValidForPage(0),
                    onDisabledTap: controller.enableErrors,
                  ),
                  PhotoPage(
                    pickedImage: controller.pickedImage,
                    onPick: (f) {
                      controller.pickedImage = f;
                      controller.update();
                    },
                    onRemove: controller.removeImage,
                    onNext: controller.onNextPressed,
                    stepValid: controller.isValidForPage(1),
                    onDisabledTap: controller.enableErrors,
                  ),
                  AboutPage(
                    options: controller.options,
                    selectedChildren: controller.selectedChildren,
                    onChildrenChanged: controller.setChildren,
                    selectedRelationship: controller.selectedRelationship,
                    onRelationshipChanged: controller.setRelationship,
                    selectedReligion: controller.selectedReligion,
                    onReligionChanged: controller.setReligion,
                    bioController: controller.bioController,
                    selectedDietary: controller.selectedDietary,
                    onDietaryChanged: controller.setDietary,
                    showErrors: controller.showErrors,
                    onNext: controller.onNextPressed,
                    stepValid: controller.isValidForPage(2),
                    onDisabledTap: controller.enableErrors,
                  ),
                  InterestsPage(
                    options: controller.options,
                    selectedInterests: controller.selectedInterests,
                    onToggleInterest: controller.toggleInterest,
                    selectedPassions: controller.selectedPassions,
                    onTogglePassion: controller.togglePassion,
                    showErrors: controller.showErrors,
                    onNext: controller.onNextPressed,
                    stepValid: controller.isValidForPage(3),
                    onDisabledTap: controller.enableErrors,
                  ),
                  LocationPage(
                    onNext: () => controller.pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    stepValid: controller.isValidForPage(4),
                    onDisabledTap: controller.enableErrors,
                  ),
                  FinalPage(
                    model: controller.model,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
