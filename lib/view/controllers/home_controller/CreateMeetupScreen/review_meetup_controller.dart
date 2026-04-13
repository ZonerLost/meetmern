import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';

class ReviewMeetupController extends GetxController {
  final Strings _strings = const Strings();

  String typeLabelFromIndex(int? typeIndex) {
    switch (typeIndex) {
      case 0: return _strings.typeCoffee;
      case 1: return _strings.typeDrink;
      case 2: return _strings.typeMeal;
      default: return _strings.typeCoffee;
    }
  }

  IconData typeIconFromIndex(int? typeIndex) {
    switch (typeIndex) {
      case 0: return Icons.coffee;
      case 1: return Icons.local_bar;
      case 2: return Icons.set_meal;
      default: return Icons.coffee;
    }
  }

  String defaultAssetIconFromIndex(int? typeIndex) {
    switch (typeIndex) {
      case 0: return 'assets/icons/coffe_icon.png';
      case 1: return 'assets/icons/drinks_icon.png';
      case 2: return 'assets/icons/meals_icon.png';
      default: return 'assets/icons/coffe_icon.png';
    }
  }

  Meetup buildMeetupFromDraft({
    required int? typeIndex,
    required String address,
    required DateTime dateTime,
  }) {
    final typeLabel = typeLabelFromIndex(typeIndex);
    return Meetup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${_strings.meetMeForPrefix}$typeLabel',
      hostName: 'You',
      time: dateTime,
      location: address.isNotEmpty ? address : _strings.notProvidedLabel,
      distanceKm: 0,
      type: typeLabel,
      status: 'Open',
      image: _strings.img9,
      description: '',
      icon: defaultAssetIconFromIndex(typeIndex),
      languages: const <String>[],
      interests: const <String>[],
      isFavorite: false,
      joinRequested: false,
    );
  }
}
