import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/theme/theme.dart';

final dimension = DimensionResource();
final appTheme = ThemeHelper(appThemeName: "lightCode").themeColor;

class OnboardingTopbar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onBack;

  const OnboardingTopbar({
    super.key,
    required this.current,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: dimension.d12.w, vertical: dimension.d8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: appTheme.neutral_800, size: dimension.d20.sp),
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(total, (i) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: dimension.d6.w),
                    width: i == current ? dimension.d10.w : dimension.d6.w,
                    height: dimension.d6.h,
                    decoration: BoxDecoration(
                      color: i == current
                          ? appTheme.b_Primary
                          : appTheme.neutral_300,
                      borderRadius: BorderRadius.circular(dimension.d6.r),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(width: dimension.d48.w),
        ],
      ),
    );
  }
}
