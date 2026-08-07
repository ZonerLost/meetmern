import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/data/service/meetup_store.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ManageAds/ads_screen_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ViewProfileScreens/view_profil_controller.dart';

class DeleteMeetupController extends GetxController {
  final Strings _strings = const Strings();

  Meetup? meetup;
  bool isDeleting = false;

  void init(Meetup initialMeetup) {
    meetup = initialMeetup;
    // Note: no update() here. This runs from initState(), which is part of
    // the framework's build/mount phase — calling update() synchronously
    // at that point can hit a GetBuilder<DeleteMeetupController> that is
    // still part of the widget tree while it is building (e.g. mid route
    // transition), triggering "setState() or markNeedsBuild() called
    // during build". The field is already assigned before this screen's
    // own first build, so no rebuild trigger is needed here.
  }

  String formatMeetupTime(DateTime dt) {
    final hour = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? _strings.pmText : _strings.amText;
    return '${dt.day}/${dt.month}/${dt.year} ${_strings.dotSeparator} $hour:$minute $period';
  }

  /// Deletes the meetup from Supabase. Returns true on success.
  Future<bool> deleteMeetup() async {
    final id = meetup?.id;
    if (id == null) return false;
    isDeleting = true;
    update();

    bool deleted = false;
    try {
      await MeetupService.deleteMeetup(id);
      deleted = true;
    } catch (_) {
      deleted = false;
    }

    if (deleted) {
      // Best-effort: purge from every list-holding controller/cache right
      // away so the deletion shows up immediately wherever this meetup is
      // listed, instead of waiting for a manual refresh. The server-side
      // delete already succeeded above, so any hiccup syncing these local
      // lists must never flip the reported outcome to "failed" — that
      // would surface a false "Failed to delete" error for a delete that
      // actually went through.
      try {
        MeetupStore.instance.removeById(id);
        if (Get.isRegistered<AdsScreenController>()) {
          Get.find<AdsScreenController>().removeById(id);
        }
        if (Get.isRegistered<ViewProfileController>()) {
          Get.find<ViewProfileController>().removeMeetupById(id);
        }
      } catch (_) {
        // Ignore — those lists will simply catch up on their next load.
      }
    }

    isDeleting = false;
    update();
    return deleted;
  }
}
