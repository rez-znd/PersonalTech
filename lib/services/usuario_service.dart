import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioService {
  static const String baseUrl = 'https://mobile-ios-login.zani0x03.eti.br/api';
  static const String sistemaId = '84f35fde-e69e-487d-b837-1c5f80828f0b';

  static Future<bool> registrar({
    required String name,
    required String surname,
    required String login,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'surname': surname,
          'login': login, 
          'email': email,
          'password': password,
          'sistemaId': sistemaId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Cadastro realizado com sucesso na nuvem!');
        return true; 
} else {
        print('ERRO NA API! Código: ${response.statusCode} | Resposta: ${response.body}');
        return false; 
      }
    } catch (e) {
      print('Erro de conexão com a internet: $e');
      return false; 
    }
  }

static Future<String?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'sistemaId': sistemaId,
        }),
      );

      if (response.statusCode == 200) {
        print('Login aprovado pela API!');

        final Map<String, dynamic> dados = jsonDecode(response.body);
        String token = dados['access_token']; 
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        return token;
        
      } else {
        print('Credenciais inválidas: ${response.body}');
        return null; 
      }
    } catch (e) {
      print('Erro de conexão com a internet: $e');
      return null; 
    }
  }
}