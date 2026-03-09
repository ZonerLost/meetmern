// import 'package:flutter/material.dart';

// class CustomDropdown extends StatelessWidget {
//   final Widget label;
//   final String hint;
//   final List<String> items;
//   final String? value;
//   final ValueChanged<String?> onChanged;
//   final FormFieldValidator<String>? validator;

//   final InputDecoration? decoration;
//   final double? width;
//   final double? height;

//   const CustomDropdown({
//     super.key,
//     required this.label,
//     required this.hint,
//     required this.items,
//     required this.value,
//     required this.onChanged,
//     this.validator,
//     this.decoration,
//     this.width,
//     this.height,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           DefaultTextStyle(
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//             child: label,
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: height,
//             child: DropdownButtonFormField<String>(
//               value: value,
//               hint: Text(hint),
//               items: items
//                   .map((item) =>
//                       DropdownMenuItem(value: item, child: Text(item)))
//                   .toList(),
//               onChanged: onChanged,
//               validator: validator,
//               decoration: decoration ??
//                   const InputDecoration(
//                     border: OutlineInputBorder(),
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final Widget label;
  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  /// Visual / layout
  final InputDecoration? decoration;
  final double? width; // overall widget width
  final double? height; // fixed field height (optional)
  final double? itemHeight; // height of each menu item (optional)
  final double? menuMaxHeight; // max height of dropdown menu (optional)
  final bool isExpanded; // whether the menu should match the width of the field
  final TextStyle? itemTextStyle; // optional style for the menu items
  final EdgeInsetsGeometry?
      contentPadding; // override content padding inside decoration

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.decoration,
    this.width,
    this.height,
    this.itemHeight,
    this.menuMaxHeight,
    this.isExpanded = true,
    this.itemTextStyle,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    // default decoration if none provided
    final InputDecoration baseDecoration = decoration ??
        InputDecoration(
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        );

    // ensure hintText comes from `hint` param unless explicitly set by caller
    final InputDecoration effectiveDecoration =
        baseDecoration.copyWith(hintText: hint);

    // Build DropdownMenuItem children — wrap in SizedBox to enforce item height if itemHeight provided
    final menuItems = items.map((item) {
      final child = Align(
        alignment: Alignment.centerLeft,
        child: Text(item, style: itemTextStyle),
      );

      if (itemHeight != null) {
        return DropdownMenuItem<String>(
          value: item,
          child: SizedBox(height: itemHeight, child: child),
        );
      } else {
        return DropdownMenuItem<String>(
          value: item,
          child: child,
        );
      }
    }).toList();

    Widget dropdown = DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      items: menuItems,
      onChanged: onChanged,
      validator: validator,
      decoration: effectiveDecoration,
      isExpanded: isExpanded,
      itemHeight: itemHeight, // null allowed
      menuMaxHeight: menuMaxHeight,
    );

    // apply a fixed height only when provided
    if (height != null) {
      dropdown = ConstrainedBox(
        constraints: BoxConstraints(minHeight: height!, maxHeight: height!),
        child: dropdown,
      );
    }

    return SizedBox(
      width: width, // if null, parent controls width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            // keep the label style customizable by parent; fallback to a reasonable default
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            child: label,
          ),
          const SizedBox(height: 8),
          dropdown,
        ],
      ),
    );
  }
}
