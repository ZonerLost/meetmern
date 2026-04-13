import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class UserProfileScreensFavouritesFavouritesController extends GetxController {
  final MeetupStore _store = MeetupStore.instance;

  bool isLoading = true;

  List<Meetup> get favourites => _store.favourites;

  Future<void> loadFavourites() async {
    isLoading = true;
    update();
    try {
      await _store.load();
    } finally {
      isLoading = false;
      update();
    }
  }

  void setFavorite(String id, bool value) {
    _store.setFavorite(id, value);
    update();
  }
}
