import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static bool isLogin = false;

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse("http://192.168.26.112:8000/api/login");
    // ⚠️ GANTI dengan IP laptop kamu

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      isLogin = true;
      return data;
    } else {
      throw Exception(data['message'] ?? "Login gagal");
    }
  }
}
