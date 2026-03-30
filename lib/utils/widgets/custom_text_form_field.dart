import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetmern/utils/constants/constants.dart';
import 'package:meetmern/utils/dimension_resource/dimension_resource.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';

final DimensionResource dimension = DimensionResource();
final appTheme = ThemeHelper(appThemeName: strings.lightCode).themeColor;
final Constants constant = Constants();
const strings = Strings();

class CustomTextFormField extends StatefulWidget {
  final Alignment? alignment;
  final double? height;
  final double? width;
  final BoxDecoration? boxDecoration;
  final EdgeInsets? scrollPadding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextStyle? textStyle;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final int? maxLines;
  final String? hintText;
  final String? labelText;
  final String? errorMessage;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final EdgeInsetsGeometry? contentPadding;
  final InputDecoration? inputDecoration;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool? isDense;
  final bool isAppBar;
  final TextAlignVertical? textAlignVertical;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign? textAlign;
  final bool expands;

  const CustomTextFormField({
    super.key,
    this.alignment,
    this.width,
    this.height,
    this.boxDecoration,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.isDense,
    this.readOnly = false,
    this.onTap,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines = 1,
    this.hintText,
    this.labelText,
    this.errorMessage,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.contentPadding,
    this.inputDecoration,
    this.validator,
    this.onChanged,
    this.isAppBar = false,
    this.onFieldSubmitted,
    this.textAlignVertical,
    this.maxLength,
    this.inputFormatters,
    this.textAlign,
    this.expands = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool get _isMultiline =>
      widget.expands || (widget.maxLines != null && widget.maxLines! > 1);

  InputBorder _defaultBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(dimension.d14),
      borderSide: BorderSide(
        color: appTheme.black900,
        width: 1,
      ),
    );
  }

  InputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(dimension.d14),
      borderSide: BorderSide(
        color: appTheme.red,
        width: dimension.d1,
      ),
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: widget.hintText ?? "",
      labelText: widget.labelText,
      alignLabelWithHint: _isMultiline,
      floatingLabelStyle: TextStyle(color: appTheme.black90001),
      hintStyle: widget.hintStyle ?? theme.textTheme.bodyMedium,
      errorText: (widget.errorMessage != null && _controller.text.isEmpty)
          ? widget.errorMessage
          : null,
      prefixIcon: widget.prefix,
      prefixIconConstraints: widget.prefixConstraints ??
          const BoxConstraints.tightFor(width: 48, height: 48),
      suffixIcon: widget.suffix,
      suffixIconConstraints: widget.suffixConstraints ??
          const BoxConstraints.tightFor(width: 48, height: 48),
      isDense: widget.isDense ?? true,
      contentPadding: widget.contentPadding ??
          EdgeInsets.fromLTRB(
            14,
            16,
            14,
            _isMultiline ? 16 : 14,
          ),
      fillColor: appTheme.coreWhite,
      filled: true,
      border: _defaultBorder(),
      enabledBorder: _defaultBorder(),
      focusedBorder: _defaultBorder().copyWith(
        borderSide: BorderSide(
          color: appTheme.blue800,
          width: 2,
        ),
      ),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _errorBorder(),
      counterText: widget.maxLength != null ? "" : null,
    );
  }

  InputDecoration _buildAppBarDecoration(BuildContext context) {
    return InputDecoration(
      hintText: widget.hintText ?? "",
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: dimension.d8,
        vertical: dimension.d10,
      ),
      fillColor: appTheme.blacktransparent,
      filled: false,
    );
  }

  Widget _textFormFieldWidget(BuildContext context) {
    final baseDecoration = widget.inputDecoration ??
        (widget.isAppBar
            ? _buildAppBarDecoration(context)
            : _buildDecoration(context));

    final decoration = baseDecoration.copyWith(
      hintText: widget.hintText ?? baseDecoration.hintText,
      labelText: widget.labelText ?? baseDecoration.labelText,
      hintStyle: widget.hintStyle ?? baseDecoration.hintStyle,
      errorText: (widget.errorMessage != null && _controller.text.isEmpty)
          ? widget.errorMessage
          : baseDecoration.errorText,
      prefixIcon: widget.prefix ?? baseDecoration.prefixIcon,
      prefixIconConstraints:
          widget.prefixConstraints ?? baseDecoration.prefixIconConstraints,
      suffixIcon: widget.suffix ?? baseDecoration.suffixIcon,
      suffixIconConstraints:
          widget.suffixConstraints ?? baseDecoration.suffixIconConstraints,
      contentPadding: widget.contentPadding ?? baseDecoration.contentPadding,
      isDense: widget.isDense ?? baseDecoration.isDense,
      alignLabelWithHint: _isMultiline,
      counterText: widget.maxLength != null ? "" : null,
    );

    final theme = Theme.of(context);

    final field = TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      scrollPadding: widget.scrollPadding ??
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      textInputAction: widget.textInputAction,
      keyboardType:
          _isMultiline ? TextInputType.multiline : widget.textInputType,

      // Fixed-height multiline support
      maxLines: widget.expands ? null : widget.maxLines,
      minLines: widget.expands ? null : 1,
      expands: widget.expands,

      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      style: widget.textStyle ?? theme.textTheme.bodyMedium,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      textAlignVertical: widget.textAlignVertical ??
          (_isMultiline ? TextAlignVertical.top : TextAlignVertical.center),
      textAlign: widget.textAlign ?? TextAlign.start,
      decoration: decoration,
      validator: widget.validator,
    );

    Widget result = Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: widget.boxDecoration,
      child: field,
    );

    if (widget.boxDecoration != null &&
        widget.boxDecoration!.borderRadius != null) {
      result = ClipRRect(
        borderRadius: widget.boxDecoration!.borderRadius as BorderRadius,
        child: result,
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return widget.alignment != null
        ? Align(
            alignment: widget.alignment!,
            child: _textFormFieldWidget(context),
          )
        : _textFormFieldWidget(context);
  }
}
