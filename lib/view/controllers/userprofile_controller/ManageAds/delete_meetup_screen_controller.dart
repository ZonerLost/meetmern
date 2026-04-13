import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';

class DeleteMeetupController extends GetxController {
  final Strings _strings = const Strings();

  Meetup? meetup;

  void init(Meetup initialMeetup) {
    meetup = initialMeetup;
    update();
  }

  String formatMeetupTime(DateTime dt) {
    final hour = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? _strings.pmText : _strings.amText;
    return '${dt.day}/${dt.month}/${dt.year} ${_strings.dotSeparator} $hour:$minute $period';
  }
}
