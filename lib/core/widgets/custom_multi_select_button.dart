import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class CustomMultiSelectButton extends StatelessWidget {
  final String hint;
  final List<String> items;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onSelectionChanged;
  final InputDecoration? decoration;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;
  final Color? menuColor;
  const CustomMultiSelectButton({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.decoration,
    this.menuColor,
    this.width,
    this.height,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final InputDecoration baseDecoration = decoration ??
        InputDecoration(
          contentPadding:
              contentPadding ?? EdgeInsets.symmetric(horizontal: dimension.d20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(dimension.d30),
          ),
        );

    final InputDecoration effectiveDecoration =
        baseDecoration.copyWith(hintText: selectedValues.isEmpty ? hint : null);
    Widget field = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final temp = Set<String>.from(selectedValues);

        final result = await showModalBottomSheet<List<String>>(
          context: context,
          backgroundColor: menuColor ?? appTheme.coreWhite,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(dimension.d20.r))),
          builder: (ctx) {
            return StatefulBuilder(
              builder: (ctx2, setStateSB) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    left: dimension.d16.w,
                    right: dimension.d16.w,
                    top: dimension.d16.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: dimension.d40.w,
                          height: dimension.d4.h,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius:
                                  BorderRadius.circular(dimension.d4.r))),
                      SizedBox(height: dimension.d12.h),
                      const Text('Select',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: dimension.d12.h),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: items.map((lang) {
                            final selected = temp.contains(lang);
                            return CheckboxListTile(
                              title: Text(lang),
                              value: selected,
                              onChanged: (v) => setStateSB(() {
                                if (v == true)
                                  temp.add(lang);
                                else
                                  temp.remove(lang);
                              }),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel')),
                          ),
                          SizedBox(width: dimension.d12.w),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: appTheme.b_Primary),
                              onPressed: () {
                                Navigator.pop(ctx, temp.toList());
                              },
                              child: Text(
                                'Done',
                                style: TextStyle(color: appTheme.coreWhite),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: dimension.d12.h),
                    ],
                  ),
                );
              },
            );
          },
        );
        if (result != null) {
          onSelectionChanged(result);
        }
      },
      child: InputDecorator(
        decoration: effectiveDecoration,
        isEmpty: selectedValues.isEmpty,
        child: Row(
          children: [
            Expanded(
              child: selectedValues.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      selectedValues.join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: appTheme.b_600,
                      ),
                    ),
            ),
            SizedBox(width: dimension.d8),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );

    /// FIXED HEIGHT FIELD (OPTIONAL)
    if (height != null) {
      field = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: height!,
          maxHeight: height!,
        ),
        child: field,
      );
    }

    final chipsArea = selectedValues.isEmpty
        ? const SizedBox()
        : Padding(
            padding: EdgeInsets.only(top: dimension.d8),
            child: Wrap(
              spacing: dimension.d8,
              runSpacing: dimension.d8,
              children: selectedValues.map((val) {
                return Container(
                  constraints: BoxConstraints(minWidth: dimension.d56),
                  padding: EdgeInsets.symmetric(horizontal: dimension.d10),
                  height: dimension.d37,
                  decoration: BoxDecoration(
                    color: appTheme.b_100,
                    borderRadius: BorderRadius.circular(dimension.d116),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final newList = List<String>.from(selectedValues)
                            ..remove(val);
                          onSelectionChanged(newList);
                        },
                        child: Icon(
                          Icons.close,
                          size: dimension.d14,
                        ),
                      ),
                      SizedBox(width: dimension.d8.w),
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: width ?? dimension.d120.w),
                        child: Text(
                          val,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: appTheme.b_600,
                            fontSize: dimension.d12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          field,
          chipsArea,
        ],
      ),
    );
  }
}
