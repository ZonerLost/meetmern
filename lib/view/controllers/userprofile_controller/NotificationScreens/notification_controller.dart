import 'package:get/get.dart';

class NotificationController extends GetxController {
  bool newRequests = true;
  bool accepted = true;
  bool messages = true;
  bool favoritePosts = false;
  bool updates = true;

  void setNewRequests(bool value) { newRequests = value; update(); }
  void setAccepted(bool value) { accepted = value; update(); }
  void setMessages(bool value) { messages = value; update(); }
  void setFavoritePosts(bool value) { favoritePosts = value; update(); }
  void setUpdates(bool value) { updates = value; update(); }
}
