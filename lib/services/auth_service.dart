import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  
  static String? getUserIdFromToken(String token) {
    if (token.isEmpty) return null;

    try {
      Map<String, dynamic> payload = JwtDecoder.decode(token);
      
      return payload['sub'] as String?;
    } catch (e) {
      print("Erro ao decodificar o token: $e");
      return null;
    }
  }

  static bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }
}