import 'package:meetmern/core/constants/dimension_resource.dart';

class AppDimensions {
  AppDimensions._();

  static final DimensionResource _d = DimensionResource();

  static double get xs => _d.d4;
  static double get sm => _d.d8;
  static double get md => _d.d12;
  static double get lg => _d.d16;
  static double get xl => _d.d20;
  static double get xxl => _d.d24;
  static double get radiusSm => _d.d8;
  static double get radiusMd => _d.d12;
  static double get radiusLg => _d.d16;
}
