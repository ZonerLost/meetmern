import 'package:get/get.dart';

class UserProfileScreensNotificationScreensNotificationController
    extends GetxController {
  bool newRequests = true;
  bool accepted = true;
  bool messages = true;
  bool favoritePosts = false;
  bool updates = true;

  Map<String, bool> toMap() {
    return <String, bool>{
      'newRequests': newRequests,
      'accepted': accepted,
      'messages': messages,
      'favoritePosts': favoritePosts,
      'updates': updates,
    };
  }

  void setNewRequests(bool value) {
    newRequests = value;
    update();
  }

  void setAccepted(bool value) {
    accepted = value;
    update();
  }

  void setMessages(bool value) {
    messages = value;
    update();
  }

  void setFavoritePosts(bool value) {
    favoritePosts = value;
    update();
  }

  void setUpdates(bool value) {
    updates = value;
    update();
  }
}
