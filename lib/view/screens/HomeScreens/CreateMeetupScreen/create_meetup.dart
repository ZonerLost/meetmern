import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/profile_service.dart';
import 'package:meetmern/main.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/review_meetup.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/meetup_draft.dart';
import 'package:meetmern/core/extensions/date_picker_extension.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/map_picker_screen.dart';

class CreateMeetupScreen extends StatefulWidget {
  final String? origin;
  // When provided, the screen opens in edit mode, prefilled with the
  // existing meetup's details; saving updates it instead of creating a new
  // meetup.
  final Meetup? existingMeetup;
  const CreateMeetupScreen({super.key, this.origin, this.existingMeetup});
  @override
  State<CreateMeetupScreen> createState() => _CreateMeetupScreenState();
}

class _CreateMeetupScreenState extends State<CreateMeetupScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  int selectedTypeIndex = -1;

  bool _repeat = false;
  String _repeatRule = 'Every Monday';

  double? _pickedLat;
  double? _pickedLng;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool get _isEditing => widget.existingMeetup != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMeetup;
    if (existing != null) {
      // Defense in depth: expired meetups are read-only even if this
      // screen is ever reached directly with one (the normal entry point
      // already hides/disables the Edit action for expired meetups).
      if (existing.isExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expired meetups can’t be edited.')),
          );
          Navigator.of(context).maybePop();
        });
        return;
      }
      _prefillFromExisting(existing);
    } else {
      _prefillAddress();
    }
  }

  void _prefillFromExisting(Meetup meetup) {
    selectedTypeIndex = MeetupType.values.indexWhere(
      (t) => _typeToLabel(t).toLowerCase() == meetup.type.trim().toLowerCase(),
    );
    addressController.text = meetup.location;
    _pickedLat = meetup.latitude;
    _pickedLng = meetup.longitude;
    _selectedDate = meetup.time;
    _selectedTime = TimeOfDay.fromDateTime(meetup.time);
    dateController.text = formatDate(meetup.time);
    timeController.text = _formatTimeOfDay(_selectedTime!);
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _typeToLabel(MeetupType t) {
    const strings = Strings();
    switch (t) {
      case MeetupType.coffee:
        return strings.typeCoffee;
      case MeetupType.drink:
        return strings.typeDrink;
      case MeetupType.meal:
        return strings.typeMeal;
    }
  }

  Future<void> _prefillAddress() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    final profile = await ProfileService.getLocationAndRadius(userId);
    if (!mounted) return;
    if (profile?.location != null && profile!.location!.isNotEmpty) {
      setState(() => addressController.text = profile.location!);
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  String formatDate(DateTime d) {
    return '${d.day} ${Strings.monthNames[d.month - 1]} ${d.year}';
  }

  bool get isStepValid {
    return selectedTypeIndex != -1 &&
        addressController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty;
  }

  void _onAddressChanged(String value) {
    if (_pickedLat == null && _pickedLng == null) return;
    setState(() {
      _pickedLat = null;
      _pickedLng = null;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<MapPickerResult>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: _pickedLat,
          initialLng: _pickedLng,
          initialAddress:
              addressController.text.isNotEmpty ? addressController.text : null,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _pickedLat = result.latitude;
        _pickedLng = result.longitude;
        if (result.address.isNotEmpty) {
          addressController.text = result.address;
        }
      });
    }
  }

  void _goToReview() async {
    final MeetupType? type =
        (selectedTypeIndex >= 0 && selectedTypeIndex < MeetupType.values.length)
            ? MeetupType.values[selectedTypeIndex]
            : null;

    final draft = MeetupDraft(
      type: type,
      address: addressController.text.trim(),
      date: _selectedDate,
      time: _selectedTime,
      repeat: _repeat,
      repeatRule: _repeat ? _repeatRule : 'Does not repeat',
      latitude: _pickedLat,
      longitude: _pickedLng,
      existingMeetupId: widget.existingMeetup?.id,
    );

    FocusScope.of(context).unfocus();

    final Meetup? created = await Navigator.of(context).push<Meetup?>(
      MaterialPageRoute(
          builder: (_) =>
              ReviewMeetupScreen(draft: draft, origin: widget.origin)),
    );

    if (!mounted) return;
    if (created != null) {
      Navigator.of(context).pop(created);
    }
  }

  void _onTapType(int i) {
    setState(() {
      selectedTypeIndex = selectedTypeIndex == i ? -1 : i;
    });
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
    final types = [
      {"icon": Icons.coffee, "label": strings.typeCoffee},
      {"icon": Icons.local_bar, "label": strings.typeDrink},
      {"icon": Icons.restaurant, "label": strings.typeMeal},
    ];

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        elevation: dimension.d0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.black90001),
          onPressed: () => context.popScreen(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              dimension.d18.w,
              dimension.d18.h,
              dimension.d18.w,
              dimension.d140.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEditing ? 'Edit Meetup' : strings.createMeetupText,
                    style: customButtonandTextStyles.titleTextStyle),
                SizedBox(height: dimension.d6.h),
                Text(strings.requestMeetupSubtitle,
                    style: customButtonandTextStyles.emailLabelTextStyle),
                SizedBox(height: dimension.d22.h),
                Text(strings.typesLabel,
                    style: customButtonandTextStyles.dobLabelTextStyle),
                SizedBox(height: dimension.d10.h),
                Row(
                  children: List.generate(types.length, (i) {
                    final isSelected = selectedTypeIndex == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTapType(i),
                        child: Container(
                          margin: EdgeInsets.only(
                              right: i != types.length - dimension.d1
                                  ? dimension.d10.w
                                  : dimension.d10),
                          padding: EdgeInsets.symmetric(
                              vertical: dimension.d18.h,
                              horizontal: dimension.d15.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? appTheme.b_Primary
                                  : appTheme.borderColor,
                            ),
                            color: isSelected
                                ? appTheme.b_100
                                : appTheme.coreWhite,
                            borderRadius: BorderRadius.circular(dimension.d12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(types[i]['icon'] as IconData,
                                  size: dimension.d28.sp,
                                  color: appTheme.b_Primary),
                              SizedBox(height: dimension.d8.h),
                              Text(types[i]['label'] as String,
                                  style: TextStyle(fontSize: dimension.d14.sp)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: dimension.d12.h),
                SizedBox(height: dimension.d18.h),
                Text(strings.addressLabel,
                    style: customButtonandTextStyles.dobLabelTextStyle),
                SizedBox(height: dimension.d8.h),
                CustomTextFormField(
                    controller: addressController,
                    textInputType: TextInputType.streetAddress,
                    onChanged: _onAddressChanged,
                    inputDecoration: customButtonandTextStyles
                        .addresFInputDecoration
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _pickedLat != null ? Icons.map : Icons.map_outlined,
                          color: _pickedLat != null ? appTheme.b_Primary : null,
                        ),
                        onPressed: _openMapPicker,
                      ),
                    )),
                SizedBox(height: dimension.d14.h),
                Text(strings.dateAndTimeLabel,
                    style: customButtonandTextStyles.dobLabelTextStyle),
                SizedBox(height: dimension.d14.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          dateController.pickDate(
                            context: context,
                            initialDate: _selectedDate,
                            format: (d) => formatDate(d),
                            onPicked: (picked) => setState(() {
                              _selectedDate = picked;
                              // Clear time if it's now in the past for today.
                              if (_selectedTime != null) {
                                final now = DateTime.now();
                                final isToday = picked.year == now.year &&
                                    picked.month == now.month &&
                                    picked.day == now.day;
                                if (isToday) {
                                  final pickedDt = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      _selectedTime!.hour,
                                      _selectedTime!.minute);
                                  if (!pickedDt.isAfter(now)) {
                                    _selectedTime = null;
                                    timeController.clear();
                                  }
                                }
                              }
                            }),
                          );
                        },
                        child: AbsorbPointer(
                          child: CustomTextFormField(
                              controller: dateController,
                              inputDecoration: customButtonandTextStyles
                                  .datefInputDecoration),
                        ),
                      ),
                    ),
                    SizedBox(width: dimension.d10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final now = DateTime.now();
                          final isToday = _selectedDate != null &&
                              _selectedDate!.year == now.year &&
                              _selectedDate!.month == now.month &&
                              _selectedDate!.day == now.day;
                          // For today, start the clock at the next minute.
                          final minTime = isToday
                              ? TimeOfDay(
                                  hour: now.minute < 59
                                      ? now.hour
                                      : (now.hour + 1) % 24,
                                  minute: now.minute < 59 ? now.minute + 1 : 0,
                                )
                              : const TimeOfDay(hour: 0, minute: 0);
                          timeController.pickTime(
                            context: context,
                            initialTime: (_selectedTime != null &&
                                    (!isToday ||
                                        _selectedTime!.hour > minTime.hour ||
                                        (_selectedTime!.hour == minTime.hour &&
                                            _selectedTime!.minute >=
                                                minTime.minute)))
                                ? _selectedTime
                                : minTime,
                            onPicked: (t) {
                              if (isToday) {
                                final picked = DateTime(now.year, now.month,
                                    now.day, t.hour, t.minute);
                                if (!picked.isAfter(now)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please select a future time.')),
                                  );
                                  return;
                                }
                              }
                              setState(() => _selectedTime = t);
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: CustomTextFormField(
                              controller: timeController,
                              inputDecoration: customButtonandTextStyles
                                  .timeFInputDecoration),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: dimension.d8.h),
                Text(strings.repetitionLabel,
                    style: customButtonandTextStyles.dobLabelTextStyle),
                SizedBox(height: dimension.d12.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _repeat = true),
                      child: Row(
                        children: [
                          Container(
                            width: dimension.d22.w,
                            height: dimension.d22.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _repeat
                                  ? appTheme.b_Primary
                                  : appTheme.coreWhite,
                              border: Border.all(
                                  color: _repeat
                                      ? appTheme.b_Primary
                                      : appTheme.neutral_700,
                                  width: dimension.d2.w),
                            ),
                            child: _repeat
                                ? Center(
                                    child: Icon(Icons.check,
                                        size: dimension.d14.w,
                                        color: appTheme.coreWhite))
                                : null,
                          ),
                          SizedBox(width: dimension.d8.w),
                          Text(strings.repeatLabel,
                              style: TextStyle(
                                  fontSize: dimension.d14.sp,
                                  color: appTheme.neutral_700)),
                        ],
                      ),
                    ),
                    SizedBox(width: dimension.d24.w),
                    GestureDetector(
                      onTap: () => setState(() => _repeat = false),
                      child: Row(
                        children: [
                          Container(
                            width: dimension.d22.w,
                            height: dimension.d22.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: !_repeat
                                  ? appTheme.b_Primary
                                  : appTheme.coreWhite,
                              border: Border.all(
                                  color: !_repeat
                                      ? appTheme.b_Primary
                                      : appTheme.neutral_700,
                                  width: dimension.d2.w),
                            ),
                            child: !_repeat
                                ? Center(
                                    child: Icon(Icons.check,
                                        size: dimension.d14.w,
                                        color: appTheme.coreWhite))
                                : null,
                          ),
                          SizedBox(width: dimension.d8.w),
                          Text(strings.doesNotRepeatLabel,
                              style:
                                  customButtonandTextStyles.userNameTextStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: dimension.d12.h),
                if (_repeat)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: dimension.d12.w, vertical: dimension.d8.h),
                    decoration: BoxDecoration(
                      color: appTheme.coreWhite,
                      borderRadius: BorderRadius.circular(dimension.d8),
                      border: Border.all(color: appTheme.neutral_700),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        items: strings.repeatOptions
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        value: _repeatRule,
                        onChanged: (v) =>
                            setState(() => _repeatRule = v ?? _repeatRule),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(
            dimension.d20.w, dimension.d8.h, dimension.d20.w, dimension.d12.h),
        child: SizedBox(
          height: dimension.d56.h,
          width: double.infinity,
          child: CustomElevatedButton(
            onPressed: isStepValid
                ? _goToReview
                : () => _showSnack(strings.pleaseFillFields),
            buttonStyle:
                customButtonandTextStyles.cnextButtonStyle(isStepValid),
            text: strings.nextButtonText,
            buttonTextStyle: TextStyle(
              fontSize: dimension.d16.sp,
              fontWeight: FontWeight.w600,
              color: isStepValid ? appTheme.coreWhite : appTheme.b_400,
            ),
          ),
        ),
      ),
    );
  }
}
