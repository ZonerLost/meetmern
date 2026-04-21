import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_multi_select_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic> options;
  final Map<String, dynamic>? initialValues;

  const FilterScreen({
    super.key,
    required this.options,
    this.initialValues,
  });

  @override
  State<FilterScreen> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterScreen> {
  static const double _defaultDistanceKm = 15;
  static const double _defaultAgeMin = 20;
  static const double _defaultAgeMax = 45;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateRangeController = TextEditingController();
  DateTimeRange? _selectedRange;

  @override
  void dispose() {
    dateRangeController.dispose();
    super.dispose();
  }

  double _distanceKm = _defaultDistanceKm;
  RangeValues _ageRange = const RangeValues(_defaultAgeMin, _defaultAgeMax);

  final List<String> _orientationsSelected = [];
  String? _religion;
  String? _relationship;
  List<String> _languages = [];
  final List<String> _interests = [];
  DateTimeRange? _dateRange;
  String? _hostRating;
  String? _gender;

  List<String> get _genders => List<String>.from(
      widget.options['genders'] ?? OnboardingMockData.genders);
  List<String> get _orientations => List<String>.from(
      widget.options['orientations'] ?? OnboardingMockData.orientations);

  List<String> get _religions => _orderedDedupeList(
      widget.options['religion'] ?? OnboardingMockData.religion);
  List<String> get _relationships =>
      _orderedDedupeList(widget.options['relationship_status'] ??
          OnboardingMockData.relationshipStatus);
  List<String> get _languagesList => _orderedDedupeList(
      widget.options['languages'] ?? OnboardingMockData.languages);
  List<String> get _interestsList => _orderedDedupeList(
      widget.options['interests'] ?? OnboardingMockData.interests);
  List<String> get _hostRatings => _orderedDedupeList(
      widget.options['host_ratings'] ?? OnboardingMockData.hostRatings);

  List<String> _orderedDedupeList(dynamic maybeList) {
    if (maybeList == null) return <String>[];
    final seen = <String>{};
    final out = <String>[];
    if (maybeList is List) {
      for (var e in maybeList) {
        if (e == null) continue;
        final s = e.toString().trim();
        if (s.isEmpty) continue;
        if (!seen.contains(s)) {
          seen.add(s);
          out.add(s);
        }
      }
    } else {
      final s = maybeList.toString().trim();
      if (s.isNotEmpty) out.add(s);
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _restoreInitialValues();
  }

  bool get _canApply => _ageRange.start <= _ageRange.end && _distanceKm > 0;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange ?? _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: appTheme.black90001,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectedRange = picked;
      _dateRange = picked;

      String fmt(DateTime d) =>
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

      final formatted = "${fmt(picked.start)} -> ${fmt(picked.end)}";

      dateRangeController.text = formatted;

      setState(() {});
    }
  }

  void _toggleListItem(List<String> list, String item) {
    setState(() {
      if (list.contains(item))
        list.remove(item);
      else
        list.add(item);
    });
  }

  String _formatDateRange() {
    if (_dateRange == null) return strings.notSet;
    final s = _dateRange!.start;
    final e = _dateRange!.end;
    return '${s.day}/${s.month}/${s.year} - ${e.day}/${e.month}/${e.year}';
  }

  void _restoreInitialValues() {
    final initial = widget.initialValues;
    if (initial == null || initial.isEmpty) return;

    _distanceKm = (initial['distanceKm'] as num?)?.toDouble() ?? _distanceKm;

    final minAge = (initial['ageMin'] as num?)?.toDouble();
    final maxAge = (initial['ageMax'] as num?)?.toDouble();
    if (minAge != null && maxAge != null && minAge <= maxAge) {
      _ageRange = RangeValues(minAge, maxAge);
    }

    final gender = initial['gender']?.toString().trim();
    _gender = (gender == null || gender.isEmpty) ? null : gender;

    final orientationRaw = initial['orientation'];
    if (orientationRaw is String) {
      _orientationsSelected
        ..clear()
        ..addAll(orientationRaw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty));
    } else if (orientationRaw is List) {
      _orientationsSelected
        ..clear()
        ..addAll(orientationRaw
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty));
    }

    final religion = initial['religion']?.toString().trim();
    _religion = (religion == null || religion.isEmpty) ? null : religion;

    final relationship = initial['relationship']?.toString().trim();
    _relationship =
        (relationship == null || relationship.isEmpty) ? null : relationship;

    final languages = initial['languages'];
    if (languages is List) {
      _languages = languages
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final interests = initial['interests'];
    if (interests is List) {
      _interests
        ..clear()
        ..addAll(interests
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty));
    }

    final hostRating = initial['hostRating']?.toString().trim();
    _hostRating =
        (hostRating == null || hostRating.isEmpty) ? null : hostRating;

    final dateRange = initial['dateRange'];
    if (dateRange is Map) {
      final start = DateTime.tryParse(dateRange['start']?.toString() ?? '');
      final end = DateTime.tryParse(dateRange['end']?.toString() ?? '');
      if (start != null && end != null) {
        _dateRange = DateTimeRange(start: start, end: end);
        _selectedRange = _dateRange;
        dateRangeController.text = _formatDateRange();
      }
    }
  }

  String? _normalizedAny(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.toLowerCase() == strings.any.toLowerCase()) return null;
    return trimmed;
  }

  List<String> _normalizedList(List<String> values) {
    return values
        .map((e) => e.trim())
        .where(
          (e) => e.isNotEmpty && e.toLowerCase() != strings.any.toLowerCase(),
        )
        .toList(growable: false);
  }

  Map<String, dynamic> _buildResultMap() {
    final map = <String, dynamic>{};

    if ((_distanceKm - _defaultDistanceKm).abs() > 0.001) {
      map['distanceKm'] = _distanceKm;
    }
    if ((_ageRange.start - _defaultAgeMin).abs() > 0.001 ||
        (_ageRange.end - _defaultAgeMax).abs() > 0.001) {
      map['ageMin'] = _ageRange.start.toInt();
      map['ageMax'] = _ageRange.end.toInt();
    }

    final gender = _normalizedAny(_gender);
    if (gender != null) map['gender'] = gender;

    final orientation = _normalizedList(_orientationsSelected);
    if (orientation.isNotEmpty) map['orientation'] = orientation;

    final religion = _normalizedAny(_religion);
    if (religion != null) map['religion'] = religion;

    final relationship = _normalizedAny(_relationship);
    if (relationship != null) map['relationship'] = relationship;

    final languages = _normalizedList(_languages);
    if (languages.isNotEmpty) map['languages'] = languages;

    final interests = _normalizedList(_interests);
    if (interests.isNotEmpty) map['interests'] = interests;

    final hostRating = _normalizedAny(_hostRating);
    if (hostRating != null) map['hostRating'] = hostRating;

    if (_dateRange != null) {
      map['dateRange'] = {
        'start': _dateRange!.start.toIso8601String(),
        'end': _dateRange!.end.toIso8601String(),
      };
    }

    return map;
  }

  void _resetFilters() {
    setState(() {
      _distanceKm = _defaultDistanceKm;
      _ageRange = const RangeValues(_defaultAgeMin, _defaultAgeMax);
      _gender = null;
      _orientationsSelected.clear();
      _religion = null;
      _relationship = null;
      _languages = <String>[];
      _interests.clear();
      _hostRating = null;
      _dateRange = null;
      _selectedRange = null;
      dateRangeController.clear();
    });
  }

  Widget _buildSelectableChip(String label, List<String> list) {
    final selected = list.contains(label);

    final textColor = selected ? appTheme.b_600 : appTheme.neutral_700;

    return ChoiceChip(
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: dimension.d13,
              color: textColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (selected) ...[
            SizedBox(width: dimension.d6),
            Icon(
              Icons.close,
              size: dimension.d16,
              color: textColor,
            ),
          ]
        ],
      ),
      selected: selected,
      selectedColor: appTheme.b_100,
      backgroundColor: appTheme.infieldColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimension.d50),
        side: BorderSide(
          color: selected ? appTheme.coreWhite : appTheme.borderColor,
          width: dimension.d1_5,
        ),
      ),
      onSelected: (_) => _toggleListItem(list, label),
    );
  }

  Widget _circularSelector({required bool selected}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: dimension.d18,
      height: dimension.d18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? appTheme.blue800 : appTheme.coreWhite,
        border: Border.all(
          color: selected ? appTheme.blue800 : appTheme.neutral_700,
          width: dimension.d1_5,
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: selected
              ? Icon(
                  Icons.check,
                  key: const ValueKey('checked'),
                  size: dimension.d12,
                  color: appTheme.coreWhite,
                )
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }

  Widget _optionRow({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(dimension.d20),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: dimension.d8, vertical: dimension.d6),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _circularSelector(selected: selected),
          SizedBox(width: dimension.d10),
          Text(label,
              style: TextStyle(
                color: appTheme.neutral_700,
                fontWeight: FontWeight.normal,
              )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return SafeArea(
      child: Container(
        height: dimension.d700.h,
        padding: EdgeInsets.fromLTRB(
            dimension.d32.w, dimension.d28.h, dimension.d32.w, dimension.d36.h),
        decoration: BoxDecoration(
            color: appTheme.coreWhite,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(dimension.d48.r),
                topRight: Radius.circular(dimension.d48.r))),
        child: Column(children: [
          SizedBox(height: dimension.d12),
          Row(children: [
            Expanded(
                child: Text(strings.applySearchFilters,
                    style: customButtonandTextStyles.emailLabelTextStyle)),
            TextButton(
              onPressed: _resetFilters,
              child: Text(
                'Clear',
                style: customButtonandTextStyles.sliderTextStyle.copyWith(
                  color: appTheme.b_Primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close))
          ]),
          SizedBox(height: dimension.d6),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(bottom: dimension.d8),
                              child: Text(strings.distance,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle))),
                      SizedBox(
                        width: double.infinity,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              activeTrackColor: appTheme.b_Primary,
                              thumbColor: appTheme.b_100,
                              overlayColor: appTheme.b_400,
                              trackHeight: dimension.d4,
                              thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: dimension.d9)),
                          child: Slider(
                            value: _distanceKm,
                            min: dimension.d1,
                            max: dimension.d50,
                            divisions: 49,
                            label: _distanceKm.toStringAsFixed(0),
                            onChanged: (v) => setState(() => _distanceKm = v),
                          ),
                        ),
                      ),
                      Row(children: [
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: dimension.d10,
                                vertical: dimension.d8),
                            decoration: BoxDecoration(
                              color: appTheme.infieldColor,
                              border: Border.all(color: appTheme.borderColor),
                              borderRadius: BorderRadius.circular(dimension.d8),
                            ),
                            child: Text(strings.oneKm,
                                style: customButtonandTextStyles.sliderTextStyle
                                    .copyWith(
                                  color: Color.lerp(
                                    appTheme.neutral_400,
                                    appTheme.neutral_700,
                                    ((_distanceKm - dimension.d1) /
                                            (dimension.d50 - dimension.d1))
                                        .clamp(dimension.d0, dimension.d1),
                                  ),
                                ))),
                        const Spacer(),
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: dimension.d10.w,
                                vertical: dimension.d8.h),
                            decoration: BoxDecoration(
                              color: appTheme.infieldColor,
                              border: Border.all(color: appTheme.borderColor),
                              borderRadius: BorderRadius.circular(dimension.d8),
                            ),
                            child: Text('${_distanceKm.toStringAsFixed(0)} KM',
                                style: customButtonandTextStyles.sliderTextStyle
                                    .copyWith(
                                  color: Color.lerp(
                                    appTheme.neutral_400,
                                    appTheme.neutral_700,
                                    ((_distanceKm - dimension.d1) /
                                            (dimension.d50 - dimension.d1))
                                        .clamp(dimension.d0, dimension.d1),
                                  ),
                                ))),
                      ]),
                      SizedBox(height: dimension.d14),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(bottom: dimension.d8),
                              child: Text(strings.age,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle))),
                      SizedBox(
                        width: double.infinity,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              activeTrackColor: appTheme.b_Primary,
                              thumbColor: appTheme.b_100,
                              overlayColor: appTheme.b_400,
                              trackHeight: dimension.d4,
                              thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: dimension.d9)),
                          child: RangeSlider(
                            values: _ageRange,
                            min: dimension.d18,
                            max: dimension.d100,
                            divisions: 82,
                            labels: RangeLabels(
                                _ageRange.start.toInt().toString(),
                                _ageRange.end.toInt().toString()),
                            onChanged: (r) => setState(() => _ageRange = r),
                          ),
                        ),
                      ),
                      Row(children: [
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: dimension.d10,
                                vertical: dimension.d8),
                            decoration: BoxDecoration(
                              color: appTheme.coreWhite,
                              border: Border.all(color: appTheme.borderColor),
                              borderRadius: BorderRadius.circular(dimension.d8),
                            ),
                            child: Text(_ageRange.start.toInt().toString(),
                                style: customButtonandTextStyles.sliderTextStyle
                                    .copyWith(
                                  color: Color.lerp(
                                    appTheme.neutral_400,
                                    appTheme.neutral_700,
                                    ((_distanceKm - dimension.d1) /
                                            (dimension.d50 - dimension.d1))
                                        .clamp(dimension.d0, dimension.d1),
                                  ),
                                ))),
                        const Spacer(),
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: dimension.d10,
                                vertical: dimension.d8),
                            decoration: BoxDecoration(
                              color: appTheme.coreWhite,
                              border: Border.all(color: appTheme.borderColor),
                              borderRadius: BorderRadius.circular(dimension.d8),
                            ),
                            child: Text(_ageRange.end.toInt().toString(),
                                style: customButtonandTextStyles.sliderTextStyle
                                    .copyWith(
                                  color: Color.lerp(
                                    appTheme.neutral_400,
                                    appTheme.black90001,
                                    ((_distanceKm - dimension.d1) /
                                            (dimension.d50 - dimension.d1))
                                        .clamp(dimension.d0, dimension.d1),
                                  ),
                                ))),
                      ]),
                      SizedBox(height: dimension.d14),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(bottom: dimension.d8),
                              child: Text(strings.gender,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle))),
                      Wrap(
                        spacing: dimension.d12,
                        runSpacing: dimension.d8,
                        children: _genders.map((g) {
                          final value = g == strings.any ? null : g;
                          final isSelected = _gender == value;
                          return _optionRow(
                            label: g,
                            selected: isSelected,
                            onTap: () => setState(() => _gender = value),
                          );
                        }).toList(),
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(bottom: dimension.d8),
                              child: Text(strings.orientation,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle))),
                      Wrap(
                        spacing: dimension.d12,
                        runSpacing: dimension.d8,
                        children: _orientations.map((o) {
                          final isSelected = _orientationsSelected.contains(o);
                          return _optionRow(
                            label: o,
                            selected: isSelected,
                            onTap: () => setState(() {
                              if (isSelected)
                                _orientationsSelected.remove(o);
                              else
                                _orientationsSelected.add(o);
                            }),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: dimension.d12),
                      Text(
                        strings.religion,
                        style: customButtonandTextStyles.dobLabelTextStyle,
                      ),
                      CustomDropdownButton(
                        decoration:
                            customButtonandTextStyles.genderFInputDecoration,
                        hint: strings.selectReligion,
                        items: _religions,
                        value: _religion,
                        onChanged: (v) => setState(() => _religion = v),
                        itemHeight: dimension.d48.h,
                        menuMaxHeight: dimension.d200.h,
                        menuMaxWidth: dimension.d320.w,
                        alignMenuRight: true,
                      ),
                      SizedBox(height: dimension.d12),
                      Text(
                        strings.relationshipStatus,
                        style: customButtonandTextStyles.dobLabelTextStyle,
                      ),
                      CustomDropdownButton(
                        decoration:
                            customButtonandTextStyles.genderFInputDecoration,
                        hint: strings.relationshipHint,
                        items: _relationships,
                        value: _relationship,
                        onChanged: (v) => setState(() => _relationship = v),
                        itemHeight: dimension.d48.h,
                        menuMaxHeight: dimension.d200.h,
                        alignMenuRight: true,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.languagesSpoken,
                          style: customButtonandTextStyles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      CustomMultiSelectButton(
                        decoration:
                            customButtonandTextStyles.genderFInputDecoration,
                        hint: strings.selectLanguages,
                        items: _languagesList,
                        selectedValues: _languages,
                        onSelectionChanged: (list) => setState(() {
                          _languages = _orderedDedupeList(list);
                        }),
                      ),
                      SizedBox(height: dimension.d12),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(strings.interests,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle))),
                      Wrap(
                          spacing: dimension.d8,
                          runSpacing: dimension.d8,
                          children: _interestsList
                              .map((i) => _buildSelectableChip(i, _interests))
                              .toList()),
                      SizedBox(height: dimension.d8),
                      SizedBox(height: dimension.d12),
                      Text(
                        strings.hostRating,
                        style: customButtonandTextStyles.dobLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      CustomDropdownButton(
                        decoration:
                            customButtonandTextStyles.genderFInputDecoration,
                        hint: strings.hostRatingHint,
                        items: _hostRatings,
                        value: _hostRating,
                        onChanged: (v) => setState(() => _hostRating = v),
                        itemHeight: dimension.d48.h,
                        menuMaxHeight: dimension.d200.h,
                        alignMenuRight: true,
                      ),
                      SizedBox(height: dimension.d12),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(bottom: dimension.d8),
                              child: Text(strings.dateRange,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle))),
                      CustomTextFormField(
                        controller: dateRangeController,
                        readOnly: true,
                        onTap: _pickDateRange,
                        hintText: strings.selectDateRange,
                        inputDecoration:
                            customButtonandTextStyles.dateFieldInputDecoration(
                          suffix: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.date_range,
                              size: dimension.d20.w,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: _pickDateRange,
                          ),
                        ),
                      ),
                      SizedBox(height: dimension.d84),
                    ]),
              ),
            ),
          ),
          CustomElevatedButton(
            text: strings.applyFilters,
            buttonTextStyle: customButtonandTextStyles.loginButtonTextStyle
                .copyWith(
                    color: _canApply ? appTheme.coreWhite : appTheme.b_400),
            buttonStyle: customButtonandTextStyles.loginButtonStyle.copyWith(
              backgroundColor: WidgetStatePropertyAll(
                _canApply ? appTheme.b_Primary : appTheme.b_100,
              ),
              elevation: WidgetStatePropertyAll(
                  _canApply ? dimension.d6 : dimension.d0),
            ),
            onPressed: _canApply
                ? () {
                    Navigator.of(context).pop(_buildResultMap());
                  }
                : null,
          ),
        ]),
      ),
    );
  }
}
