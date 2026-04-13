import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';

class RequestMeetupController extends GetxController {
  int selectedTypeIndex = -1;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  String formatDate(DateTime d) =>
      '${d.day} ${Strings.monthNames[d.month - 1]} ${d.year}';

  String formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool get canSend =>
      selectedTypeIndex != -1 &&
      addressController.text.trim().isNotEmpty &&
      dateController.text.trim().isNotEmpty &&
      timeController.text.trim().isNotEmpty;

  void onTapType(int index) {
    selectedTypeIndex = selectedTypeIndex == index ? -1 : index;
    update();
  }

  void setDate(DateTime? date) {
    if (date == null) return;
    dateController.text = formatDate(date);
    update();
  }

  void setTime(TimeOfDay? time) {
    if (time == null) return;
    timeController.text = formatTime(time);
    update();
  }

  void onControllerChanged() => update();

  void clearAllFields() {
    selectedTypeIndex = -1;
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
