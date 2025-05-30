// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  bool   _isLoading = false;
  String? _errorMessage;
  String? _token;
  List<String> _roles = [];

  bool   get isLoading     => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token        => _token;
  List<String> get roles   => _roles;
  bool   hasRole(String r) => _roles.contains(r);

  static const _loginUrl   = 'http://localhost:8082/auth/login';
  static const _forgotUrl  = 'http://localhost:8082/auth/password/forgot';
  static const _confirmUrl = 'http://localhost:8082/auth/password/confirm';
  static const _changeUrl  = 'http://localhost:8082/auth/password/change';

  /* ───────── constructor loads saved token ───────── */
  AuthService() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs   = await SharedPreferences.getInstance();
    final saved   = prefs.getString('jwt_token');
    final rolesJs = prefs.getStringList('jwt_roles');

    if (saved != null) {
      _token = saved;
      _roles = rolesJs ?? [];
      notifyListeners();
    }
  }

  Future<void> _persistSession(String token, List<String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setStringList('jwt_roles', roles);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('jwt_roles');
  }

  /* ───────── login ───────── */

  Future<bool> login(String email, String password) async {
    _isLoading = true; _errorMessage = null; notifyListeners();

    try {
      final res = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data   = jsonDecode(res.body);
        _token       = data['token'];
        _roles       = List<String>.from(_decodeJwt(_token!)['roles'] ?? []);
        await _persistSession(_token!, _roles);
        _isLoading   = false; notifyListeners();
        return true;
      }
      _errorMessage = _extractError(res);
    } catch (e) {
      _errorMessage = 'Server error: $e';
    }

    _isLoading = false; notifyListeners(); return false;
  }

  /* ───────── forgot / confirm ───────── */

  Future<bool> forgotPassword(String workEmail) =>
      _simplePost(_forgotUrl, {'workEmail': workEmail});

  Future<bool> confirmPassword(String token, String newPwd) =>
      _simplePost(_confirmUrl, {'token': token, 'newPwd': newPwd});

  /* ───────── change password ───────── */

  Future<bool> changePassword(String currentPwd, String newPwd) async {
    if (_token == null) {
      _errorMessage = 'Not logged in'; notifyListeners(); return false;
    }
    _isLoading = true; _errorMessage = null; notifyListeners();
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
        await logout();                       // force re-login
        _isLoading = false; notifyListeners();
        return true;
      }
      _errorMessage = _extractError(res);
    } catch (e) {
      _errorMessage = 'Server error: $e';
    }
    _isLoading = false; notifyListeners(); return false;
  }

  /* ───────── helpers ───────── */

  Future<bool> _simplePost(String url, Map<String,dynamic> body) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        _isLoading = false; notifyListeners(); return true;
      }
      _errorMessage = _extractError(res);
    } catch (e) {
      _errorMessage = 'Server error: $e';
    }
    _isLoading = false; notifyListeners(); return false;
  }

  String _extractError(http.Response res) {
    try { return jsonDecode(res.body)['message'] ?? 'Error ${res.statusCode}'; }
    catch (_) { return 'Error ${res.statusCode}'; }
  }

  Map<String,dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = base64.normalize(parts[1]);
    return json.decode(utf8.decode(base64Url.decode(payload)));
  }

  Future<void> logout() async {
    _token = null;
    _roles = [];
    await _clearSession();
    notifyListeners();
  }
}







/*
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

*/

