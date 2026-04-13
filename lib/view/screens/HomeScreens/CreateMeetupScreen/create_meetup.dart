import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/screens/HomeScreens/CreateMeetupScreen/review_meetup.dart';
import 'package:meetmern/core/extensions/date_picker_extension.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

enum MeetupType { coffee, drink, meal }

class MeetupDraft {
  MeetupType? type;
  String address;
  DateTime? date;
  TimeOfDay? time;
  bool repeat;
  String repeatRule;

  MeetupDraft({
    this.type,
    this.address = '',
    this.date,
    this.time,
    this.repeat = false,
    this.repeatRule = '',
  });

  DateTime? get dateTime {
    if (date == null || time == null) return null;
    return DateTime(
        date!.year, date!.month, date!.day, time!.hour, time!.minute);
  }
}

class CreateMeetupScreen extends StatefulWidget {
  final String? origin;
  const CreateMeetupScreen({super.key, this.origin});
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

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
    );

    FocusScope.of(context).unfocus();

    final Meetup? created = await Navigator.of(context).push<Meetup?>(
      MaterialPageRoute(
          builder: (_) =>
              ReviewMeetupScreen(draft: draft, origin: widget.origin)),
    );

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
                Text(strings.createMeetupText,
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
                                  : dimension.d0),
                          padding: EdgeInsets.symmetric(
                              vertical: dimension.d18.h,
                              horizontal: dimension.d8.w),
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
                    inputDecoration:
                        customButtonandTextStyles.addresFInputDecoration),
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
                            onPicked: (picked) =>
                                setState(() => _selectedDate = picked),
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
                          timeController.pickTime(
                            context: context,
                            initialTime: _selectedTime,
                            onPicked: (t) => setState(() => _selectedTime = t),
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
