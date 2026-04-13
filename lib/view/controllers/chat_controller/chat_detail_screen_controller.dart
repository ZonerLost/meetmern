import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreensChatDetailScreenController extends GetxController {
  final TextEditingController reportDescriptionController =
      TextEditingController();

  String? selectedReportReason;

  bool get canSubmitReport {
    return (selectedReportReason != null && selectedReportReason!.isNotEmpty) &&
        reportDescriptionController.text.trim().isNotEmpty;
  }

  void setReportReason(String? reason) {
    selectedReportReason = reason;
    update();
  }

  void onDescriptionChanged(String _) {
    update();
  }

  void clearReportDraft() {
    selectedReportReason = null;
    reportDescriptionController.clear();
    update();
  }

  @override
  void onClose() {
    reportDescriptionController.dispose();
    super.onClose();
  }
}
