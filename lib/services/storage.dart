// Intellectual property of Strauch Development. All rights reserved.
import 'package:home_widget/home_widget.dart';

/// App Group shared by the Flutter app and the iOS widget extension.
///
/// IMPORTANT: Must match the App Group in both targets' entitlements.
const String appGroupId = 'group.com.aymanstrauch.wordapp';

/// Minimal string key-value persistence, so app logic can be tested without
/// platform channels.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// Stores values in the App Group's shared UserDefaults via `home_widget`,
/// which keeps preferences readable by the widget extension too.
class SharedGroupStore implements KeyValueStore {
  @override
  Future<String?> read(String key) => HomeWidget.getWidgetData<String>(key);

  @override
  Future<void> write(String key, String value) async {
    final saved = await HomeWidget.saveWidgetData<String>(key, value);
    if (saved == false) {
      throw StateError('Failed to save "$key" to shared storage.');
    }
  }
}

/// Non-persistent store for tests.
class InMemoryStore implements KeyValueStore {
  InMemoryStore([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
