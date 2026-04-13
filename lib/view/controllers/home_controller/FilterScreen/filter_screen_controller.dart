import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';

class FilterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController dateRangeController = TextEditingController();

  late Map<String, dynamic> options;

  double distanceKm = 15;
  RangeValues ageRange = const RangeValues(20, 45);

  final List<String> orientationsSelected = <String>[];
  String? religion;
  String? relationship;
  List<String> languages = <String>[];
  final List<String> interests = <String>[];
  DateTimeRange? dateRange;
  String? hostRating;
  String? gender;

  void initialize(Map<String, dynamic> initialOptions) {
    options = initialOptions;
    update();
  }

  List<String> get genders =>
      List<String>.from(options['genders'] ?? OnboardingMockData.genders);

  List<String> get orientations =>
      List<String>.from(options['orientations'] ?? OnboardingMockData.orientations);

  List<String> get religions =>
      _orderedDedupeList(options['religion'] ?? OnboardingMockData.religion);

  List<String> get relationships =>
      _orderedDedupeList(options['relationship_status'] ?? OnboardingMockData.relationshipStatus);

  List<String> get languagesList =>
      _orderedDedupeList(options['languages'] ?? OnboardingMockData.languages);

  List<String> get interestsList =>
      _orderedDedupeList(options['interests'] ?? OnboardingMockData.interests);

  List<String> get hostRatings =>
      _orderedDedupeList(options['host_ratings'] ?? OnboardingMockData.hostRatings);

  List<String> _orderedDedupeList(dynamic maybeList) {
    if (maybeList == null) return <String>[];
    final Set<String> seen = <String>{};
    final List<String> out = <String>[];
    if (maybeList is List) {
      for (final e in maybeList) {
        if (e == null) continue;
        final s = e.toString().trim();
        if (s.isEmpty || seen.contains(s)) continue;
        seen.add(s);
        out.add(s);
      }
      return out;
    }
    final single = maybeList.toString().trim();
    if (single.isNotEmpty) out.add(single);
    return out;
  }

  bool get canApply =>
      ageRange.start <= ageRange.end &&
      distanceKm > 0 &&
      gender != null &&
      orientationsSelected.isNotEmpty &&
      religion != null &&
      religion!.trim().isNotEmpty &&
      relationship != null &&
      relationship!.trim().isNotEmpty &&
      languages.isNotEmpty &&
      interests.isNotEmpty &&
      dateRange != null &&
      hostRating != null &&
      hostRating!.trim().isNotEmpty;

  void setDistance(double value) { distanceKm = value; update(); }
  void setAgeRange(RangeValues value) { ageRange = value; update(); }
  void setGender(String? value) { gender = value; update(); }

  void toggleOrientation(String value) {
    if (orientationsSelected.contains(value)) {
      orientationsSelected.remove(value);
    } else {
      orientationsSelected.add(value);
    }
    update();
  }

  void setReligion(String? value) { religion = value; update(); }
  void setRelationship(String? value) { relationship = value; update(); }
  void setLanguages(List<String> value) { languages = _orderedDedupeList(value); update(); }

  void toggleInterest(String value) {
    if (interests.contains(value)) {
      interests.remove(value);
    } else {
      interests.add(value);
    }
    update();
  }

  void setHostRating(String? value) { hostRating = value; update(); }

  void setDateRange(DateTimeRange? value) {
    dateRange = value;
    if (value != null) {
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      dateRangeController.text = '${fmt(value.start)}  →  ${fmt(value.end)}';
    }
    update();
  }

  Map<String, dynamic> buildResultMap() => <String, dynamic>{
        'distanceKm': distanceKm,
        'ageMin': ageRange.start.toInt(),
        'ageMax': ageRange.end.toInt(),
        'gender': gender,
        'orientation': orientationsSelected.isEmpty ? null : orientationsSelected.join(','),
        'religion': religion,
        'relationship': relationship,
        'languages': languages,
        'interests': interests,
        'hostRating': hostRating,
        'dateRange': dateRange == null
            ? null
            : {'start': dateRange!.start.toIso8601String(), 'end': dateRange!.end.toIso8601String()},
      };

  @override
  void onClose() {
    dateRangeController.dispose();
    super.onClose();
  }
}
