// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import 'app_controller.dart';
import 'app_scope.dart';
import 'screens/journal_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/today_screen.dart';
import 'services/notification_service.dart';
import 'services/storage.dart';
import 'services/widget_sync_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  try {
    await HomeWidget.setAppGroupId(appGroupId);
  } catch (error) {
    debugPrint('Could not set App Group: $error');
  }

  runApp(
    WordApp(
      controller: AppController(
        store: SharedGroupStore(),
        widgetSync: HomeWidgetSyncService(),
        notifications: NativeNotificationService(),
      ),
    ),
  );
}

/// Root widget: owns the controller's lifecycle and applies the theme.
class WordApp extends StatefulWidget {
  const WordApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<WordApp> createState() => _WordAppState();
}

class _WordAppState extends State<WordApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.refreshIfNewDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      child: MaterialApp(
        title: 'Word of the Day',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeShell(),
      ),
    );
  }
}

/// Bottom-navigation shell holding the three main tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return Scaffold(
      body: ForestBackground(
        child: SafeArea(
          bottom: false,
          child: !controller.isReady
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _index,
                  children: [
                    TodayScreen(
                      onOpenSettings: () => setState(() => _index = 2),
                    ),
                    const JournalScreen(),
                    const SettingsScreen(),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_twilight_outlined),
            selectedIcon: Icon(Icons.wb_twilight),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
