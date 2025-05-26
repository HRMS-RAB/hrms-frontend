/*import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  /// Correct path is /auth/login
  static const String _loginUrl =
      'http://localhost:8082/auth/login';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Avoid FormatException when body is empty
        _errorMessage = res.body.isNotEmpty
            ? (jsonDecode(res.body)['message'] ?? 'Login failed')
            : 'Login failed (${res.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Could not reach server: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}*/

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  bool    _isLoading = false;
  String? _errorMessage;
  String? _token;

  bool   get isLoading    => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token        => _token;

  static const String _loginUrl = 'http://localhost:8082/auth/login';

  Future<bool> login(String email, String password) async {
    _isLoading     = true;
    _errorMessage  = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        // 🔑 MUST be "username", not "email"
        body: jsonEncode({'username': email.trim(), 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _token     = data['token'] as String?;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed (${res.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Could not reach server: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}

