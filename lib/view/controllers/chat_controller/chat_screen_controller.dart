import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/service/api_s.dart';

class ChatListController extends GetxController {
  final Strings _strings = const Strings();

  List<Chat> items = <Chat>[];
  bool isLoading = true;
  String? error;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  Future<void> loadChats() async {
    isLoading = true;
    error = null;
    update();
    try {
      items = await MockApi.fetchChats();
    } catch (_) {
      error = _strings.failedToLoadChats;
    } finally {
      isLoading = false;
      update();
    }
  }

  void acceptRequest(Chat item) {
    item.status = RequestStatus.accepted;
    update();
  }

  void rejectRequest(Chat item) {
    item.status = RequestStatus.rejected;
    update();
  }

  void removeConversation(Chat item) {
    items.remove(item);
    update();
  }
}
