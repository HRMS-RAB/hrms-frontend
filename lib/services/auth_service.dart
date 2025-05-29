// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Utility to decode a JWT's payload
Map<String, dynamic> _decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return {};
  final payload = base64.normalize(parts[1]);
  final decoded = utf8.decode(base64Url.decode(payload));
  return json.decode(decoded);
}

class AuthService with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  List<String> _roles = [];

  bool get isLoading     => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token      => _token;
  List<String> get roles => _roles;

  /// Returns true if the current user has the given role
  bool hasRole(String role) => _roles.contains(role);

  static const _loginUrl   = 'http://localhost:8082/auth/login';
  static const _forgotUrl  = 'http://localhost:8082/auth/password/forgot';
  static const _confirmUrl = 'http://localhost:8082/auth/password/confirm';
  static const _changeUrl  = 'http://localhost:8082/auth/password/change';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];
        final decoded = _decodeJwt(_token!);
        _roles = List<String>.from(decoded['roles'] ?? []);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _extractError(res);
      }
    } catch (e) {
      _errorMessage = 'Could not reach server: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> forgotPassword(String workEmail) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await http.post(
        Uri.parse(_forgotUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'workEmail': workEmail}),
      );
      if (res.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _extractError(res);
      }
    } catch (e) {
      _errorMessage = 'Could not reach server: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> confirmPassword(String token, String newPwd) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await http.post(
        Uri.parse(_confirmUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'newPwd': newPwd}),
      );
      if (res.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _extractError(res);
      }
    } catch (e) {
      _errorMessage = 'Could not reach server: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> changePassword(String currentPwd, String newPwd) async {
    if (_token == null) {
      _errorMessage = 'Not logged in';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await http.post(
        Uri.parse(_changeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'currentPwd': currentPwd, 'newPwd': newPwd}),
      );
      if (res.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _extractError(res);
      }
    } catch (e) {
      _errorMessage = 'Could not reach server: $e';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  String _extractError(http.Response res) {
    try {
      final m = jsonDecode(res.body)['message'];
      return m ?? 'Error ${res.statusCode}';
    } catch (_) {
      return 'Error ${res.statusCode}';
    }
  }

  void logout() {
    _token = null;
    _roles = [];
    notifyListeners();
  }
}






/*
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Utility to decode JWT payload
Map<String, dynamic> _decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return {};
  final payload = base64.normalize(parts[1]);
  final decoded = utf8.decode(base64Url.decode(payload));
  return json.decode(decoded);
}

class AuthService with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  List<String> _roles = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  List<String> get roles => _roles;

  bool hasRole(String role) => _roles.contains(role);

  static const String _loginUrl       = 'http://localhost:8082/auth/login';
  static const String _forgotPwdUrl   = 'http://localhost:8082/auth/password/forgot';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];

        final decoded = _decodeJwt(_token!);
        _roles = List<String>.from(decoded['roles'] ?? []);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
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

  /// ─────────────── NEW ───────────────
  Future<bool> forgotPassword(String workEmail) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(_forgotPwdUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'workEmail': workEmail}),
      );

      if (res.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.body.isNotEmpty
            ? (jsonDecode(res.body)['message'] ?? 'Request failed')
            : 'Error ${res.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Could not reach server: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
  /// ────────────────────────────────────

  void logout() {
    _token = null;
    _roles = [];
    notifyListeners();
  }
}


*/