import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';           // so we can read the token

class PasswordService {
  static const _base = 'http://localhost:8082/auth/password';

  /// Change while logged in
  static Future<void> change(
      String currentPwd, String newPwd, AuthService auth) async {
    final res = await http.post(
      Uri.parse('$_base/change'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
      },
      body: jsonEncode({
        'currentPwd': currentPwd,
        'newPwd': newPwd,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Change password failed: ${res.body}');
    }
  }

  /// Forgot – request e-mail with token
  static Future<void> forgot(String email) async {
    final res = await http.post(
      Uri.parse('$_base/forgot'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode != 200) {
      throw Exception('Forgot-password failed: ${res.body}');
    }
  }

  /// Confirm – supply token & new pwd
  static Future<void> confirm(String token, String newPwd) async {
    final res = await http.post(
      Uri.parse('$_base/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'newPwd': newPwd}),
    );
    if (res.statusCode != 200) {
      throw Exception('Reset confirmation failed: ${res.body}');
    }
  }
}
