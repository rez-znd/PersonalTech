import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:personaltech/dataBase/dartDb.dart';
import 'package:personaltech/models/mensagem_chat.dart'; // Verifique se o caminho está correto

class ChatIA extends StatefulWidget {
  final String idUsuario;
  final String token;

  const ChatIA({super.key, required this.idUsuario, required this.token});

  @override
  State<ChatIA> createState() => _ChatIAState();
}

class _ChatIAState extends State<ChatIA> {
  final TextEditingController _mensagemController = TextEditingController();
  List<MensagemChat> _mensagens = [];
  bool _carregando = true;
  bool _digitandoIA = false;
String instrucaoContexto = """
Você é o assistente virtual do app Personal Tech, focado EXCLUSIVAMENTE em calistenia e saúde.

REGRAS CRÍTICAS:
1. NUNCA responda sobre: História, Astronomia, Geografia, Política, Geologia ou Curiosidades gerais.
2. Se a pergunta não for sobre exercício físico ou dieta, responda algo como: "Sinto muito, mas só posso ajudar com treinos e saúde."
3. Não abra exceções para biologia geral, apenas anatomia humana aplicada ao exercício.
""";
  @override
  void initState() {
    super.initState();
    _carregarMensagens();
  }

  Future<void> _carregarMensagens() async {
    // Usando seu método do DartDB que retorna List<Map<String, dynamic>>
    final dados = await DartDB.instance.buscarMensagens(widget.idUsuario);
    
    setState(() {
      // Convertendo os mapas do banco para instâncias da sua Model
      _mensagens = dados.map((map) => MensagemChat.fromMap(map)).toList();
      _carregando = false;
    });
  }

  Future<void> _enviarMensagem() async {
    String texto = _mensagemController.text.trim();
    if (texto.isEmpty || _digitandoIA) return;

    // 1. Criar objeto da sua Model para o Usuário
    MensagemChat msgUsuario = MensagemChat(
      idUsuario: widget.idUsuario,
      isUser: 1,
      conteudo: texto,
      tipo: 1,
    );

    // 2. Salvar no banco e atualizar tela
    await DartDB.instance.inserirMensagem(msgUsuario.toMap());
    _mensagemController.clear();
    await _carregarMensagens();

    setState(() => _digitandoIA = true);

    try {
      // 3. Chamada à API conforme a imagem
      final response = await http.post(


// No corpo do seu POST para a API:

        Uri.parse('https://mobile-ios-ia.zani0x03.eti.br/api/ai/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
  'prompt': "$instrucaoContexto \n Pergunta do usuário: $texto"
  }),
      );

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);
        
        // 4. Criar objeto da sua Model para a Resposta da IA
        MensagemChat msgIA = MensagemChat(
          idUsuario: widget.idUsuario,
          isUser: 0,
          conteudo: dados['response'] ?? 'Sem resposta da IA',
          tipo: 1,
        );

        await DartDB.instance.inserirMensagem(msgIA.toMap());
      }
    } catch (e) {
      debugPrint("Erro na API: $e");
    } finally {
      if (mounted) {
        setState(() => _digitandoIA = false);
        _carregarMensagens();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Assistente IA', style: TextStyle(color: Colors.blue)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _mensagens.length,
                    itemBuilder: (context, index) {
                      final msg = _mensagens[index];
                      return _construirBalao(msg);
                    },
                  ),
          ),
          if (_digitandoIA)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("IA está digitando...", style: TextStyle(fontStyle: FontStyle.italic)),
            ),
          _construirBarraDigitacao(),
        ],
      ),
    );
  }

  Widget _construirBalao(MensagemChat msg) {
    bool ehUsuario = msg.isUser == 1;
    return Align(
      alignment: ehUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ehUsuario ? Colors.blue[100] : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(msg.conteudo),
      ),
    );
  }

  Widget _construirBarraDigitacao() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mensagemController,
              decoration: const InputDecoration(hintText: 'Pergunte algo...'),
              onSubmitted: (_) => _enviarMensagem(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _enviarMensagem,
          ),
        ],
      ),
    );
  }
}