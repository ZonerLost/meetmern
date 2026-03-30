import 'package:flutter/material.dart';
import 'package:meetmern/utils/strings/strings.dart';

extension DateTimeFormatting on DateTime {
  String toDateTimeRangeString({int durationMinutes = 60}) {
    final start = this;
    final end = start.add(Duration(minutes: durationMinutes));
    String formatTime(DateTime d) {
      final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final minute = d.minute.toString().padLeft(2, '0');
      final period = d.hour >= 12 ? 'PM' : 'AM';
      return '$hour12:$minute $period';
    }

    final month = Strings.monthNames[start.month - 1];
    final startTime = formatTime(start);
    final endTime = formatTime(end);

    return '$month ${start.day}, ${start.year} · $startTime - $endTime';
  }

  String toCompactIsoString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$y-$m-$d' 'T' '$hh:$mm';
  }
}

extension DatePickerExtensions on BuildContext {
  Future<DateTime?> pickDobIntoController(
    TextEditingController controller, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final picked = await showDatePicker(
      context: this,
      initialDate: initialDate ?? DateTime(1995, 1, 1),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
    );

    if (picked != null) {
      controller.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
    return picked;
  }
}

extension PickerExtensions on TextEditingController {
  Future<DateTime?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String Function(DateTime)? format,
    void Function(DateTime)? onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365)),
      lastDate: lastDate ?? now.add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      text = format != null ? format(picked) : picked.toDateTimeRangeString();
      onPicked?.call(picked);
    }
    return picked;
  }

  Future<TimeOfDay?> pickTime({
    required BuildContext context,
    TimeOfDay? initialTime,
    String Function(TimeOfDay)? formatTime,
    void Function(TimeOfDay)? onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      String defaultFormatter(TimeOfDay t) {
        final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
        final minute = t.minute.toString().padLeft(2, '0');
        final period = t.period == DayPeriod.am ? 'AM' : 'PM';
        return '$hour:$minute $period';
      }

      text = (formatTime ?? defaultFormatter)(picked);
      onPicked?.call(picked);
    }
    return picked;
  }
}
