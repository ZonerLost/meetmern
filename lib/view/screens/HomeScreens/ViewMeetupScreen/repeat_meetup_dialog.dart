import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/extensions/snackbar_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

Future<void> showRepeatMeetupDialog(
  BuildContext parentContext,
  Meetup meetup, {
  VoidCallback? onRepeat,
}) {
  return showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (ctx) {
      return _RepeatMeetupDialogContent(
        parentContext: parentContext,
        dialogContext: ctx,
        meetup: meetup,
        onRepeat: onRepeat,
      );
    },
  );
}

class _RepeatMeetupDialogContent extends StatefulWidget {
  final BuildContext parentContext;
  final BuildContext dialogContext;
  final Meetup meetup;
  final VoidCallback? onRepeat;

  const _RepeatMeetupDialogContent({
    required this.parentContext,
    required this.dialogContext,
    required this.meetup,
    this.onRepeat,
  });

  @override
  State<_RepeatMeetupDialogContent> createState() =>
      _RepeatMeetupDialogContentState();
}

class _RepeatMeetupDialogContentState
    extends State<_RepeatMeetupDialogContent> {
  int selectedTypeIndex = -1;
  late TextEditingController addressController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  final dimension = DimensionResource();
  final strings = const Strings();

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(text: widget.meetup.location);
    dateController = TextEditingController();
    timeController = TextEditingController();

    // If you want the dialog to react to typing, add listeners (here optional)
    addressController.addListener(() => setState(() {}));
    dateController.addListener(() => setState(() {}));
    timeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    addressController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  String formatDate(DateTime d) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${monthNames[d.month - 1]} ${d.year}';
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) dateController.text = formatDate(picked);
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

  void _toggleType(int i) {
    setState(() {
      selectedTypeIndex = selectedTypeIndex == i ? -1 : i;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final List<Map<String, dynamic>> types = [
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
    final maxHeight = MediaQuery.of(ctx).size.height * 0.65;

    return CustomModalDialog(
      topLeftIcon: null,
      showCloseButton: false,
      title: null,
      subtitle: null,
      backgroundColor: appTheme.coreWhite,
      primaryLabel: strings.yesRepeatLabel,
      onPrimary: () {
        Navigator.of(widget.dialogContext).pop();
        if (widget.onRepeat != null) widget.onRepeat!();
        widget.parentContext.showCustomSnackBar(strings.repeatRequestSent);
      },
      secondaryLabel: strings.cancelLabel,
      onSecondary: () => Navigator.of(widget.dialogContext).pop(),
      content: StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: maxHeight,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                right: dimension.d8,
                left: dimension.d0,
                top: dimension.d0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: dimension.d40,
                        height: dimension.d40,
                        decoration: BoxDecoration(
                          color: appTheme.b_50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(Icons.repeat, color: appTheme.b_Primary),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(widget.dialogContext).pop(),
                        borderRadius: BorderRadius.circular(dimension.d20),
                        child: SizedBox(
                          width: dimension.d36,
                          height: dimension.d36,
                          child: Icon(Icons.close,
                              size: 20, color: appTheme.neutral_600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: dimension.d14.h),
                  Text(
                    strings.repeatThisMeetup,
                    style:
                        customButtonandTextStyles.emailLabelTextStyle.copyWith(
                      color: appTheme.neutral_800,
                    ),
                  ),
                  SizedBox(height: dimension.d6.h),
                  Text(
                    strings.repeatDialogConfirmPrefix,
                    style: customButtonandTextStyles.locationTextStyle.copyWith(
                      color: appTheme.neutral_700,
                    ),
                  ),
                  SizedBox(height: dimension.d16.h),
                  Text(strings.typesLabel,
                      style: customButtonandTextStyles.dobLabelTextStyle),
                  SizedBox(height: dimension.d10.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(types.length, (i) {
                        final isSelected = selectedTypeIndex == i;
                        return GestureDetector(
                          onTap: () => _toggleType(i),
                          child: Container(
                            width: dimension.d92,
                            margin: EdgeInsets.only(right: dimension.d8),
                            padding: EdgeInsets.symmetric(
                                vertical: dimension.d12,
                                horizontal: dimension.d6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isSelected
                                      ? appTheme.b_Primary
                                      : appTheme.borderColor),
                              color: isSelected
                                  ? appTheme.b_100
                                  : appTheme.coreWhite,
                            ),
                            child: Column(
                              children: [
                                Icon(types[i]['icon'],
                                    color: appTheme.b_Primary),
                                SizedBox(height: dimension.d6.h),
                                Text(types[i]['label'],
                                    style: TextStyle(fontSize: dimension.d13)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: dimension.d16.h),
                  Text(strings.addressLabel,
                      style: customButtonandTextStyles.dobLabelTextStyle),
                  SizedBox(height: dimension.d8.h),
                  CustomTextFormField(
                    controller: addressController,
                    suffix: InkWell(
                      onTap: () {},
                      child: const Icon(Icons.map_outlined),
                    ),
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
                      style: const TextStyle(fontWeight: FontWeight.w600)),
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
                  SizedBox(height: dimension.d12.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
