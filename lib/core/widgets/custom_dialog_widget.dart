import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class DialogField {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;

  final TextStyle? labelStyle;
  final TextStyle? hintStyle;

  const DialogField({
    required this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.labelStyle,
    this.hintStyle,
  });
}

class CustomModalDialog extends StatefulWidget {
  final Widget? topLeftIcon;
  final Widget? topRightIcon;

  final String? title;
  final String? subtitle;
  final String? text1;
  final String? text2;

  final String? subtitleHighlightedText;

  final Widget? content;
  final List<DialogField>? fields;

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryBold;

  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  final bool showCloseButton;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color primaryColor;
  final Color backgroundColor;
  final bool centerTitle;

  final bool centerHeaderTitle;

  final ButtonStyle? primaryButtonStyle;
  final ButtonStyle? secondaryButtonStyle;
  final TextStyle? primaryTextStyle;
  final TextStyle? secondaryTextStyle;

  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final TextStyle? text1Style;
  final TextStyle? text2Style;

  final TextStyle? subtitleHighlightedTextStyle;

  final bool showLeftIconBackground;
  final Color leftIconBackgroundColor;

  final double? maxWidth;
  final double? maxHeight;

  const CustomModalDialog({
    super.key,
    this.topLeftIcon,
    this.topRightIcon,
    this.title,
    this.subtitle,
    this.text1,
    this.text2,
    this.subtitleHighlightedText,
    this.content,
    this.fields,
    required this.primaryLabel,
    this.onPrimary,
    this.primaryBold = true,
    this.secondaryLabel,
    this.onSecondary,
    this.showCloseButton = false,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 20),
    this.primaryColor = const Color(0xFFFF5B5B),
    this.backgroundColor = Colors.white,
    this.centerTitle = false,
    this.centerHeaderTitle = false,
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.text1Style,
    this.text2Style,
    this.subtitleHighlightedTextStyle,
    this.showLeftIconBackground = false,
    this.leftIconBackgroundColor = const Color(0xFFFFE6E6),
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<CustomModalDialog> createState() => _CustomModalDialogState();
}

class _CustomModalDialogState extends State<CustomModalDialog> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _internalControllers;
  late final List<bool> _obscureFlags;
  late final bool _usingFields;

  @override
  void initState() {
    super.initState();
    _usingFields =
        widget.content == null && (widget.fields?.isNotEmpty ?? false);

    if (_usingFields) {
      final fields = widget.fields!;
      _internalControllers =
          List<TextEditingController>.generate(fields.length, (i) {
        return fields[i].controller ?? TextEditingController();
      });
      _obscureFlags = fields.map((f) => f.isPassword).toList();
    } else {
      _internalControllers = [];
      _obscureFlags = [];
    }
  }

  @override
  void dispose() {
    if (_usingFields) {
      for (int i = 0; i < widget.fields!.length; i++) {
        if (widget.fields![i].controller == null) {
          _internalControllers[i].dispose();
        }
      }
    }
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? prefix,
    Widget? suffix,
    TextStyle? hintStyle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: hintStyle,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      prefixIcon: prefix != null
          ? Padding(
              padding:
                  EdgeInsets.only(left: dimension.d12, right: dimension.d8),
              child: SizedBox(width: dimension.d28, child: prefix),
            )
          : null,
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: widget.primaryColor, width: 1.2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  Widget _buildText(
    String? text, {
    required TextStyle defaultStyle,
    required TextAlign textAlign,
    TextStyle? customStyle,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Text(
        text,
        textAlign: textAlign,
        softWrap: true,
        style: customStyle ?? defaultStyle,
      ),
    );
  }

  Widget _buildSubtitleText({
    required String? text,
    required TextAlign textAlign,
  }) {
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    final highlighted = widget.subtitleHighlightedText;

    final normalStyle = widget.subtitleTextStyle ??
        TextStyle(
          fontSize: 13,
          height: 1.35,
          color: Colors.grey[700],
        );

    if (highlighted == null ||
        highlighted.isEmpty ||
        !text.contains(highlighted)) {
      return Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          text,
          textAlign: textAlign,
          softWrap: true,
          style: normalStyle,
        ),
      );
    }

    final boldStyle =
        (widget.subtitleHighlightedTextStyle ?? normalStyle).copyWith(
      fontSize: normalStyle.fontSize,
      height: normalStyle.height,
      fontWeight: FontWeight.w700,
    );

