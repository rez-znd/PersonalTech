import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  static const String baseUrl = 'https://mobile-ios-login.zani0x03.eti.br/api';
  static const String sistemaId = 'd7f0beee-ac36-4cdf-8dba-7c752ace6ec6';

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
          'username': login, 
          'email': email,
          'password': password,
          'sistema_id': sistemaId,
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

  static Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'sistema_id': sistemaId,
        }),
      );

      if (response.statusCode == 200) {
        print('Login aprovado pela API!');
        return true; 
      } else {
        print('Credenciais inválidas: ${response.body}');
        return false; 
      }
    } catch (e) {
      print('Erro de conexão com a internet: $e');
      return false; 
    }
  }
}