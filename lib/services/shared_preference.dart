import 'package:flutter/material.dart';
import 'package:hadieaty/services/sqlite_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class PreferencesService extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = value;
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = value;
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }
}
