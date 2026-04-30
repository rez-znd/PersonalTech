import 'package:flutter/material.dart';
import 'dataBase/dartDb.dart';

class ChatIA extends StatefulWidget {
  final int idUsuario;

  const ChatIA({super.key, required this.idUsuario});

  @override
  State<ChatIA> createState() => _ChatIAState();
}

class _ChatIAState extends State<ChatIA> {
  final TextEditingController _mensagemController = TextEditingController();
  List<Map<String, dynamic>> _mensagens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
  }

  Future<void> _carregarMensagens() async {
    final dados = await DartDB.instance.buscarMensagens(widget.idUsuario);
    setState(() {
      _mensagens = dados;
      _carregando = false;
    });
  }

  Future<void> _enviarMensagem() async {
    String texto = _mensagemController.text.trim();
    if (texto.isEmpty) return;

    Map<String, dynamic> novaMensagem = {
      'IdUsuario': widget.idUsuario,
      'IsUser': 1,
      'Conteudo': texto,
      'Tipo': 1,
    };

    await DartDB.instance.inserirMensagem(novaMensagem);
    
    _mensagemController.clear();
    _carregarMensagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Assistente IA',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              children: [
                Expanded(
                  child: _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _mensagens.length + 1, 
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _construirBalaoIA(
                                'Olá! Sou o assistente do Personal Tech 💪\n\n'
                                'Posso te ajudar com:\n'
                                'Sugestões de treinos\n'
                                'Dicas de execução\n'
                                'Informações sobre exercícios\n\n'
                                'Como posso te ajudar?'
                              );
                            }
                            
                            final msg = _mensagens[index - 1];
                            final isUser = msg['IsUser'] == 1;

                            return isUser 
                                ? _construirBalaoUsuario(msg['Conteudo']) 
                                : _construirBalaoIA(msg['Conteudo']);
                          },
                        ),
                ),
                _construirBarraDigitacao(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirBalaoIA(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(texto, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _construirBalaoUsuario(String texto) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(texto, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _construirBarraDigitacao() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.transparent,
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.black54),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _mensagemController,
                decoration: const InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _enviarMensagem(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _enviarMensagem,
            ),
          ),
        ],
      ),
    );
  }
}