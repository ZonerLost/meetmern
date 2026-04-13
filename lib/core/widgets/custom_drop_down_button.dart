import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {
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
  final bool alignMenuRight;
  final TextStyle? itemTextStyle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? menuColor;

  const CustomDropdownButton({
    super.key,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.decoration,
    this.menuColor,
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
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant CustomDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        widget.value != _controller.text &&
        !_focusNode.hasFocus) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final InputDecoration baseDecoration = widget.decoration ??
        InputDecoration(
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        );

    final InputDecoration effectiveDecoration = baseDecoration.copyWith(
      hintText: widget.hint,
      suffixIcon: IconButton(
        icon: const Icon(Icons.arrow_drop_down),
        onPressed: () async {
          final renderBox = context.findRenderObject() as RenderBox;
          final offset = renderBox.localToGlobal(Offset.zero);

          final screenWidth = MediaQuery.of(context).size.width;
          final desiredMenuWidth = widget.menuMaxWidth ?? renderBox.size.width;
          final menuWidth = math.min(desiredMenuWidth, screenWidth);

          double left;
          if (widget.alignMenuRight) {
            left = offset.dx + renderBox.size.width - menuWidth;
            if (left < 0) left = 0;
          } else {
            left = offset.dx;
          }

          final position = RelativeRect.fromLTRB(
            left,
            offset.dy + renderBox.size.height,
            left + menuWidth,
            offset.dy,
          );

          final selected = await showMenu<String>(
            context: context,
            color: widget.menuColor ?? Colors.white,
            position: position,
            items: widget.items.map((it) {
              return PopupMenuItem<String>(
                value: it,
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: SizedBox(
                    height: widget.itemHeight ?? 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          it,
                          textAlign: TextAlign.left,
                          style: widget.itemTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            constraints: BoxConstraints(
              maxHeight: widget.menuMaxHeight ?? 300,
              maxWidth: menuWidth,
            ),
          );

          if (selected != null) {
            _controller.text = selected;
            widget.onChanged(selected);
          }
        },
      ),
    );

    Widget field = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: effectiveDecoration,
      textAlignVertical: TextAlignVertical.center,
    );

    if (widget.height != null) {
      field = ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: widget.height!, maxHeight: widget.height!),
        child: field,
      );
    }

    return SizedBox(
      width: widget.width,
      child: field,
    );
  }
}
