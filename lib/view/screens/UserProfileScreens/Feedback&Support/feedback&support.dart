import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/controllers/userprofile_controller/Feedback&Support/feedback&support_controller.dart';

class FeedbackSupportScreen extends StatelessWidget {
  const FeedbackSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return GetBuilder<FeedbackSupportController>(
      builder: (controller) {
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
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
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

                          // Error banner
                          if (controller.errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(dimension.d12.w),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                    BorderRadius.circular(dimension.d8.r),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                controller.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: dimension.d13.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: dimension.d15.h),
                          ],

                          Text(
                            strings.titleLabel,
                            style:
                                customButtonandTextStyles.emailLabelTextStyle,
                          ),
                          SizedBox(height: dimension.d15.h),
                          CustomTextFormField(
                            controller: controller.titleController,
                            hintText: strings.titleHintText,
                            prefix: Icon(
                              Icons.event_note_outlined,
                              color: appTheme.neutral_700,
                            ),
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
                            style:
                                customButtonandTextStyles.emailLabelTextStyle,
                          ),
                          SizedBox(height: dimension.d8.h),
                          CustomDropdownButton(
                            hint: strings.typeHintText,
                            items: controller.types,
                            value: controller.type,
                            onChanged: controller.setType,
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
                            style:
                                customButtonandTextStyles.emailLabelTextStyle,
                          ),
                          SizedBox(height: dimension.d8.h),
                          CustomDropdownButton(
                            hint: strings.urgencyHintText,
                            items: controller.urgencies,
                            value: controller.urgency,
                            onChanged: controller.setUrgency,
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
                            style:
                                customButtonandTextStyles.emailLabelTextStyle,
                          ),
                          SizedBox(height: dimension.d8.h),
                          CustomTextFormField(
                            maxLines: 10,
                            controller: controller.descriptionController,
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
                          ),
                          SizedBox(height: dimension.d18.h),
                          Text(
                            strings.attachmentsLabel,
                            style:
                                customButtonandTextStyles.emailLabelTextStyle,
                          ),
                          SizedBox(height: dimension.d15.h),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: appTheme.coreWhite,
                                builder: (_) => SafeArea(
                                  child: Wrap(
                                    children: [
                                      ListTile(
                                        leading:
                                            const Icon(Icons.photo_library),
                                        title:
                                            Text(strings.chooseFromGalleryText),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          controller.pickImages();
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: Text(strings.takeAPhotoText),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          controller.takePhoto();
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
                                child: controller.attachments.isEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                          controller.attachments.length,
                                          (i) {
                                            final item =
                                                controller.attachments[i];
                                            return Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          dimension.d8.r),
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
                                                    onTap: () => controller
                                                        .removeAttachment(i),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            appTheme.black90001,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            dimension.d4.w),
                                                        child: Icon(
                                                          Icons.close,
                                                          size:
                                                              dimension.d16.sp,
                                                          color: appTheme
                                                              .coreWhite,
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
                          controller.isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: appTheme.b_Primary,
                                  ),
                                )
                              : CustomElevatedButton(
                                  inactiveColor: appTheme.neutral_200,
                                  inactiveTextColor: appTheme.neutral_500,
                                  activeTextColor: appTheme.coreWhite,
                                  activeColor: appTheme.b_Primary,
                                  onPressed: controller.canSubmit
                                      ? () async {
                                          FocusScope.of(context).unfocus();
                                          await controller.submit();
                                          if (!context.mounted) return;
                                          if (controller.errorMessage == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      strings.submitSnackText)),
                                            );
                                          }
                                        }
                                      : null,
                                  buttonStyle: customButtonandTextStyles
                                      .loginButtonStyle,
                                  text: strings.saveDetailsText,
                                  buttonTextStyle: customButtonandTextStyles
                                      .loginButtonTextStyle,
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
      },
    );
  }
}
