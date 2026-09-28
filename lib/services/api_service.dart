import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Exception levée quand l'API répond avec une erreur métier (4xx/5xx).
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, this.statusCode, {this.errors});

  @override
  String toString() => message;
}

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  /// Serveur de production (Render.com) — accessible depuis n'importe quel
  /// téléphone, n'importe où, sans dépendre du réseau local de développement.
  static const String _productionUrl = 'https://concours-pro.onrender.com/api';

  /// Pour développer en local à la place (réseau Wi-Fi partagé avec la
  /// machine de dev), remplacez _productionUrl par 'http://IP-locale/api'
  /// (trouvable avec `ipconfig`), ou 'http://10.0.2.2/api' pour un émulateur Android.
  static String get baseUrl => _productionUrl;

  Future<String?> get _token async => _storage.read(key: _tokenKey);

  Future<void> _saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _token;
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    Map<String, dynamic>? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = null;
    }

    final message = body?['message'] ?? 'Une erreur est survenue.';
    final errors = body?['errors'] as Map<String, dynamic>?;

    throw ApiException(message, response.statusCode, errors: errors);
  }

  // --- Authentification ---

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String dateNaissance,
    String? telephone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'date_naissance': dateNaissance,
        if (telephone != null) 'telephone': telephone,
      }),
    );

    final data = _decode(response);
    await _saveToken(data['token']);
    return data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decode(response);
    await _saveToken(data['token']);
    return data;
  }

  Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/logout'), headers: await _headers());
    } finally {
      await clearToken();
    }
  }

  Future<bool> get isAuthenticated async => (await _token) != null;

  Future<Map<String, dynamic>> me() async {
    final response = await http.get(Uri.parse('$baseUrl/me'), headers: await _headers());
    return _decode(response);
  }

  // --- Concours ---

  Future<List<dynamic>> concoursOuverts() async {
    final response = await http.get(Uri.parse('$baseUrl/concours'), headers: await _headers());
    return _decode(response);
  }

  // --- Candidatures ---

  Future<List<dynamic>> mesCandidatures() async {
    final response = await http.get(Uri.parse('$baseUrl/candidatures'), headers: await _headers());
    return _decode(response);
  }

  Future<Map<String, dynamic>> candidature(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/candidatures/$id'), headers: await _headers());
    return _decode(response);
  }

  Future<Map<String, dynamic>> creerCandidature({
    required int concoursId,
    required String diplomeCandidat,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/candidatures'),
      headers: await _headers(),
      body: jsonEncode({'concours_id': concoursId, 'diplome_candidat': diplomeCandidat}),
    );
    return _decode(response);
  }

  // --- Paiements ---

  Future<Map<String, dynamic>> payer({
    required int candidatureId,
    required String type,
    required String numeroTelephone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/candidatures/$candidatureId/paiements'),
      headers: await _headers(),
      body: jsonEncode({'type': type, 'numero_telephone': numeroTelephone}),
    );
    return _decode(response);
  }

  // --- Documents ---

  Future<Map<String, dynamic>> deposerDocument({
    required int candidatureId,
    required String type,
    required List<int> fichierBytes,
    required String nomFichier,
  }) async {
    final token = await _token;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/candidatures/$candidatureId/documents'),
    )
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['type'] = type
      ..files.add(http.MultipartFile.fromBytes('fichier', fichierBytes, filename: nomFichier));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  // --- PDF (retourne les octets bruts) ---

  Future<List<int>> telechargerConvocation(int candidatureId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/candidatures/$candidatureId/convocation'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) _decode(response);
    return response.bodyBytes;
  }

  Future<List<int>> telechargerFiche(int candidatureId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/candidatures/$candidatureId/fiche'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) _decode(response);
    return response.bodyBytes;
  }

  Future<List<int>> telechargerRecu(int paiementId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/paiements/$paiementId/recu'),
      headers: await _headers(json: false),
    );
    if (response.statusCode != 200) _decode(response);
    return response.bodyBytes;
  }
}
