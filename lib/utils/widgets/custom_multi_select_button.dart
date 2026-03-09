// import 'package:flutter/material.dart';
// import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

// class CustomMultiSelectButton extends StatelessWidget {
//   final String hint;
//   final List<String> items;
//   final List<String> selectedValues;
//   final ValueChanged<List<String>> onSelectionChanged;
//   final InputDecoration? decoration;
//   final double? width;
//   final double? height;
//   final EdgeInsetsGeometry? contentPadding;
//   final double chipAreaHeight;
//   const CustomMultiSelectButton({
//     super.key,
//     required this.hint,
//     required this.items,
//     required this.selectedValues,
//     required this.onSelectionChanged,
//     this.decoration,
//     this.width,
//     this.height,
//     this.contentPadding,
//     this.chipAreaHeight = 56,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final InputDecoration baseDecoration = decoration ??
//         InputDecoration(
//           contentPadding:
//               contentPadding ?? EdgeInsets.symmetric(horizontal: dimension.d20),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(dimension.d30),
//           ),
//         );
//     final InputDecoration effectiveDecoration =
//         baseDecoration.copyWith(hintText: hint);
//     Widget field = GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () async {
//         final temp = Set<String>.from(selectedValues);

//         final result = await showModalBottomSheet<List<String>>(
//           context: context,
//           isScrollControlled: true,
//           builder: (ctx) {
//             return StatefulBuilder(
//               builder: (ctx2, setStateSB) {
//                 return SafeArea(
//                   child: Padding(
//                     padding: EdgeInsets.only(
//                         bottom: MediaQuery.of(ctx).viewInsets.bottom),
//                     child: SizedBox(
//                       height: MediaQuery.of(ctx).size.height * dimension.d0_6,
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.all(dimension.d12),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Select",
//                                   style: Theme.of(ctx).textTheme.bodyLarge,
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.pop(ctx, temp.toList());
//                                   },
//                                   child: const Text("Done"),
//                                 )
//                               ],
//                             ),
//                           ),
//                           const Divider(height: 1),

//                           /// OPTIONS LIST
//                           Expanded(
//                             child: ListView.builder(
//                               itemCount: items.length,
//                               itemBuilder: (c, i) {
//                                 final it = items[i];
//                                 final checked = temp.contains(it);

//                                 return CheckboxListTile(
//                                   title: Text(it),
//                                   value: checked,
//                                   onChanged: (v) {
//                                     setStateSB(() {
//                                       if (v == true) {
//                                         temp.add(it);
//                                       } else {
//                                         temp.remove(it);
//                                       }
//                                     });
//                                   },
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );

//         if (result != null) {
//           onSelectionChanged(result);
//         }
//       },
//       child: InputDecorator(
//         decoration: effectiveDecoration,
//         isEmpty: true,
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(child: SizedBox()),
//             SizedBox(width: 8),
//             Icon(Icons.arrow_drop_down),
//           ],
//         ),
//       ),
//     );

//     if (height != null) {
//       field = ConstrainedBox(
//         constraints: BoxConstraints(
//           minHeight: height!,
//           maxHeight: height!,
//         ),
//         child: field,
//       );
//     }
//     final chipsArea = SizedBox(
//       height: chipAreaHeight,
//       child: selectedValues.isEmpty
//           ? const SizedBox()
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.only(top: dimension.d8),
//                 child: Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: selectedValues.map((val) {
//                     return Container(
//                       width: 88,
//                       height: 37,
//                       decoration: BoxDecoration(
//                         color: appTheme.b_100,
//                         borderRadius: BorderRadius.circular(116),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               final newList = List<String>.from(selectedValues)
//                                 ..remove(val);
//                               onSelectionChanged(newList);
//                             },
//                             child: const Icon(
//                               Icons.close,
//                               size: 14,
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               val,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 color: appTheme.b_600,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//     );

//     return SizedBox(
//       width: width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const DefaultTextStyle(
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//             child: SizedBox(height: 8),
//           ),
//           const SizedBox(height: 8),
//           field,
//           const SizedBox(height: 8),
//           chipsArea,
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class CustomMultiSelectButton extends StatelessWidget {
  final String hint;
  final List<String> items;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onSelectionChanged;
  final InputDecoration? decoration;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;

  const CustomMultiSelectButton({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.decoration,
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
        baseDecoration.copyWith(hintText: hint);
    Widget field = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final temp = Set<String>.from(selectedValues);

        final result = await showModalBottomSheet<List<String>>(
          context: context,
          isScrollControlled: true,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (ctx2, setStateSB) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(ctx).size.height * dimension.d0_6,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(dimension.d12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Select",
                                  style: Theme.of(ctx).textTheme.bodyLarge,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx, temp.toList());
                                  },
                                  child: const Text("Done"),
                                )
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (c, i) {
                                final it = items[i];
                                final checked = temp.contains(it);

                                return CheckboxListTile(
                                  title: Text(it),
                                  value: checked,
                                  onChanged: (v) {
                                    setStateSB(() {
                                      if (v == true) {
                                        temp.add(it);
                                      } else {
                                        temp.remove(it);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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
        isEmpty: true,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: SizedBox()),
            SizedBox(width: 8),
            Icon(Icons.arrow_drop_down),
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

    /// CHIPS AREA (DYNAMIC HEIGHT)
    final chipsArea = selectedValues.isEmpty
        ? const SizedBox()
        : Padding(
            padding: EdgeInsets.only(top: dimension.d8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedValues.map((val) {
                return Container(
                  width: 88,
                  height: 37,
                  decoration: BoxDecoration(
                    color: appTheme.b_100,
                    borderRadius: BorderRadius.circular(116),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final newList = List<String>.from(selectedValues)
                            ..remove(val);
                          onSelectionChanged(newList);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          val,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: appTheme.b_600,
                            fontSize: 12,
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
