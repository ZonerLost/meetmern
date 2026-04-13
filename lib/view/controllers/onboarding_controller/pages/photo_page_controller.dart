import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingScreensPagesPhotoPageController extends GetxController {
  final ImagePicker picker = ImagePicker();

  File? pickedImage;

  bool get isStepValid => true;

  Future<void> pickImage() async {
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;

    pickedImage = File(file.path);
    update();
  }

  void removeImage() {
    pickedImage = null;
    update();
  }
}
