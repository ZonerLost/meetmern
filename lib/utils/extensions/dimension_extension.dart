import 'package:flutter/material.dart';
import 'package:meetmern/utils/dimension_resource/dimension_resource.dart';

// Extension on MediaQueryData
extension DimensionExtension on MediaQueryData {
  DimensionResource get dimension => DimensionResource();
}
