import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class RequestMeetupScreen extends StatefulWidget {
  const RequestMeetupScreen({super.key});

  @override
  State<RequestMeetupScreen> createState() => _RequestMeetupScreenState();
}

class _RequestMeetupScreenState extends State<RequestMeetupScreen> {
  int selectedTypeIndex = -1;
  final addressController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  final dimension = DimensionResource();
  final strings = const Strings();

  @override
  void initState() {
    super.initState();
    addressController.addListener(_onControllerChanged);
    dateController.addListener(_onControllerChanged);
    timeController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    addressController.removeListener(_onControllerChanged);
    dateController.removeListener(_onControllerChanged);
    timeController.removeListener(_onControllerChanged);

    addressController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  String formatDate(DateTime d) {
    const monthNames = Strings.monthNames;
    return '${d.day} ${monthNames[d.month - 1]} ${d.year}';
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      dateController.text = formatDate(picked);
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      timeController.text = '$hour:$minute $period';
    }
  }

  bool get canSend {
    return selectedTypeIndex != -1 &&
        addressController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty;
  }

  void _clearAllFields() {
    selectedTypeIndex = -1;
    addressController.clear();
    dateController.clear();
    timeController.clear();
    setState(() {});
  }

  void _onTapType(int i) {
    setState(() {
      selectedTypeIndex = selectedTypeIndex == i ? -1 : i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final types = [
      {"icon": Icons.coffee, "label": strings.typeCoffee},
      {"icon": Icons.local_bar, "label": strings.typeDrink},
      {"icon": Icons.restaurant, "label": strings.typeMeal},
    ];
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        elevation: dimension.d0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              dimension.d18,
              dimension.d18,
              dimension.d18,
              dimension.d18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.requestMeetupTitle,
                  style: customButtonandTextStyles.titleTextStyle,
                ),
                SizedBox(height: dimension.d6.h),
                Text(
                  strings.requestMeetupSubtitle,
                  style: customButtonandTextStyles.emailLabelTextStyle,
                ),
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
                            right: i != types.length - 1 ? dimension.d10 : 0,
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: dimension.d18,
                              horizontal: dimension.d8),
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
                                  size: dimension.d28,
                                  color: appTheme.b_Primary),
                              SizedBox(height: dimension.d8.h),
                              Text(types[i]['label'] as String,
                                  style: TextStyle(fontSize: dimension.d14)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: dimension.d18.h),
                Text(strings.addressLabel,
                    style: customButtonandTextStyles.dobLabelTextStyle),
                SizedBox(height: dimension.d8.h),
                CustomTextFormField(
                  controller: addressController,
                  suffix: const Icon(Icons.map_outlined),
                  inputDecoration: InputDecoration(
                    hintText: strings.nearSohoHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(dimension.d12)),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: dimension.d12, vertical: dimension.d12),
                  ),
                ),
                SizedBox(height: dimension.d14.h),
                Text(strings.dateAndTimeLabel,
                    style: customButtonandTextStyles.dobLabelTextStyle),
                SizedBox(height: dimension.d14.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: pickDate,
                        child: AbsorbPointer(
                          child: CustomTextFormField(
                            suffix: const Icon(Icons.calendar_today),
                            controller: dateController,
                            inputDecoration: InputDecoration(
                              labelText: strings.dateLabel,
                              hintText: strings.dateHintExample,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(dimension.d12)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: dimension.d12,
                                  vertical: dimension.d12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: dimension.d10),
                    Expanded(
                      child: GestureDetector(
                        onTap: pickTime,
                        child: AbsorbPointer(
                          child: CustomTextFormField(
                            controller: timeController,
                            inputDecoration: InputDecoration(
                              labelText: strings.timeLabelShort,
                              hintText: strings.timeHintExample,
                              suffixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(dimension.d12)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: dimension.d12,
                                  vertical: dimension.d12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: dimension.d8.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              dimension.d18, dimension.d8, dimension.d18, dimension.d12),
          child: CustomElevatedButton(
            onPressed: canSend
                ? () {
                    FocusScope.of(context).unfocus();
                    _clearAllFields();
                    Navigator.of(context).pop(true);
                  }
                : null,
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: appTheme.b_Primary,
              disabledBackgroundColor: appTheme.b_200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dimension.d28),
              ),
            ),
            text: strings.sendRequestBtn,
            buttonTextStyle: TextStyle(
              color: canSend ? appTheme.coreWhite : appTheme.neutral_400,
            ),
          ),
        ),
      ),
    );
  }
}
