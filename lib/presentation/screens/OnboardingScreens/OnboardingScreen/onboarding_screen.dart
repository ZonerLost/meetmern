import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/mock/onboarding_mock_data.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/model/onboarding_model.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/about_page.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/basics_page.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/final_page.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/interests_page.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/location_page.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/photo_page.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/strings/strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingModel model = OnboardingModel();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();

  String? selectedGender;
  String? selectedOrientation;
  String? selectedEthnicity;
  String? selectedChildren;
  String? selectedRelationship;
  String? selectedReligion;
  List<String> selectedLanguages = [];
  List<String> selectedDietary = [];

  final Set<String> selectedInterests = {};
  final Set<String> selectedPassions = {};

  File? pickedImage;

  final Map<String, dynamic> options = {
    'gender': OnboardingMockData.genders,
    'orientation': OnboardingMockData.orientations,
    'ethnicity': OnboardingMockData.ethnicities,
    'languages': OnboardingMockData.languages,
    'children': OnboardingMockData.children,
    'relationship_status': OnboardingMockData.relationshipStatus,
    'religion': OnboardingMockData.religion,
    'interests': OnboardingMockData.interests,
    'passion_topics': OnboardingMockData.passionTopics,
    'Dietarypreferences': OnboardingMockData.dietaryPreferences,
  };

  bool showErrors = false;
  int currentPage = 0;
  static const int pages = 6;
  final strings = const Strings();

  @override
  void dispose() {
    _pageController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker p = ImagePicker();
    final XFile? f =
        await p.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (f != null) setState(() => pickedImage = File(f.path));
  }

  void _removeImage() => setState(() => pickedImage = null);

  bool _isValidForPage(int page) {
    if (page == 0) {
      final dobOk = _dobController.text.trim().isNotEmpty;
      final genderOk = selectedGender != null;
      final ethnicityOk = selectedEthnicity != null;
      final orientationOk = selectedOrientation != null;
      return dobOk && genderOk && ethnicityOk && orientationOk;
    } else if (page == 1) {
      return true;
    } else if (page == 2) {
      final relationshipOk = selectedRelationship != null;
      final childrenOk = selectedChildren != null;
      return relationshipOk && childrenOk;
    } else if (page == 3) {
      return selectedInterests.isNotEmpty || selectedPassions.isNotEmpty;
    } else {
      return true;
    }
  }

  void _onNextPressed() {
    setState(() => showErrors = true);
    if (!_isValidForPage(currentPage)) return;
    if (currentPage == 0) {
      model.dob = _dobController.text;
      model.gender = selectedGender;
      model.ethnicity = selectedEthnicity;
      model.orientation = selectedOrientation;
      model.languages = selectedLanguages;
    } else if (currentPage == 1) {
      model.photoPath = pickedImage?.path;
    } else if (currentPage == 2) {
      model.bio = _bioController.text;
      model.children = selectedChildren;
      model.relationshipStatus = selectedRelationship;
      model.dietaryPreferences = selectedDietary;
      model.religion = selectedReligion;
    } else if (currentPage == 3) {
      model.interests = selectedInterests.toList();
      model.passionTopics = selectedPassions.toList();
    }

    if (currentPage < pages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.navigateToScreen(const SizedBox());
    }
  }

  void _onBack() {
    if (currentPage == 0) {
      Navigator.of(context).maybePop();
    } else {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => showErrors = false);
    }
  }

  void _onDisabledTap() => setState(() => showErrors = true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      body: SafeArea(
        child: Column(children: [
          OnboardingTopbar(current: currentPage, total: pages, onBack: _onBack),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const AlwaysScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() {
                currentPage = i;
                showErrors = false;
              }),
              children: [
                BasicsPage(
                  options: options,
                  dobController: _dobController,
                  selectedGender: selectedGender,
                  onGenderChanged: (v) => setState(() => selectedGender = v),
                  selectedEthnicity: selectedEthnicity,
                  onEthnicityChanged: (v) =>
                      setState(() => selectedEthnicity = v),
                  selectedOrientation: selectedOrientation,
                  onOrientationChanged: (v) =>
                      setState(() => selectedOrientation = v),
                  selectedLanguages: selectedLanguages,
                  onLanguageChanged: (v) =>
                      setState(() => selectedLanguages = v),
                  showErrors: showErrors,
                  onNext: _onNextPressed,
                  stepValid: _isValidForPage(0),
                  onDisabledTap: _onDisabledTap,
                ),
                PhotoPage(
                  pickedImage: pickedImage,
                  onPick: (f) => setState(() => pickedImage = f),
                  onRemove: _removeImage,
                  onNext: _onNextPressed,
                  stepValid: _isValidForPage(1),
                  onDisabledTap: _onDisabledTap,
                ),
                AboutPage(
                  options: options,
                  selectedChildren: selectedChildren,
                  onChildrenChanged: (v) =>
                      setState(() => selectedChildren = v),
                  selectedRelationship: selectedRelationship,
                  onRelationshipChanged: (v) =>
                      setState(() => selectedRelationship = v),
                  selectedReligion: selectedReligion,
                  onReligionChanged: (v) =>
                      setState(() => selectedReligion = v),
                  bioController: _bioController,
                  selectedDietary: selectedDietary,
                  onDietaryChanged: (v) => setState(() => selectedDietary = v),
                  showErrors: showErrors,
                  onNext: _onNextPressed,
                  stepValid: _isValidForPage(2),
                  onDisabledTap: _onDisabledTap,
                ),
                InterestsPage(
                  options: options,
                  selectedInterests: selectedInterests,
                  onToggleInterest: (it, sel) => setState(() {
                    if (sel)
                      selectedInterests.add(it);
                    else
                      selectedInterests.remove(it);
                  }),
                  selectedPassions: selectedPassions,
                  onTogglePassion: (p, sel) => setState(() {
                    if (sel)
                      selectedPassions.add(p);
                    else
                      selectedPassions.remove(p);
                  }),
                  showErrors: showErrors,
                  onNext: _onNextPressed,
                  stepValid: _isValidForPage(3),
                  onDisabledTap: _onDisabledTap,
                ),
                LocationPage(
                  onNext: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
                  stepValid: _isValidForPage(4),
                  onDisabledTap: _onDisabledTap,
                ),
                FinalPage(
                  model: model,
                  onFinish: () {
                    context.navigateToScreen(const SizedBox());
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