    final parts = text.split(highlighted);
    final spans = <TextSpan>[];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: normalStyle));
      }

      if (i != parts.length - 1) {
        spans.add(TextSpan(text: highlighted, style: boldStyle));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: RichText(
        textAlign: textAlign,
        softWrap: true,
        text: TextSpan(children: spans),
      ),
    );
  }

  Widget _buttonLabel({
    required String text,
    required TextStyle style,
    required TextAlign align,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: style,
      ),
    );
  }

  Widget _buildHeader({
    required bool isWide,
  }) {
    final leftBubbleSize = isWide ? 42.0 : 36.0;
    final leftIconSize = isWide ? 24.0 : 20.0;
    final rightIconSize = isWide ? 28.0 : 24.0;
    final rightSlotWidth = isWide ? 42.0 : 40.0;

    final Widget leftIcon = widget.topLeftIcon != null
        ? Container(
            width: leftBubbleSize,
            height: leftBubbleSize,
            decoration: BoxDecoration(
              color: widget.showLeftIconBackground
                  ? widget.leftIconBackgroundColor
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: IconTheme(
              data: IconThemeData(size: leftIconSize),
              child: widget.topLeftIcon!,
            ),
          )
        : SizedBox(width: leftBubbleSize, height: leftBubbleSize);

    final Widget rightIcon = widget.topRightIcon ??
        (widget.showCloseButton
            ? IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(
                  width: rightSlotWidth,
                  height: rightSlotWidth,
                ),
                splashRadius: 20,
                icon: Icon(
                  Icons.close,
                  size: rightIconSize,
                  color: const Color(0xFF4A5568),
                ),
              )
            : SizedBox(width: rightSlotWidth, height: rightSlotWidth));

    if (widget.centerHeaderTitle && widget.title != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leftIcon,
          SizedBox(width: isWide ? 8.0 : 6.0),
          Expanded(
            child: Text(
              widget.title!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: widget.titleTextStyle ??
                  const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.15,
                  ),
            ),
          ),
          SizedBox(width: isWide ? 8.0 : 6.0),
          rightIcon,
        ],
      );
    }

    if (widget.topLeftIcon == null &&
        widget.topRightIcon == null &&
        !widget.showCloseButton) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.topLeftIcon != null) leftIcon,
        const Spacer(),
        rightIcon,
      ],
    );
  }

  Widget _buildContent({
    required bool isWide,
  }) {
    final textAlign = widget.centerTitle ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        _buildHeader(isWide: isWide),
        if (widget.topLeftIcon != null ||
            widget.topRightIcon != null ||
            widget.showCloseButton)
          SizedBox(height: dimension.d10),
        if (!widget.centerHeaderTitle)
          _buildText(
            widget.title,
            textAlign: textAlign,
            customStyle: widget.titleTextStyle,
            defaultStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.15,
            ),
          ),
        _buildSubtitleText(
          text: widget.subtitle,
          textAlign: textAlign,
        ),
        _buildText(
          widget.text1,
          textAlign: textAlign,
          customStyle: widget.text1Style,
          defaultStyle: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
          padding: const EdgeInsets.only(top: 8.0),
        ),
        _buildText(
          widget.text2,
          textAlign: textAlign,
          customStyle: widget.text2Style,
          defaultStyle: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
          padding: const EdgeInsets.only(top: 8.0),
        ),
        SizedBox(height: dimension.d18),
        if (widget.content != null)
          widget.content!
        else if (_usingFields)
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.fields!.length, (index) {
                final field = widget.fields![index];
                final controller = _internalControllers[index];
                final isPassword = field.isPassword;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.label,
                        style: field.labelStyle ??
                            const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: dimension.d8),
                      TextFormField(
                        controller: controller,
                        keyboardType: field.keyboardType,
                        obscureText: _obscureFlags[index],
                        validator: field.validator,
                        decoration: _inputDecoration(
                          hint: field.hint ?? '',
                          hintStyle: field.hintStyle,
                          prefix: field.prefixIcon,
                          suffix: isPassword
                              ? IconButton(
                                  icon: Icon(
                                    _obscureFlags[index]
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureFlags[index] =
                                          !_obscureFlags[index];
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          )
        else
          const SizedBox.shrink(),
        SizedBox(height: dimension.d18),
        SizedBox(
          width: double.infinity,
          height: dimension.d52,
          child: ElevatedButton(
            onPressed: () {
              if (_usingFields) {
                if (_formKey.currentState?.validate() ?? true) {
                  widget.onPrimary?.call();
                }
              } else {
                widget.onPrimary?.call();
              }
            },
            style: widget.primaryButtonStyle ??
                ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
            child: _buttonLabel(
              text: widget.primaryLabel,
              align: TextAlign.center,
              style: widget.primaryTextStyle ??
                  TextStyle(
                    fontSize: 16,
                    fontWeight:
                        widget.primaryBold ? FontWeight.w600 : FontWeight.w500,
                    height: 1.0,
                  ),
            ),
          ),
        ),
        SizedBox(height: dimension.d12),
        if (widget.secondaryLabel != null)
          SizedBox(
            width: double.infinity,
            height: dimension.d52,
            child: OutlinedButton(
              onPressed: widget.onSecondary,
              style: widget.secondaryButtonStyle ??
                  OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
              child: _buttonLabel(
                text: widget.secondaryLabel!,
                align: TextAlign.center,
                style: widget.secondaryTextStyle ??
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF344563),
                      height: 1.0,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = MediaQuery.sizeOf(context).height;
        final isWide = screenWidth >= 700;

        final maxWidth = widget.maxWidth ??
            (isWide ? 560.0 : math.min(screenWidth - 32, 420.0));
        final maxHeight =
            widget.maxHeight ?? math.min(screenHeight * 0.9, 760.0);

        final horizontalInset = isWide ? 24.0 : 16.0;
        final verticalInset = isWide ? 24.0 : 16.0;

        final effectivePadding = widget.padding is EdgeInsets
            ? (widget.padding as EdgeInsets)
            : const EdgeInsets.fromLTRB(20, 20, 20, 20);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: verticalInset,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                padding: effectivePadding,
                child: SingleChildScrollView(
                  child: _buildContent(isWide: isWide),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
