import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetmern/utils/dimension_resource/dimension_resource.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';

final DimensionResource dimension = DimensionResource();
final appTheme = ThemeHelper(appThemeName: strings.lightCode).themeColor;

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
  const CustomTextFormField(
      {super.key,
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
      this.textAlign});
  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
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

  InputBorder _defaultBorder(BuildContext context) {
    final appTheme = ThemeHelper(appThemeName: strings.lightCode).themeColor;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(dimension.d14),
      borderSide: BorderSide(
        color: appTheme.black900,
        width: 1,
      ),
    );
  }

  InputBorder _errorBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(dimension.d14),
      borderSide: BorderSide(
        color: appTheme.red,
        width: dimension.d1,
      ),
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final appTheme = ThemeHelper(appThemeName: strings.lightCode).themeColor;
    final ThemeData theme = Theme.of(context);
    return InputDecoration(
      hintText: widget.hintText ?? "",
      labelText: widget.labelText,
      floatingLabelStyle: TextStyle(color: appTheme.black90001),
      hintStyle: widget.hintStyle ?? theme.textTheme.bodyMedium,
      errorText: (widget.errorMessage != null && _controller.text.isEmpty)
          ? widget.errorMessage
          : null,
      prefixIcon: widget.prefix,
      prefixIconConstraints: widget.prefixConstraints,
      suffixIcon: widget.suffix,
      suffixIconConstraints: widget.suffixConstraints,
      isDense: widget.isDense ?? true,
      contentPadding: widget.contentPadding ?? EdgeInsets.all(dimension.d14),
      fillColor: appTheme.coreWhite,
      filled: true,
      border: _defaultBorder(context),
      enabledBorder: _defaultBorder(context),
      focusedBorder: _defaultBorder(context).copyWith(
        borderSide: BorderSide(
          color: appTheme.blue800,
          width: 2,
        ),
      ),
      errorBorder: _errorBorder(context),
      focusedErrorBorder: _errorBorder(context),
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
          horizontal: dimension.d8, vertical: dimension.d10),
      fillColor: appTheme.blacktransparent,
      filled: false,
    );
  }

  Widget _textFormFieldWidget(BuildContext context) {
    final decoration = widget.inputDecoration ??
        (widget.isAppBar
            ? _buildAppBarDecoration(context)
            : _buildDecoration(context));
    final ThemeData theme = Theme.of(context);

    return Container(
      height: widget.height ?? 50,
      width: widget.width ?? double.infinity,
      decoration: widget.boxDecoration,
      child: TextFormField(
        textAlignVertical: widget.textAlignVertical,
        textAlign: widget.textAlign ?? TextAlign.start,
        controller: _controller,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        scrollPadding: widget.scrollPadding ??
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        focusNode: widget.focusNode,
        onTap: widget.onTap,
        textInputAction: widget.textInputAction,
        keyboardType: widget.textInputType,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        style: widget.textStyle ?? theme.textTheme.bodyMedium,
        obscureText: widget.obscureText,
        readOnly: widget.readOnly,
        decoration: decoration.copyWith(
          suffixIcon: widget.isAppBar
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                )
              : widget.suffix,
          suffixIconConstraints: widget.suffixConstraints,
          counterText: widget.maxLength != null ? "" : null,
        ),
        validator: widget.validator,
      ),
    );
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
