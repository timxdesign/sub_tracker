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

enum _FormPickerField { startDate, nextBillingDate, serviceProvider }

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

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _serviceProviderFocusNode = FocusNode();
  final FocusNode _websiteFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  static const _categoryOrder = <SubscriptionCategory>[
    SubscriptionCategory.dataPlan,
    SubscriptionCategory.apps,
    SubscriptionCategory.tools,
    SubscriptionCategory.vehicle,
    SubscriptionCategory.insurance,
    SubscriptionCategory.identity,
    SubscriptionCategory.health,
    SubscriptionCategory.others,
  ];

  static const _billingCycleOptions = <SubscriptionBillingCycle>[
    SubscriptionBillingCycle.monthly,
    SubscriptionBillingCycle.yearly,
    SubscriptionBillingCycle.custom,
  ];

  static const _serviceProviderOptions = <_ServiceProviderOption>[
    _ServiceProviderOption(label: 'Netflix', assetPath: AppAssets.netflixLogo),
    _ServiceProviderOption(label: 'OpenAI', assetPath: AppAssets.openAiLogo),
    _ServiceProviderOption(
      label: 'Prime Video',
      assetPath: AppAssets.primeVideoLogo,
    ),
    _ServiceProviderOption(label: 'Airtel', assetPath: AppAssets.airtelLogo),
    _ServiceProviderOption(label: 'MTN', assetPath: AppAssets.mtnLogo),
    _ServiceProviderOption(label: 'Identity', assetPath: AppAssets.idLogo),
    _ServiceProviderOption(label: 'Others'),
  ];

  _FormPickerField? _activePickerField;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _serviceProviderController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    _serviceProviderFocusNode.dispose();
    _websiteFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required BuildContext context,
    required _FormPickerField field,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    setState(() {
      _activePickerField = field;
    });

    try {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime(2010),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
      );

      if (pickedDate != null) {
        onPicked(pickedDate);
      }
    } finally {
      if (mounted) {
        setState(() {
          _activePickerField = null;
        });
      }
    }
  }

  Future<void> _showServiceProviderSheet(
    BuildContext context,
    SubscriptionFormViewModel viewModel,
  ) async {
    _serviceProviderFocusNode.unfocus();
    setState(() {
      _activePickerField = _FormPickerField.serviceProvider;
    });

    final selectedProvider = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlayScrim,
      builder: (context) {
        return _ServiceProviderSheet(
          selectedValue: viewModel.serviceProvider,
          options: _serviceProviderOptions,
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _activePickerField = null;
    });

    if (selectedProvider == null) {
      return;
    }

    _serviceProviderController
      ..text = selectedProvider
      ..selection = TextSelection.collapsed(offset: selectedProvider.length);
    viewModel.updateServiceProvider(selectedProvider);
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
              bottom: false,
              child: Column(
                children: [
                  const SubPage_Header(title: 'Add subscription'),
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _SubscriptionTextField(
                                    label: 'Enter Subscription name',
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    hintText: 'e.g Netflix premium, ChatGPT',
                                    errorText: viewModel.nameError,
                                    onChanged: viewModel.updateName,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) => FocusScope.of(
                                      context,
                                    ).requestFocus(_priceFocusNode),
                                  ),
                                  const SizedBox(height: 16),
                                  _SubscriptionTextField(
                                    label: 'Amount',
                                    controller: _priceController,
                                    focusNode: _priceFocusNode,
                                    hintText: amountHint,
                                    errorText: viewModel.priceError,
                                    onChanged: viewModel.updatePrice,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) => FocusScope.of(
                                      context,
                                    ).requestFocus(_serviceProviderFocusNode),
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
                                    alignment: WrapAlignment.start,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _categoryOrder
                                        .map((category) {
                                          return _SelectionChip(
                                            label: category.label,
                                            isSelected:
                                                viewModel.category == category,
                                            surfaceKey: ValueKey(
                                              'subscription-category-chip-${category.name}',
                                            ),
                                            onTap: () => viewModel
                                                .updateCategory(category),
                                          );
                                        })
                                        .toList(growable: false),
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOutCubic,
                                    child: viewModel.categoryError == null
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                viewModel.categoryError!,
                                                style: AppTextStyles.errorText,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _SectionTitle(label: 'Duration'),
                            const SizedBox(height: 12),
                            _FormCard(
                              child: _buildDurationSection(context, viewModel),
                            ),
                            const SizedBox(height: 12),
                            const _SectionTitle(label: 'Other Info'),
                            const SizedBox(height: 12),
                            _FormCard(
                              child: _buildOtherInfoSection(context, viewModel),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _BottomActionBar(
                            isBusy: viewModel.isSubmitting,
                            isActive: viewModel.canSubmit,
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

  Widget _buildDurationSection(
    BuildContext context,
    SubscriptionFormViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _billingCycleOptions
                  .map((cycle) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: cycle == _billingCycleOptions.last ? 0 : 12,
                      ),
                      child: _SelectionChip(
                        label: cycle.label,
                        isSelected: viewModel.billingCycle == cycle,
                        surfaceKey: ValueKey(
                          'subscription-duration-chip-${cycle.name}',
                        ),
                        onTap: () => viewModel.updateBillingCycle(cycle),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InteractiveInputField(
                key: const ValueKey('subscription-form-start-date'),
                label: 'Start date',
                text: viewModel.startDate == null
                    ? 'mm/dd/yyyy'
                    : _formatInputDate(viewModel.startDate!),
                isFilled: viewModel.startDate != null,
                isActive: _activePickerField == _FormPickerField.startDate,
                errorText: viewModel.startDateError,
                onTap: () => _pickDate(
                  context: context,
                  field: _FormPickerField.startDate,
                  initialDate: viewModel.startDate,
                  onPicked: viewModel.updateStartDate,
                ),
                trailing: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 35),
            Expanded(
              child: _InteractiveInputField(
                key: const ValueKey('subscription-form-next-date'),
                label: 'Enter date',
                text: viewModel.nextBillingDate == null
                    ? 'mm/dd/yyyy'
                    : _formatInputDate(viewModel.nextBillingDate!),
                isFilled: viewModel.nextBillingDate != null,
                isActive:
                    _activePickerField == _FormPickerField.nextBillingDate,
                errorText: viewModel.nextBillingDateError,
                onTap: () => _pickDate(
                  context: context,
                  field: _FormPickerField.nextBillingDate,
                  initialDate: viewModel.nextBillingDate ?? viewModel.startDate,
                  onPicked: viewModel.updateNextBillingDate,
                ),
                trailing: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherInfoSection(
    BuildContext context,
    SubscriptionFormViewModel viewModel,
  ) {
    return Column(
      children: [
        _SubscriptionTextField(
          label: 'Service Provider',
          controller: _serviceProviderController,
          focusNode: _serviceProviderFocusNode,
          hintText: 'Select service provider',
          onChanged: viewModel.updateServiceProvider,
          isExternallyActive:
              _activePickerField == _FormPickerField.serviceProvider,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_websiteFocusNode),
          suffix: InkWell(
            key: const ValueKey('subscription-form-provider-button'),
            onTap: () => _showServiceProviderSheet(context, viewModel),
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SubscriptionTextField(
          label: 'Website (Optional)',
          controller: _websiteController,
          focusNode: _websiteFocusNode,
          hintText: 'e.g example.com',
          onChanged: viewModel.updateWebsite,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_descriptionFocusNode),
        ),
        const SizedBox(height: 16),
        _SubscriptionTextField(
          label: 'Description (Optional)',
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          hintText: 'Write any important note',
          onChanged: viewModel.updateDescription,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

// ignore: camel_case_types
class SubPage_Header extends StatelessWidget {
  const SubPage_Header({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox(
        height: 64,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 24,
              top: 12,
              child: InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(999),
                child: SvgPicture.asset(
                  AppAssets.backIcon,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 20,
                  height: 28 / 20,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
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

class _SubscriptionTextField extends StatelessWidget {
  const _SubscriptionTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.suffix,
    this.isExternallyActive = false,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final bool isExternallyActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, focusNode]),
      builder: (context, child) {
        final hasValue = controller.text.trim().isNotEmpty;
        final hasError = errorText != null;
        final isFocused = focusNode.hasFocus || isExternallyActive;
        final borderColor = hasError
            ? AppColors.error
            : isFocused
            ? AppColors.brandGreen
            : Colors.transparent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.inputLabel),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: borderColor,
                    width: hasError || isFocused ? 1 : 0,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: maxLines > 1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      keyboardType: keyboardType,
                      maxLines: maxLines,
                      minLines: maxLines,
                      textCapitalization: textCapitalization,
                      textInputAction: textInputAction,
                      cursorColor: hasError
                          ? AppColors.error
                          : AppColors.brandGreen,
                      style: AppTextStyles.inputValue.copyWith(
                        color: hasValue
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: hintText,
                        hintStyle: AppTextStyles.inputPlaceholder,
                      ),
                    ),
                  ),
                  if (suffix != null) ...[const SizedBox(width: 12), suffix!],
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: hasError
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(errorText!, style: AppTextStyles.errorText),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _InteractiveInputField extends StatelessWidget {
  const _InteractiveInputField({
    super.key,
    required this.label,
    required this.text,
    required this.isFilled,
    required this.isActive,
    required this.errorText,
    required this.onTap,
    required this.trailing,
  });

  final String label;
  final String text;
  final bool isFilled;
  final bool isActive;
  final String? errorText;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : isActive
        ? AppColors.brandGreen
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.inputLabel),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: borderColor,
                  width: hasError || isActive ? 1 : 0,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.inputValue.copyWith(
                      color: isFilled
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                trailing,
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: hasError
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(errorText!, style: AppTextStyles.errorText),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SelectionChip extends StatelessWidget {
  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.surfaceKey,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Key? surfaceKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(33),
        child: AnimatedContainer(
          key: surfaceKey,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
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
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isBusy,
    required this.isActive,
    required this.onTap,
  });

  final bool isBusy;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? AppColors.brandGreen
        : AppColors.surfaceMuted;
    final foregroundColor = isActive ? Colors.white : AppColors.textSecondary;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          color: const Color(0xB3FFFFFF),
          child: InkWell(
            key: const ValueKey('subscription-form-submit-button'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              key: const ValueKey('subscription-form-submit-surface'),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
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
                            colorFilter: ColorFilter.mode(
                              foregroundColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Add subscription',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w500,
                              color: foregroundColor,
                              letterSpacing: -0.2,
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
  }
}

class _ServiceProviderSheet extends StatelessWidget {
  const _ServiceProviderSheet({
    required this.selectedValue,
    required this.options,
  });

  final String selectedValue;
  final List<_ServiceProviderOption> options;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Material(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 418,
            child: Stack(
              children: [
                Positioned(
                  left: 24,
                  top: 24,
                  child: Text(
                    'Service Provider',
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 20,
                      height: 28 / 20,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppAssets.closeIcon,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
                    child: ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return _ServiceProviderOptionTile(
                          option: option,
                          isSelected:
                              option.label.toLowerCase() ==
                              selectedValue.trim().toLowerCase(),
                          onTap: () => Navigator.of(context).pop(option.label),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceProviderOptionTile extends StatelessWidget {
  const _ServiceProviderOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _ServiceProviderOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('subscription-provider-${option.label.toLowerCase()}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandGreen : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            if (option.assetPath != null)
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: ClipOval(
                  child: Image.asset(
                    option.assetPath!,
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  option.label.substring(0, 1).toUpperCase(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandGreen,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.16,
                ),
              ),
            ),
            if (isSelected)
              SvgPicture.asset(
                AppAssets.checkCircleIcon,
                width: 20,
                height: 20,
              ),
          ],
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
              SvgPicture.asset(
                AppAssets.checkCircleIcon,
                width: 51.26,
                height: 51.26,
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

class _ServiceProviderOption {
  const _ServiceProviderOption({required this.label, this.assetPath});

  final String label;
  final String? assetPath;
}

String _formatInputDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$month/$day/${value.year}';
}
