import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personaltech/dataBase/dartDb.dart';

class ChatService {
  final String _baseUrl = "https://mobile-ios-ia.zani0x03.eti.br/api/ai/chat";

  Future<String?> perguntarIA(String prompt, String token) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String?; 
      }
      return "Erro ao processar resposta da IA.";
    } catch (e) {
      return "Erro de conexão com a IA.";
    }
  }

  Future<void> salvarMensagemLocal(String userId, String conteudo, bool isUser) async {
    Map<String, dynamic> novaMensagem = {
      'IdUsuario': userId,
      'IsUser': isUser ? 1 : 0,
      'Conteudo': conteudo,
      'Tipo': 1,
    };
    await DartDB.instance.inserirMensagem(novaMensagem);
  }
}