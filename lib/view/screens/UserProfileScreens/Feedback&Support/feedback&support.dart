import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class FeedbackSupportScreen extends StatefulWidget {
  const FeedbackSupportScreen({super.key});

  @override
  State<FeedbackSupportScreen> createState() => _FeedbackSupportScreenState();
}

class _FeedbackSupportScreenState extends State<FeedbackSupportScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();

  String? _type;
  String? _urgency;

  final List<String> _types = ['Bug', 'Account', 'Feature request', 'Other'];
  final List<String> _urgencies = ['Low', 'Medium', 'High'];

  final ImagePicker _picker = ImagePicker();
  final List<_PickedImage> _images = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onFieldChanged);
    _descriptionCtrl.addListener(_onFieldChanged);
    _descriptionFocusNode.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _titleCtrl.removeListener(_onFieldChanged);
    _descriptionCtrl.removeListener(_onFieldChanged);
    _descriptionFocusNode.removeListener(_onFieldChanged);

    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;

      final List<_PickedImage> converted = await Future.wait(
        picked.map(
          (x) async => _PickedImage(
            bytes: await x.readAsBytes(),
            name: x.name,
          ),
        ),
      );

      setState(() => _images.addAll(converted));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${strings.errorSelectingImagesText}: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (photo == null) return;

      final bytes = await photo.readAsBytes();

      setState(() {
        _images.add(
          _PickedImage(
            bytes: bytes,
            name: photo.name,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${strings.errorTakingPhotoText}: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  bool get _canSave {
    return _titleCtrl.text.trim().isNotEmpty &&
        _descriptionCtrl.text.trim().isNotEmpty &&
        (_type != null && _type!.trim().isNotEmpty) &&
        (_urgency != null && _urgency!.trim().isNotEmpty);
  }

  void _submit() {
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.fillRequiredFieldsSnackText)),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.submitSnackText)),
    );

    setState(() {
      _titleCtrl.clear();
      _descriptionCtrl.clear();
      _type = null;
      _urgency = null;
      _images.clear();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: appTheme.black90001,
            size: dimension.d22.sp,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: dimension.d20.w,
                    vertical: dimension.d12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: dimension.d6.h),
                      Text(
                        strings.feedbackSupportTitle,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d22.h),
                      Text(
                        strings.titleLabel,
                        style: customButtonandTextStyles.emailLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d15.h),
                      CustomTextFormField(
                        controller: _titleCtrl,
                        hintText: strings.titleHintText,
                        prefix: Icon(
                          Icons.event_note_outlined,
                          color: appTheme.neutral_700,
                        ),
                        onChanged: (_) => _onFieldChanged(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: dimension.d14.w,
                          vertical: dimension.d14.h,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        inputDecoration: customButtonandTextStyles
                            .feedbackfInputDecoration
                            .copyWith(
                          hintStyle: customButtonandTextStyles
                              .dateFieldTextStyle
                              .copyWith(
                            color: appTheme.neutral_400,
                            fontSize: dimension.d14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: dimension.d15.h),
                      Text(
                        strings.typeLabel,
                        style: customButtonandTextStyles.emailLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      CustomDropdownButton(
                        hint: strings.typeHintText,
                        items: _types,
                        value: _type,
                        onChanged: (v) => setState(() => _type = v),
                        decoration: customButtonandTextStyles
                            .feedbackfInputDecoration
                            .copyWith(
                          prefixIcon: Icon(
                            Icons.info_outline,
                            color: appTheme.neutral_700,
                          ),
                        ),
                      ),
                      SizedBox(height: dimension.d15.h),
                      Text(
                        strings.urgencyLabel,
                        style: customButtonandTextStyles.emailLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      CustomDropdownButton(
                        hint: strings.urgencyHintText,
                        items: _urgencies,
                        value: _urgency,
                        onChanged: (v) => setState(() => _urgency = v),
                        decoration: customButtonandTextStyles
                            .feedbackfInputDecoration
                            .copyWith(
                          prefixIcon: Icon(
                            Icons.label_outline,
                            color: appTheme.neutral_700,
                          ),
                          hintText: strings.urgencyHintText,
                        ),
                        menuColor: appTheme.coreWhite,
                        itemTextStyle: TextStyle(
                          fontSize: dimension.d14.sp,
                          color: appTheme.black90001,
                        ),
                      ),
                      SizedBox(height: dimension.d15.h),
                      Text(
                        strings.descriptionLabel,
                        style: customButtonandTextStyles.emailLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
                        maxLines: 10,
                        controller: _descriptionCtrl,
                        hintText: strings.descriptionHintText,
                        textInputType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: dimension.d14,
                          vertical: dimension.d14,
                        ),
                        prefix: Icon(
                          Icons.description,
                          color: appTheme.neutral_700,
                        ),
                        inputDecoration: customButtonandTextStyles
                            .messagefInputDecoration
                            .copyWith(
                          floatingLabelStyle: TextStyle(
                            color: appTheme.black90001,
                          ),
                          hintStyle: customButtonandTextStyles
                              .dateFieldTextStyle
                              .copyWith(
                            color: appTheme.neutral_400,
                            fontSize: dimension.d14,
                          ),
                        ),
                        onChanged: (_) => _onFieldChanged(),
                      ),
                      SizedBox(height: dimension.d18.h),
                      Text(
                        strings.attachmentsLabel,
                        style: customButtonandTextStyles.emailLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d15.h),
                      GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: appTheme.coreWhite,
                            builder: (_) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: Text(strings.chooseFromGalleryText),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImages();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: Text(strings.takeAPhotoText),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _takePhoto();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: DottedBorder(
                          color: appTheme.borderColor,
                          strokeWidth: dimension.d1.w,
                          borderType: BorderType.RRect,
                          radius: Radius.circular(dimension.d12.r),
                          dashPattern: const [5, 4],
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(dimension.d12.w),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(dimension.d12.r),
                              color: appTheme.coreWhite,
                            ),
                            child: _images.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_outlined,
                                        size: dimension.d28.sp,
                                        color: appTheme.neutral_700,
                                      ),
                                      SizedBox(height: dimension.d8.h),
                                      Text(
                                        strings.dropImagesText,
                                        style: TextStyle(
                                          color: appTheme.neutral_700,
                                          fontSize: dimension.d13.sp,
                                        ),
                                      ),
                                    ],
                                  )
                                : Wrap(
                                    spacing: dimension.d12.w,
                                    runSpacing: dimension.d12.h,
                                    children: List.generate(
                                      _images.length,
                                      (i) {
                                        final item = _images[i];
                                        return Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                dimension.d8.r,
                                              ),
                                              child: Image.memory(
                                                item.bytes,
                                                width: dimension.d100.w,
                                                height: dimension.d100.h,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: dimension.d6.h,
                                              right: dimension.d6.w,
                                              child: GestureDetector(
                                                onTap: () => _removeImage(i),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: appTheme.black90001,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      dimension.d4.w,
                                                    ),
                                                    child: Icon(
                                                      Icons.close,
                                                      size: dimension.d16.sp,
                                                      color: appTheme.coreWhite,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: dimension.d20.h),
                      CustomElevatedButton(
                        inactiveColor: appTheme.neutral_200,
                        inactiveTextColor: appTheme.neutral_500,
                        activeTextColor: appTheme.coreWhite,
                        activeColor: appTheme.b_Primary,
                        onPressed: _canSave ? _submit : null,
                        buttonStyle: customButtonandTextStyles.loginButtonStyle,
                        text: strings.saveDetailsText,
                        buttonTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
                      ),
                      SizedBox(height: dimension.d20.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PickedImage {
  final Uint8List bytes;
  final String? name;

  const _PickedImage({
    required this.bytes,
    this.name,
  });
}
