import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/repositories/settings_repository.dart';
import '../viewmodels/app_preferences_controller.dart';
import '../viewmodels/import_existing_profile_view_model.dart';

Future<void> showImportExistingProfileSheet(
  BuildContext context, {
  VoidCallback? onImported,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlayScrim,
    isScrollControlled: true,
    builder: (context) {
      return ChangeNotifierProvider(
        create: (_) => ImportExistingProfileViewModel(
          settingsRepository: context.read<SettingsRepository>(),
        ),
        child: _CenteredBottomOverlay(
          child: _ImportExistingProfileSheet(onImported: onImported),
        ),
      );
    },
  );
}

class _CenteredBottomOverlay extends StatelessWidget {
  const _CenteredBottomOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: child,
      ),
    );
  }
}

class _ImportExistingProfileSheet extends StatelessWidget {
  const _ImportExistingProfileSheet({this.onImported});

  final VoidCallback? onImported;

  Future<void> _handleFileImport(BuildContext context) async {
    final importViewModel = context.read<ImportExistingProfileViewModel>();
    final preferencesController = context.read<AppPreferencesController>();

    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['db'],
      allowMultiple: false,
    );
    final path = pickerResult?.files.single.path;
    if (path == null) {
      return;
    }

    final result = await importViewModel.importFromFile(path);
    if (!context.mounted) {
      return;
    }

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Import failed.')),
      );
      return;
    }

    await preferencesController.reload();
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup imported successfully.')),
    );
    onImported?.call();
  }

  void _showNotReadyMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ImportExistingProfileViewModel>();
    return Material(
      color: AppColors.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        key: const Key('import-existing-profile-sheet'),
        width: double.infinity,
        height: 533,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16.5, 24, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.36),
                      child: Text(
                        'Import existing profile',
                        style: AppTextStyles.sheetTitle,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      AppAssets.closeIcon,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17.5),
              _ImportOptionCard(
                height: 209,
                iconAssetPath: AppAssets.importIcon,
                title: 'Import from file',
                description: 'Select export file from device',
                isBusy: viewModel.isBusy,
                onTap: viewModel.isBusy
                    ? null
                    : () => _handleFileImport(context),
              ),
              const SizedBox(height: 15),
              _ImportOptionCard(
                height: 210,
                iconAssetPath: AppAssets.scanQrIcon,
                title: 'Scan QR',
                description:
                    'Go to setting on old device and select migrate with QR',
                descriptionWidth: 230,
                isBusy: false,
                onTap: () => _showNotReadyMessage(
                  context,
                  'QR migration is not available in this build yet.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportOptionCard extends StatelessWidget {
  const _ImportOptionCard({
    required this.height,
    required this.iconAssetPath,
    required this.title,
    required this.description,
    required this.onTap,
    required this.isBusy,
    this.descriptionWidth,
  });

  final double height;
  final String iconAssetPath;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isBusy;
  final double? descriptionWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isBusy)
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(),
                  )
                else
                  SvgPicture.asset(iconAssetPath, width: 56, height: 56),
                const SizedBox(height: 17),
                Text(
                  title,
                  style: AppTextStyles.optionTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: SizedBox(
                    width: descriptionWidth,
                    child: Text(
                      description,
                      style: AppTextStyles.optionDescription,
                      textAlign: TextAlign.center,
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
