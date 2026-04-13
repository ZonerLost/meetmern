import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';

class CreateMeetupDraftData {
  final int? typeIndex;
  final String address;
  final DateTime? date;
  final TimeOfDay? time;
  final bool repeat;
  final String repeatRule;

  const CreateMeetupDraftData({
    required this.typeIndex,
    required this.address,
    required this.date,
    required this.time,
    required this.repeat,
    required this.repeatRule,
  });
}

class CreateMeetupController extends GetxController {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  int selectedTypeIndex = -1;
  bool repeat = false;
  String repeatRule = 'Every Monday';

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool get isStepValid =>
      selectedTypeIndex != -1 &&
      addressController.text.trim().isNotEmpty &&
      dateController.text.trim().isNotEmpty &&
      timeController.text.trim().isNotEmpty;

  String formatDate(DateTime d) =>
      '${d.day} ${Strings.monthNames[d.month - 1]} ${d.year}';

  String formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void onTapType(int index) {
    selectedTypeIndex = selectedTypeIndex == index ? -1 : index;
    update();
  }

  void onAddressChanged(String _) => update();

  void setDate(DateTime? date) {
    selectedDate = date;
    if (date != null) dateController.text = formatDate(date);
    update();
  }

  void setTime(TimeOfDay? time) {
    selectedTime = time;
    if (time != null) timeController.text = formatTime(time);
    update();
  }

  void setRepeat(bool value) {
    repeat = value;
    update();
  }

  void setRepeatRule(String value) {
    repeatRule = value;
    update();
  }

  CreateMeetupDraftData buildDraft() => CreateMeetupDraftData(
        typeIndex: selectedTypeIndex == -1 ? null : selectedTypeIndex,
        address: addressController.text.trim(),
        date: selectedDate,
        time: selectedTime,
        repeat: repeat,
        repeatRule: repeat ? repeatRule : 'Does not repeat',
      );

  void clearAll() {
    selectedTypeIndex = -1;
    repeat = false;
    repeatRule = 'Every Monday';
    selectedDate = null;
    selectedTime = null;
    addressController.clear();
    dateController.clear();
    timeController.clear();
    update();
  }

  @override
  void onClose() {
    addressController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.onClose();
  }
}
