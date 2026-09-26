import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Map<String, dynamic>? _user;
  bool _loading = true;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;

  AuthProvider() {
    _restaurerSession();
  }

  Future<void> _restaurerSession() async {
    try {
      if (await _api.isAuthenticated) {
        _user = await _api.me();
      }
    } catch (_) {
      try {
        await _api.clearToken();
      } catch (_) {
        // Stockage sécurisé indisponible (ex: environnement de test) : on
        // reste simplement déconnecté plutôt que de faire planter l'app.
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> connexion(String email, String password) async {
    final data = await _api.login(email, password);
    _user = data['user'];
    notifyListeners();
  }

  Future<void> inscription({
    required String name,
    required String email,
    required String password,
    String? telephone,
  }) async {
    final data = await _api.register(
      name: name,
      email: email,
      password: password,
      telephone: telephone,
    );
    _user = data['user'];
    notifyListeners();
  }

  Future<void> deconnexion() async {
    await _api.logout();
    _user = null;
    notifyListeners();
  }
}
