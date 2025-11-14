import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  String? uid;
  String? displayName;
  String? email;
  bool isVip = false;
  String? targetLanguageCode;
  String difficulty = "beginner";

  bool _ready = false;
  bool get isReady => _ready;

  List<String> _favorites = [];
  List<String> get favorites => _favorites;

  AppState() {
    initialize();
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    targetLanguageCode = prefs.getString("target_language");
    difficulty = prefs.getString("difficulty") ?? "beginner";
    _favorites = prefs.getStringList("favorites") ?? [];

    final user = await AuthService.getCurrentUser();
    if (user != null) {
      uid = user["uid"];
      displayName = user["name"];
      email = user["email"];
      isVip = user["isVip"] ?? false;
    }

    _ready = true;
    notifyListeners();
  }

  bool get isLoggedIn => uid != null;

  Future<void> setLanguage(String code) async {
    targetLanguageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("target_language", code);
    notifyListeners();
  }

  Future<void> setDifficulty(String d) async {
    difficulty = d;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("difficulty", d);
    notifyListeners();
  }

  bool isFavorite(String phrase) {
    return _favorites.contains(phrase);
  }

  Future<void> addFavorite(String phrase) async {
    if (!_favorites.contains(phrase)) {
      _favorites.add(phrase);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList("favorites", _favorites);
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String phrase) async {
    _favorites.remove(phrase);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("favorites", _favorites);
    notifyListeners();
  }

  Future<bool> login(String email, String password, {String? name}) async {
    try {
      final data = await AuthService.login(email, password);
      if (data == null) return false;

      uid = data["uid"];
      this.email = data["email"];
      displayName = data["name"];
      isVip = data["isVip"] ?? false;

      if (name != null && name.trim().isNotEmpty) {
        await AuthService.updateUserName(uid!, name.trim());
        displayName = name.trim();
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      final ok = await AuthService.signUp(name, email, password);
      if (ok) {
        final data = await AuthService.getCurrentUser();
        uid = data?["uid"];
        this.email = data?["email"];
        displayName = name;
        isVip = data?["isVip"] ?? false;
      }
      notifyListeners();
      return ok;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    uid = null;
    displayName = null;
    email = null;
    isVip = false;
    notifyListeners();
  }

  Future<void> updateProfileName(String name) async {
    if (uid != null) {
      await AuthService.updateUserName(uid!, name);
      displayName = name;
      notifyListeners();
    }
  }
}
