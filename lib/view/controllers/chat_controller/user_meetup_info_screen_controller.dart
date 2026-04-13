import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';

class ChatScreensUserMeetupInfoScreenController extends GetxController {
  final Strings _strings = const Strings();

  Meetup? meetup;
  bool isConfirmed = true;
  String meetupStatus = '';

  void init(Meetup initialMeetup) {
    meetup = initialMeetup;
    meetupStatus = initialMeetup.status;
    isConfirmed =
        meetupStatus.toLowerCase() != _strings.cancelledLabel.toLowerCase();
    update();
  }

  void cancelMeetup() {
    isConfirmed = false;
    meetupStatus = _strings.cancelledLabel;
    update();
  }
}
