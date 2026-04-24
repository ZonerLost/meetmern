import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetmern/data/models/feedback_model.dart';
import 'package:meetmern/data/service/feedback_service.dart';
import 'package:meetmern/main.dart';

class FeedbackAttachment {
  final Uint8List bytes;
  final String? name;

  const FeedbackAttachment({required this.bytes, this.name});
}

class FeedbackSupportController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode descriptionFocusNode = FocusNode();

  final List<String> types = ['Bug', 'Account', 'Feature request', 'Other'];
  final List<String> urgencies = ['Low', 'Medium', 'High'];

  final ImagePicker picker = ImagePicker();

  String? type;
  String? urgency;
  List<FeedbackAttachment> attachments = [];

  bool isLoading = false;
  String? errorMessage;

  bool get canSubmit =>
      titleController.text.trim().isNotEmpty &&
      descriptionController.text.trim().isNotEmpty &&
      (type != null && type!.trim().isNotEmpty) &&
      (urgency != null && urgency!.trim().isNotEmpty);

  @override
  void onInit() {
    super.onInit();
    titleController.addListener(_onFieldChanged);
    descriptionController.addListener(_onFieldChanged);
    descriptionFocusNode.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => update();

  void setType(String? value) {
    type = value;
    update();
  }

  void setUrgency(String? value) {
    urgency = value;
    update();
  }

  Future<void> pickImages() async {
    final List<XFile> picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    final converted = await Future.wait(
      picked.map(
          (x) async => FeedbackAttachment(bytes: await x.readAsBytes(), name: x.name)),
    );
    attachments.addAll(converted);
    update();
  }

  Future<void> takePhoto() async {
    final XFile? photo =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo == null) return;
    attachments
        .add(FeedbackAttachment(bytes: await photo.readAsBytes(), name: photo.name));
    update();
  }

  void removeAttachment(int index) {
    if (index < 0 || index >= attachments.length) return;
    attachments.removeAt(index);
    update();
  }

  Future<void> submit() async {
    if (!canSubmit) return;

    isLoading = true;
    errorMessage = null;
    update();

    try {
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';

      // Upload attachments to storage bucket
      final List<String> urls = [];
      for (final attachment in attachments) {
        final url = await FeedbackService.uploadAttachment(
          userId: userId,
          bytes: attachment.bytes,
          fileName: attachment.name ?? 'attachment',
        );
        if (url != null) urls.add(url);
      }

      final feedback = FeedbackModel(
        userId: userId,
        title: titleController.text.trim(),
        type: type!,
        urgency: urgency!,
        description: descriptionController.text.trim(),
        attachmentUrls: urls,
      );

      await FeedbackService.submitFeedback(feedback);
      clearForm();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    type = null;
    urgency = null;
    attachments = [];
    errorMessage = null;
    update();
  }

  @override
  void onClose() {
    titleController.removeListener(_onFieldChanged);
    descriptionController.removeListener(_onFieldChanged);
    descriptionFocusNode.removeListener(_onFieldChanged);
    titleController.dispose();
    descriptionController.dispose();
    descriptionFocusNode.dispose();
    super.onClose();
  }
}
