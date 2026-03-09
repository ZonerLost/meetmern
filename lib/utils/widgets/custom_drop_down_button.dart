// // import 'package:flutter/material.dart';

// // class CustomDropdownButton extends StatelessWidget {
// //   final Widget label;
// //   final String hint;
// //   final List<String> items;
// //   final String? value;
// //   final ValueChanged<String?> onChanged;
// //   final InputDecoration? decoration;
// //   final double? width;
// //   final double? height;
// //   final double? itemHeight;
// //   final double? menuMaxHeight;
// //   final double? menuMaxWidth;
// //   final TextStyle? itemTextStyle;
// //   final EdgeInsetsGeometry? contentPadding;

// //   const CustomDropdownButton({
// //     super.key,
// //     required this.label,
// //     required this.hint,
// //     required this.items,
// //     required this.value,
// //     required this.onChanged,
// //     this.decoration,
// //     this.width,
// //     this.height,
// //     this.itemHeight,
// //     this.menuMaxHeight,
// //     this.menuMaxWidth,
// //     this.itemTextStyle,
// //     this.contentPadding,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final InputDecoration baseDecoration = decoration ??
// //         InputDecoration(
// //           contentPadding: contentPadding ??
// //               const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
// //         );

// //     final InputDecoration effectiveDecoration = baseDecoration.copyWith(
// //       hintText: hint,
// //     );

// //     Widget field = Builder(builder: (fieldContext) {
// //       // We need the RenderBox for correct menu position and width
// //       return GestureDetector(
// //         behavior: HitTestBehavior.opaque,
// //         onTap: () async {
// //           final RenderBox renderBox =
// //               fieldContext.findRenderObject() as RenderBox;
// //           final Offset offset = renderBox.localToGlobal(Offset.zero);
// //           final RelativeRect position = RelativeRect.fromLTRB(
// //             offset.dx,
// //             offset.dy + renderBox.size.height,
// //             offset.dx + renderBox.size.width,
// //             offset.dy,
// //           );

// //           final selected = await showMenu<String>(
// //             context: context,
// //             position: position,
// //             items: items.map((it) {
// //               return PopupMenuItem<String>(
// //                 value: it,
// //                 child: SizedBox(
// //                   height: itemHeight,
// //                   child: Align(
// //                     alignment: Alignment.centerLeft,
// //                     child: Text(it, style: itemTextStyle),
// //                   ),
// //                 ),
// //               );
// //             }).toList(),
// //             // Control menu constraints (max width/height)
// //             constraints: BoxConstraints(
// //               maxHeight: menuMaxHeight ?? 300,
// //               maxWidth: menuMaxWidth ?? renderBox.size.width,
// //             ),
// //           );

