// services/setting_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _difficultyKey = 'difficulty';

  String _difficulty = 'normal';
  bool _isInitialized = false;

  SettingsService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSettings();
    _isInitialized = true;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _difficulty = prefs.getString(_difficultyKey) ?? 'normal';
  }

  // Use this getter to ensure settings are loaded
  Future<String> get difficulty async {
    if (!_isInitialized) {
      await _initialize();
    }
    return _difficulty;
  }

  Future<void> setDifficulty(String difficulty) async {
    _difficulty = difficulty;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_difficultyKey, difficulty);
  }

  Future<void> resetToDefaults() async {
    await setDifficulty('normal');
  }
  bool get isInitialized => _isInitialized;

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
  }

  String get difficultySync {
    if (!_isInitialized) {
      return 'normal'; // Default until initialized
    }
    return _difficulty;
  }
}
