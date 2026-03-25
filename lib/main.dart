import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/di/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final dependencies = await buildAppDependencies(
    preferences: preferences,
    httpClient: http.Client(),
  );
  dependencies.startBackgroundWork();

  runApp(SubTrackerApp(dependencies: dependencies));
}
