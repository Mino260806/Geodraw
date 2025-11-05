import 'dart:html';

import 'package:get_storage/get_storage.dart';

class StorageManager {
  static StorageManager? _instance;
  factory StorageManager() => _instance ??= StorageManager._();
  StorageManager._();

  late final GetStorage drawings;
  late final GetStorage appState;

  init() async {
    await GetStorage.init();
    drawings = GetStorage();
    appState = GetStorage("app_state");
  }

  void setLastOpened(String? name) {
    name ??= "";
    appState.write("last_opened", name);
  }

  String? getLastOpened() {
    String? name = appState.read("last_opened") as String?;
    return name?.isNotEmpty == true? name: null;
  }
}