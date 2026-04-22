import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/meetup_service.dart';

class ChatDetailController extends GetxController {
  final TextEditingController reportDescriptionController =
      TextEditingController();

  String? selectedReportReason;
  bool isLoading = false;

  Chat? _chat;
  Meetup? _meetup;

  bool get canSubmitReport =>
      (selectedReportReason != null && selectedReportReason!.isNotEmpty) &&
      reportDescriptionController.text.trim().isNotEmpty;

  Meetup get resolvedMeetup {
    final loaded = _meetup;
    if (loaded != null) return loaded;
    final source = _chat;
    if (source != null) return source.toMeetup();

    return Meetup(
      id: 'chat_fallback',
      title: 'Meetup',
      hostName: 'User',
      time: DateTime.now(),
      location: 'Not provided',
      distanceKm: 0,
      type: 'meetup',
      status: 'open',
      image: 'assets/images/img9.jpg',
      description: '',
      icon: 'assets/icons/coffe_icon.png',
      languages: const <String>[],
      interests: const <String>[],
    );
  }

  Future<void> init(Chat chat) async {
    _chat = chat;
    _meetup = chat.toMeetup();

    final meetupId = chat.meetupId;
    if (meetupId == null || meetupId.trim().isEmpty) {
      update();
      return;
    }

    isLoading = true;
    update();

    try {
      final row = await MeetupService.fetchMeetupById(meetupId);
      if (row != null) {
        _meetup = Meetup.fromSupabase(row);
      }
    } catch (_) {
      // Keep fallback data from chat.
    }

    isLoading = false;
    update();
  }

  void setReportReason(String? reason) {
    selectedReportReason = reason;
    update();
  }

  void onDescriptionChanged(String _) => update();

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
