import 'package:flutter/material.dart';

enum MeetupType { coffee, drink, meal }

class MeetupDraft {
  MeetupType? type;
  String address;
  DateTime? date;
  TimeOfDay? time;
  bool repeat;
  String repeatRule;
  double? latitude;
  double? longitude;

  /// Set when this draft edits an existing meetup rather than creating a
  /// new one; carries the id so the review screen can update in place.
  final String? existingMeetupId;

  MeetupDraft({
    this.type,
    this.address = '',
    this.date,
    this.time,
    this.repeat = false,
    this.repeatRule = '',
    this.latitude,
    this.longitude,
    this.existingMeetupId,
  });

  DateTime? get dateTime {
    if (date == null || time == null) return null;
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );
  }
}

