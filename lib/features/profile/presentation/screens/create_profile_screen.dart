import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
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
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 40),
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
                                  const SizedBox(
                                    width: 321,
                                    child: Text(
                                      'Create a profile',
                                      style: AppTextStyles.screenTitle,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const SizedBox(
                                    width: 321,
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
                                  const SizedBox(height: 32),
                                  ProfileTextField(
                                    label: 'Enter your email',
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    hintText: 'e.g johndoe@gmail.com',
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
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: viewModel.isSubmitting
                                ? null
                                : _handleSubmit,
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
                      ],
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
