import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/records/domain/health_record.dart';
import 'features/records/presentation/health_view_model.dart';
import 'features/records/presentation/history_screen.dart';
import 'features/records/presentation/record_form.dart';

class HealthMateApp extends StatefulWidget {
  const HealthMateApp({required this.viewModel, super.key});
  final HealthViewModel viewModel;
  @override
  State<HealthMateApp> createState() => _HealthMateAppState();
}

class _HealthMateAppState extends State<HealthMateApp> {
  bool _dark = false;
  bool _themeReady = false;
  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    unawaited(_loadThemePreference());
  }

  Future<void> _loadThemePreference() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedDarkMode = preferences.getBool('dark_mode');
      if (mounted) {
        setState(() {
          _preferences = preferences;
          _dark = savedDarkMode ?? false;
          _themeReady = true;
        });
      }
    } on PlatformException catch (error, stackTrace) {
      _reportThemePreferenceError(error, stackTrace, 'loading');
      if (mounted) setState(() => _themeReady = true);
    } on MissingPluginException catch (error, stackTrace) {
      _reportThemePreferenceError(error, stackTrace, 'loading');
      if (mounted) setState(() => _themeReady = true);
    }
  }

  Future<void> _toggleTheme() async {
    final preferences = _preferences;
    if (!_themeReady || preferences == null) return;
    final nextDarkMode = !_dark;
    try {
      await preferences.setBool('dark_mode', nextDarkMode);
    } on PlatformException catch (error, stackTrace) {
      _reportThemePreferenceError(error, stackTrace, 'saving');
      if (mounted) feedbackMessage(context, 'Could not save your theme preference.');
      return;
    } on MissingPluginException catch (error, stackTrace) {
      _reportThemePreferenceError(error, stackTrace, 'saving');
      if (mounted) feedbackMessage(context, 'Could not save your theme preference.');
      return;
    }
    if (mounted) setState(() => _dark = nextDarkMode);
  }

  void _reportThemePreferenceError(Object error, StackTrace stackTrace, String action) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'healthmate',
        context: ErrorDescription('while $action the theme preference'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: widget.viewModel,
    child: MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      darkTheme: appTheme(brightness: Brightness.dark),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: _HomeScreen(dark: _dark, themeReady: _themeReady, onToggleTheme: _toggleTheme),
    ),
  );
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen({required this.dark, required this.themeReady, required this.onToggleTheme});
  final bool dark;
  final bool themeReady;
  final Future<void> Function() onToggleTheme;
  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> with WidgetsBindingObserver {
  int _tab = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) context.read<HealthViewModel>().refreshDate();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HealthViewModel>().refreshDate();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _edit([HealthRecord? record]) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => RecordForm(record: record)));
  Future<void> _delete(HealthRecord record) async {
    final vm = context.read<HealthViewModel>();
    if (vm.busy) return;
    if (!await confirm(
      context,
      title: 'Delete record?',
      message: 'This record will be permanently deleted.',
      action: 'Delete',
    )) {
      return;
    }
    final success = await vm.delete(record);
    if (mounted) {
      feedbackMessage(context, success ? 'Record deleted.' : vm.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.spa_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 11),
            const Flexible(
              child: Text(
                'HealthMate',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -.5),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('theme-toggle'),
            tooltip: widget.dark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: widget.themeReady ? widget.onToggleTheme : null,
            icon: Icon(widget.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : !vm.ready
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: EmptyState(
                  title: 'Unable to load records',
                  message: vm.error ?? 'Please try again.',
                  action: FilledButton(onPressed: vm.initialize, child: const Text('Retry')),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: IndexedStack(
                    index: _tab,
                    children: [
                      const DashboardScreen(),
                      HistoryScreen(onAdd: _edit, onEdit: _edit, onDelete: _delete),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: vm.ready
          ? FloatingActionButton.extended(
              onPressed: vm.busy ? null : _edit,
              icon: const Icon(Icons.add),
              label: const Text('Add record'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
