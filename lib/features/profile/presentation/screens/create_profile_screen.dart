import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../../settings/presentation/widgets/import_existing_profile_sheet.dart';
import '../viewmodels/create_profile_view_model.dart';
import '../widgets/profile_created_sheet.dart';
import '../widgets/profile_text_field.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _handleSubmit() async {
    _dismissKeyboard();

    final didCreate = await context.read<CreateProfileViewModel>().submit();
    if (!mounted || !didCreate) {
      return;
    }

    await showProfileCreatedSheet(context);
    if (!mounted) {
      return;
    }

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateProfileViewModel>(
      builder: (context, viewModel, _) {
        final canProceed = viewModel.canSubmit && !viewModel.isSubmitting;

        return AppScreen(
          child: PhoneViewport(
            child: SafeArea(
              child: GestureDetector(
                onTap: _dismissKeyboard,
                behavior: HitTestBehavior.translucent,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Padding(
                    padding: context.pagePadding(top: 56, bottom: 40),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.formContentMaxWidth ?? double.infinity,
                      ),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.folderIllustration,
                                    width: 72,
                                    height: 72,
                                  ),
                                  const SizedBox(height: 16),
                                  const ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 321),
                                    child: Text(
                                      'Create a profile',
                                      style: AppTextStyles.screenTitle,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 321),
                                    child: Text(
                                      'Enter your name and email address to proceed',
                                      style: AppTextStyles.screenSubtitle,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  ProfileTextField(
                                    label: 'Enter your name',
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    hintText: 'e.g John Doe',
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.name],
                                    errorText: viewModel.nameError,
                                    onChanged: viewModel.updateName,
                                    onBlur: viewModel.markNameTouched,
                                    onSubmitted: (_) {
                                      _emailFocusNode.requestFocus();
                                    },
                                  ),
                                  const SizedBox(height: 26),
                                  ProfileTextField(
                                    label: 'Email address',
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    hintText: 'e.g example@gmail.com',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [AutofillHints.email],
                                    errorText: viewModel.emailError,
                                    onChanged: viewModel.updateEmail,
                                    onBlur: viewModel.markEmailTouched,
                                    onSubmitted: (_) => _handleSubmit(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            key: const Key('create-profile-proceed-button'),
                            onPressed: canProceed ? _handleSubmit : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.brandGreen,
                              disabledBackgroundColor: const Color(0xFFF4F6F8),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: AppColors.textDisabled,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                              ),
                            ),
                            child: viewModel.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Proceed'),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            key: const Key('create-profile-import-link'),
                            onPressed: () => showImportExistingProfileSheet(
                              context,
                              onImported: () => context.go(AppRoutes.home),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text.rich(
                              TextSpan(
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.2,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Have an existing profile? ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Import',
                                    style: TextStyle(
                                      color: AppColors.brandGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 309),
                            child: Text(
                              'Note, this app is completely managed offline and all data is stored on your device',
                              key: const Key('create-profile-offline-note'),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: math.max(
                            0,
                            MediaQuery.of(context).padding.bottom * 0.25,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
