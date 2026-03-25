import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../../profile/presentation/widgets/profile_text_field.dart';
import '../../../subscriptions/presentation/widgets/subscription_feature_widgets.dart';
import '../viewmodels/edit_profile_view_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<EditProfileViewModel>();
      await viewModel.load();
      if (!mounted) {
        return;
      }
      _nameController.text = viewModel.name;
      _emailController.text = viewModel.email;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final didSave = await context.read<EditProfileViewModel>().save();
    if (!mounted || !didSave) {
      return;
    }

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, _) {
        return AppScreen(
          child: PhoneViewport(
            child: SafeArea(
              child: Column(
                children: [
                  const _SettingsSubpageHeader(title: 'Edit Profile'),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: context.formContentMaxWidth ?? double.infinity,
                        ),
                        child: ListView(
                          padding: context.pagePadding(top: 26, bottom: 32),
                          children: [
                            if (viewModel.screenError != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  viewModel.screenError!,
                                  style: AppTextStyles.bodyMuted,
                                ),
                              ),
                            SurfaceCard(
                              radius: 24,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  ProfileTextField(
                                    label: 'Enter your name',
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    hintText: 'John Doe',
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    errorText: viewModel.nameError,
                                    onChanged: viewModel.updateName,
                                    onBlur: viewModel.markNameTouched,
                                    onSubmitted: (_) =>
                                        _emailFocusNode.requestFocus(),
                                  ),
                                  const SizedBox(height: 26),
                                  ProfileTextField(
                                    label: 'Email address',
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    hintText: 'example@gmail.com',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    errorText: viewModel.emailError,
                                    onChanged: viewModel.updateEmail,
                                    onBlur: viewModel.markEmailTouched,
                                    onSubmitted: (_) => _handleSave(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                onPressed: viewModel.isSaving ? null : _handleSave,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.brandGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  textStyle: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                child: viewModel.isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSubpageHeader extends StatelessWidget {
  const _SettingsSubpageHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.pageHorizontalPadding;
    return Container(
      height: 64,
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(width: horizontalPadding),
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: horizontalPadding + 40),
              child: Center(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 20,
                    height: 28 / 20,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
