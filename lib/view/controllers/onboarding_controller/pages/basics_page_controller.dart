import 'package:get/get.dart';

class BasicsPageController extends GetxController {
  bool isStepValid({
    required String dob,
    required String? gender,
    required String? ethnicity,
    required String? orientation,
  }) =>
      dob.trim().isNotEmpty && gender != null && ethnicity != null && orientation != null;
}
