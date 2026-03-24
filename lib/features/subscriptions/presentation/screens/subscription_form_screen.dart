import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../domain/models/subscription.dart';
import '../viewmodels/subscription_form_view_model.dart';

class SubscriptionFormScreen extends StatefulWidget {
  const SubscriptionFormScreen({super.key});

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _serviceProviderController =
      TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  static const _categoryOrder = <SubscriptionCategory>[
    SubscriptionCategory.dataPlan,
    SubscriptionCategory.apps,
    SubscriptionCategory.tools,
    SubscriptionCategory.vehicle,
    SubscriptionCategory.insurance,
    SubscriptionCategory.health,
    SubscriptionCategory.other,
    SubscriptionCategory.identity,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _serviceProviderController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      onPicked(pickedDate);
    }
  }

  Future<void> _submit(BuildContext context) async {
    final subscriptionId = await context
        .read<SubscriptionFormViewModel>()
        .submit();
    if (!context.mounted || subscriptionId == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.overlayScrim,
      builder: (_) => const _SubscriptionAddedDialog(),
    );
    if (!context.mounted) {
      return;
    }

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionFormViewModel>(
      builder: (context, viewModel, _) {
        final amountHint = '${_currencySymbol(viewModel)}5,000';

        return AppScreen(
          backgroundColor: AppColors.background,
          child: PhoneViewport(
            child: SafeArea(
              child: Column(
                children: [
                  const _FormHeader(title: 'Add subscription'),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 156),
                          children: [
                            const _SectionTitle(label: 'Basic Info'),
                            const SizedBox(height: 12),
                            _FormCard(
                              child: Column(
                                children: [
                                  _InlineInputField(
                                    label: 'Enter Subscription name',
                                    controller: _nameController,
                                    hintText: 'e.g Netflix premium, ChatGPT',
                                    errorText: viewModel.nameError,
                                    onChanged: viewModel.updateName,
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const SizedBox(height: 16),
                                  _InlineInputField(
                                    label: 'Amount',
                                    controller: _priceController,
                                    hintText: amountHint,
                                    errorText: viewModel.priceError,
                                    onChanged: viewModel.updatePrice,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Category',
                                      style: AppTextStyles.inputLabel,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _categoryOrder
                                        .map((category) {
                                          final isSelected =
                                              viewModel.category == category;
                                          return _SelectionChip(
                                            label: category.label,
                                            isSelected: isSelected,
                                            onTap: () => viewModel
                                                .updateCategory(category),
                                          );
                                        })
                                        .toList(growable: false),
                                  ),
                                  if (viewModel.categoryError != null) ...[
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        viewModel.categoryError!,
                                        style: AppTextStyles.errorText,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _SectionTitle(label: 'Duration'),
                            const SizedBox(height: 12),
                            _FormCard(
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: SubscriptionBillingCycle.values
                                          .map((cycle) {
                                            final isSelected =
                                                viewModel.billingCycle == cycle;
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                right:
                                                    cycle ==
                                                        SubscriptionBillingCycle
                                                            .lifetime
                                                    ? 0
                                                    : 12,
                                              ),
                                              child: _SelectionChip(
                                                label: cycle.label,
                                                isSelected: isSelected,
                                                onTap: () => viewModel
                                                    .updateBillingCycle(cycle),
                                              ),
                                            );
                                          })
                                          .toList(growable: false),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _DateField(
                                          label: 'Start date',
                                          value: _formatInputDate(
                                            viewModel.startDate,
                                          ),
                                          onTap: () => _pickDate(
                                            context: context,
                                            initialDate: viewModel.startDate,
                                            onPicked: viewModel.updateStartDate,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 35),
                                      Expanded(
                                        child: _DateField(
                                          label: 'Enter date',
                                          value: _formatInputDate(
                                            viewModel.nextBillingDate,
                                          ),
                                          onTap: () => _pickDate(
                                            context: context,
                                            initialDate:
                                                viewModel.nextBillingDate,
                                            onPicked:
                                                viewModel.updateNextBillingDate,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _SectionTitle(label: 'Other Info'),
                            const SizedBox(height: 12),
                            _FormCard(
                              child: Column(
                                children: [
                                  _InlineInputField(
                                    label: 'Service Provider',
                                    controller: _serviceProviderController,
                                    hintText: 'Select service provider',
                                    onChanged: viewModel.updateServiceProvider,
                                    suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _InlineInputField(
                                    label: 'Website (Optional)',
                                    controller: _websiteController,
                                    hintText: 'e.g example.com',
                                    onChanged: viewModel.updateWebsite,
                                    keyboardType: TextInputType.url,
                                  ),
                                  const SizedBox(height: 16),
                                  _InlineInputField(
                                    label: 'Description (Optional)',
                                    controller: _descriptionController,
                                    hintText:
                                        'Write important note about subsciption',
                                    onChanged: viewModel.updateDescription,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _BottomActionBar(
                            isBusy: viewModel.isSubmitting,
                            onTap: viewModel.isSubmitting
                                ? null
                                : () => _submit(context),
                          ),
                        ),
                      ],
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

  String _currencySymbol(SubscriptionFormViewModel viewModel) {
    return switch (viewModel.currencyCode.toUpperCase()) {
      'USD' => r'$',
      'NGN' => 'N',
      _ => '${viewModel.currencyCode.toUpperCase()} ',
    };
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 24),
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
              padding: const EdgeInsets.only(right: 64),
              child: Center(
                child: Text(
                  title,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _InlineInputField extends StatelessWidget {
  const _InlineInputField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: maxLines > 1
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: keyboardType,
                maxLines: maxLines,
                minLines: maxLines,
                textCapitalization: textCapitalization,
                style: AppTextStyles.inputValue,
                decoration: InputDecoration.collapsed(
                  hintText: hintText,
                  hintStyle: AppTextStyles.inputPlaceholder,
                ),
              ),
            ),
            if (suffixIcon != null) ...[const SizedBox(width: 12), suffixIcon!],
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: AppTextStyles.errorText),
        ],
      ],
    );
  }
}

class _SelectionChip extends StatelessWidget {
  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(33),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGreen : AppColors.background,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.16,
            color: isSelected ? Colors.white : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.inputLabel),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(value, style: AppTextStyles.inputPlaceholder),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.isBusy, required this.onTap});

  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          color: const Color(0xB3FFFFFF),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.addIcon,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Add subscription',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionAddedDialog extends StatefulWidget {
  const _SubscriptionAddedDialog();

  @override
  State<_SubscriptionAddedDialog> createState() =>
      _SubscriptionAddedDialogState();
}

class _SubscriptionAddedDialogState extends State<_SubscriptionAddedDialog> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Subscription Added',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 20,
                  height: 28 / 20,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatInputDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$month/$day/${value.year}';
}
