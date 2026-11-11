import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/data/health_database.dart';
import 'features/records/data/health_repository.dart';
import 'features/records/presentation/health_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setPrefix('', allowList: const {'dark_mode'});
  final viewModel = HealthViewModel(SqliteHealthRepository(HealthDatabase()));
  runApp(HealthMateApp(viewModel: viewModel));
  unawaited(viewModel.initialize());
}
