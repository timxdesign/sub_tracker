import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../../profile/presentation/widgets/profile_text_field.dart';
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: 20),
                    Text('Edit profile', style: AppTextStyles.sheetTitle),
                    const SizedBox(height: 8),
                    const Text(
                      'Update your name and email locally on this device.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 32),
                    if (viewModel.screenError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          viewModel.screenError!,
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                    ProfileTextField(
                      label: 'Full name',
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      hintText: 'e.g John Doe',
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      errorText: viewModel.nameError,
                      onChanged: viewModel.updateName,
                      onBlur: viewModel.markNameTouched,
                      onSubmitted: (_) => _emailFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 24),
                    ProfileTextField(
                      label: 'Email address',
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hintText: 'e.g johndoe@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      errorText: viewModel.emailError,
                      onChanged: viewModel.updateEmail,
                      onBlur: viewModel.markEmailTouched,
                      onSubmitted: (_) => _handleSave(),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: viewModel.isSaving ? null : _handleSave,
                        child: viewModel.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
