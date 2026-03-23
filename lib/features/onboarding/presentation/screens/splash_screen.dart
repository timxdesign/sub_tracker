import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../viewmodels/splash_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _logoStartScale = 0.526600717097639;

  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: _logoStartScale, end: 1).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutCubic),
      );

  @override
  void initState() {
    super.initState();
    unawaited(_playSequence());
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _playSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) {
      return;
    }

    await _scaleController.forward();
    if (!mounted) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) {
      return;
    }

    final nextRoute = await context.read<SplashViewModel>().resolveNextRoute();
    if (!mounted) {
      return;
    }

    context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: PhoneViewport(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final frameWidth = math.min(constraints.maxWidth, 390.0);
            final logoWidth = frameWidth * 0.50353749593099;

            return Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SvgPicture.asset(
                  AppAssets.logo,
                  key: const Key('start-screen-logo'),
                  width: logoWidth,
                  semanticsLabel: 'SubTracker logo',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