// //           if (selected != null) onChanged(selected);
// //         },
// //         child: InputDecorator(
// //           decoration: effectiveDecoration,
// //           isEmpty: value == null || value!.isEmpty,
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Expanded(
// //                 child: Text(
// //                   value ?? hint,
// //                   // style: value == null
// //                   //     ? Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.grey)
// //                   //     : Theme.of(context).textTheme.bodyText1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //               const SizedBox(width: 8),
// //               const Icon(Icons.arrow_drop_down, size: 24),
// //             ],
// //           ),
// //         ),
// //       );
// //     });

// //     if (height != null) {
// //       field = ConstrainedBox(
// //         constraints: BoxConstraints(minHeight: height!, maxHeight: height!),
// //         child: field,
// //       );
// //     }

// //     return SizedBox(
// //       width: width,
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           DefaultTextStyle(
// //             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
// //             child: label,
// //           ),
// //           const SizedBox(height: 8),
// //           field,
// //         ],
// //       ),
// //     );
// //   }
// // }

// // lib/utils/widgets/custom_dropdown_button.dart
// import 'dart:math' as math;

// import 'package:flutter/material.dart';

// class CustomDropdownButton extends StatelessWidget {
//   final Widget label;
//   final String hint;
//   final List<String> items;
//   final String? value;
//   final ValueChanged<String?> onChanged;
//   final FormFieldValidator<String>? validator;

//   /// Visual / layout
//   final InputDecoration? decoration;
//   final double? width;
//   final double? height;
//   final double? itemHeight;
//   final double? menuMaxHeight;
//   final double? menuMaxWidth;
//   final bool isExpanded;
//   final bool alignMenuRight; // align menu's right edge with field right edge
//   final TextStyle? itemTextStyle;
//   final EdgeInsetsGeometry? contentPadding;

//   const CustomDropdownButton({
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
//     this.itemHeight,
//     this.menuMaxHeight,
//     this.menuMaxWidth,
//     this.isExpanded = true,
//     this.alignMenuRight = false,
//     this.itemTextStyle,
//     this.contentPadding,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final InputDecoration baseDecoration = decoration ??
//         InputDecoration(
//           contentPadding: contentPadding ??
//               const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
//         );

//     // Show hint only when no value selected
//     final InputDecoration effectiveDecoration = baseDecoration.copyWith(
//         hintText: (value == null || value!.isEmpty) ? hint : null);

//     Widget field = Builder(builder: (fieldContext) {
//       return GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: () async {
//           final RenderBox renderBox =
//               fieldContext.findRenderObject() as RenderBox;
//           final Offset offset = renderBox.localToGlobal(Offset.zero);

//           final screenWidth = MediaQuery.of(context).size.width;
//           final double desiredMenuWidth = menuMaxWidth ?? renderBox.size.width;
//           final double menuWidth = math.min(desiredMenuWidth, screenWidth);

//           double left;
//           if (alignMenuRight) {
//             left = offset.dx + renderBox.size.width - menuWidth;
//             if (left < 0) left = 0;
//           } else {
//             left = offset.dx;
//           }

//           final RelativeRect position = RelativeRect.fromLTRB(
//             left,
//             offset.dy + renderBox.size.height,
//             left + menuWidth,
//             offset.dy,
//           );

//           final selected = await showMenu<String>(
//             context: context,
//             position: position,
//             items: items.map((it) {
//               return PopupMenuItem<String>(
//                 value: it,
//                 child: SizedBox(
//                   height: itemHeight ?? 48,
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                       it,
//                       textAlign: TextAlign.right,
//                       style: itemTextStyle,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//             constraints: BoxConstraints(
//               maxHeight: menuMaxHeight ?? 300,
//               maxWidth: menuWidth,
//             ),
//           );

//           if (selected != null) onChanged(selected);
//         },
//         child: InputDecorator(
//           decoration: effectiveDecoration,
//           isEmpty: value == null || value!.isEmpty,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   value ?? '',
//                   // style: value == null
//                   //     ? Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.grey)
//                   //     : Theme.of(context).textTheme.bodyText1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               const Icon(Icons.arrow_drop_down, size: 24),
//             ],
//           ),
//         ),
//       );
//     });

//     if (height != null) {
//       field = ConstrainedBox(
//         constraints: BoxConstraints(minHeight: height!, maxHeight: height!),
//         child: field,
//       );
//     }

//     return SizedBox(
//       width: width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           DefaultTextStyle(
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             child: label,
//           ),
//           const SizedBox(height: 8),
//           field,
//         ],
//       ),
//     );
//   }
// }

// lib/utils/widgets/custom_dropdown_button.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;
  final double? width;
  final double? height;
  final double? itemHeight;
  final double? menuMaxHeight;
  final double? menuMaxWidth;
  final bool isExpanded;
  final bool alignMenuRight; // align menu's right edge with field right edge
  final TextStyle? itemTextStyle;
  final EdgeInsetsGeometry? contentPadding;

  const CustomDropdownButton({
    super.key,
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
    this.menuMaxWidth,
    this.isExpanded = true,
    this.alignMenuRight = false,
    this.itemTextStyle,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final InputDecoration baseDecoration = decoration ??
        InputDecoration(
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        );

    // Show hint only when no value selected
    final InputDecoration effectiveDecoration = baseDecoration.copyWith(
        hintText: (value == null || value!.isEmpty) ? hint : null);

    Widget field = Builder(builder: (fieldContext) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final RenderBox renderBox =
              fieldContext.findRenderObject() as RenderBox;
          final Offset offset = renderBox.localToGlobal(Offset.zero);

          final screenWidth = MediaQuery.of(context).size.width;
          final double desiredMenuWidth = menuMaxWidth ?? renderBox.size.width;
          final double menuWidth = math.min(desiredMenuWidth, screenWidth);

          double left;
          if (alignMenuRight) {
            left = offset.dx + renderBox.size.width - menuWidth;
            if (left < 0) left = 0;
          } else {
            left = offset.dx;
          }

          final RelativeRect position = RelativeRect.fromLTRB(
            left,
            offset.dy + renderBox.size.height,
            left + menuWidth,
            offset.dy,
          );

          final selected = await showMenu<String>(
            context: context,
            position: position,
            items: items.map((it) {
              return PopupMenuItem<String>(
                value: it,
                child: SizedBox(
                  height: itemHeight ?? 48,
                  child: Align(
                    alignment: Alignment.centerLeft, // LEFT aligned text now
                    child: Text(
                      it,
                      textAlign: TextAlign.left,
                      style: itemTextStyle,
                    ),
                  ),
                ),
              );
            }).toList(),
            constraints: BoxConstraints(
              maxHeight: menuMaxHeight ?? 300,
              maxWidth: menuWidth,
            ),
          );

          if (selected != null) onChanged(selected);
        },
        child: InputDecorator(
          decoration: effectiveDecoration,
          isEmpty: value == null || value!.isEmpty,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value ?? '',
                  style: value == null
                      ? Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey)
                      : Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        ),
      );
    });

    if (height != null) {
      field = ConstrainedBox(
        constraints: BoxConstraints(minHeight: height!, maxHeight: height!),
        child: field,
      );
    }

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DefaultTextStyle(
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            child: SizedBox(height: 8),
          ),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );
  }
}
