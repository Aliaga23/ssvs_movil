import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = 'https://ssvsbackend-production.up.railway.app/auth/login';
  final String _tokenKey = 'auth_token';

  // Method to log in and save the token
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final token = responseData['token'];
        await setToken(token); // Save the token
        return token;
      } else {
        print("Error en el inicio de sesión: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return null;
    }
  }

  // Method to save the token to shared preferences
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Method to retrieve the token from shared preferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Method to clear the token (for logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
