import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../domain/models/subscription.dart';
import '../viewmodels/subscription_form_view_model.dart';
import '../widgets/subscription_feature_widgets.dart';

class SubscriptionFormScreen extends StatefulWidget {
  const SubscriptionFormScreen({super.key});

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickBillingDate(
    BuildContext context,
    SubscriptionFormViewModel viewModel,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: viewModel.nextBillingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      viewModel.updateNextBillingDate(pickedDate);
    }
  }

  Future<void> _submit(BuildContext context) async {
    final didSave = await context.read<SubscriptionFormViewModel>().submit();
    if (!mounted || didSave == null) {
      return;
    }

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionFormViewModel>(
      builder: (context, viewModel, _) {
        return AppScreen(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Add Subscription'),
          ),
          child: PhoneViewport(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                children: [
                  Text(
                    'Capture a new renewal and keep your dashboard updated instantly.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel('Subscription name'),
                  const SizedBox(height: 8),
                  _TextFieldCard(
                    controller: _nameController,
                    hintText: 'e.g Netflix Premium',
                    onChanged: viewModel.updateName,
                    errorText: viewModel.nameError,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Category'),
                  const SizedBox(height: 8),
                  SurfaceCard(
                    radius: 24,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: SubscriptionCategory.values.map((category) {
                            final isSelected = viewModel.category == category;
                            return InkWell(
                              onTap: () => viewModel.updateCategory(category),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.brandSoft
                                      : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SubscriptionCategoryIcon(category: category),
                                    const SizedBox(width: 8),
                                    Text(
                                      category.label,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.brandGreen
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(growable: false),
                        ),
                        if (viewModel.categoryError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            viewModel.categoryError!,
                            style: AppTextStyles.errorText,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Price'),
                  const SizedBox(height: 8),
                  _TextFieldCard(
                    controller: _priceController,
                    hintText: 'e.g 8000',
                    onChanged: viewModel.updatePrice,
                    errorText: viewModel.priceError,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefix: Text(
                      'N',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Billing cycle'),
                  const SizedBox(height: 8),
                  SurfaceCard(
                    radius: 24,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: SubscriptionBillingCycle.values.map((cycle) {
                        final isSelected = viewModel.billingCycle == cycle;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => viewModel.updateBillingCycle(cycle),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.brandGreen
                                      : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  cycle.label,
                                  style: isSelected
                                      ? AppTextStyles.tabLabelActive
                                      : AppTextStyles.tabLabel.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Renewal date'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _pickBillingDate(context, viewModel),
                    borderRadius: BorderRadius.circular(24),
                    child: SurfaceCard(
                      radius: 24,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatShortDate(viewModel.nextBillingDate),
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Notes'),
                  const SizedBox(height: 8),
                  _TextFieldCard(
                    controller: _descriptionController,
                    hintText: 'Optional details',
                    onChanged: viewModel.updateDescription,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: viewModel.isSubmitting
                        ? null
                        : () => _submit(context),
                    child: viewModel.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save subscription'),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.inputLabel);
  }
}

class _TextFieldCard extends StatelessWidget {
  const _TextFieldCard({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.prefix,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurfaceCard(
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (prefix != null) ...[
                prefix!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  textCapitalization: textCapitalization,
                  style: AppTextStyles.inputValue,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.inputPlaceholder,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: AppTextStyles.errorText),
        ],
      ],
    );
  }
}
