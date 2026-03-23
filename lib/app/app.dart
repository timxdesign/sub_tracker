import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'di/providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class SubTrackerApp extends StatefulWidget {
  const SubTrackerApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<SubTrackerApp> createState() => _SubTrackerAppState();
}

class _SubTrackerAppState extends State<SubTrackerApp>
    with WidgetsBindingObserver {
  late final GoRouter _router = createAppRouter(widget.dependencies);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    widget.dependencies.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.dependencies.flushPendingSyncs());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      dependencies: widget.dependencies,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Subscription Tracker',
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
