import 'package:flutter/material.dart';

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
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );
  }
}

