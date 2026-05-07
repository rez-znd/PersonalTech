import 'package:flutter/material.dart';
import 'dataBase/dartDb.dart'; 

class TelaEdicao extends StatefulWidget {
  final String nomeDoDia;
  final int idDiaSemana; 
  final String idUsuario;   

  const TelaEdicao({
    super.key, 
    required this.nomeDoDia,
    required this.idDiaSemana,
    required this.idUsuario,
  });

  @override
  State<TelaEdicao> createState() => _TelaEdicaoState();
}

class _TelaEdicaoState extends State<TelaEdicao> {
  List<Map<String, dynamic>> _exercicios = [];
  bool _carregando = true;

  final List<TextEditingController> _nomeControllers = [];
  final List<TextEditingController> _seriesControllers = [];
  final List<TextEditingController> _repsControllers = [];

  @override
  void initState() {
    super.initState();
    _carregarExerciciosDoBanco();
  }

  @override
  void dispose() {
    _limparControllers();
    super.dispose();
  }

  void _limparControllers() {
    for (var c in _nomeControllers) { c.dispose(); }
    for (var c in _seriesControllers) { c.dispose(); }
    for (var c in _repsControllers) { c.dispose(); }
    _nomeControllers.clear();
    _seriesControllers.clear();
    _repsControllers.clear();
  }

  Future<void> _carregarExerciciosDoBanco() async {
    final dados = await DartDB.instance.buscarTreinosPorDia(widget.idUsuario, widget.idDiaSemana);
    
    setState(() {
      _exercicios = dados.map((e) => Map<String, dynamic>.from(e)).toList();
      
      _limparControllers(); 

      for (var ex in _exercicios) {
        _nomeControllers.add(TextEditingController(text: ex['Exercicio']?.toString() ?? ''));
        _seriesControllers.add(TextEditingController(text: ex['Series']?.toString() ?? ''));
        _repsControllers.add(TextEditingController(text: ex['Repeticoes']?.toString() ?? ''));
      }
      
      _carregando = false;
    });
  }

  Future<void> _adicionarExercicioVazio() async {
    Map<String, dynamic> novoTreino = {
      'IdUsuario': widget.idUsuario,
      'IdDiaSemana': widget.idDiaSemana,
      'Exercicio': '',
      'Series': '',
      'Repeticoes': '',
      'Concluido': 0,
    };
    
    int idInserido = await DartDB.instance.inserirTreino(novoTreino);
    novoTreino['Id'] = idInserido; 

    setState(() {
      _exercicios.add(novoTreino);
      _nomeControllers.add(TextEditingController(text: ''));
      _seriesControllers.add(TextEditingController(text: ''));
      _repsControllers.add(TextEditingController(text: ''));
    });
  }

  Future<void> _deletarExercicio(int index) async {
    int idDoBanco = _exercicios[index]['Id'];
    
    await DartDB.instance.deletarTreino(idDoBanco);
    
    setState(() {
      _exercicios.removeAt(index);
      
      _nomeControllers[index].dispose();
      _seriesControllers[index].dispose();
      _repsControllers[index].dispose();
      
      _nomeControllers.removeAt(index);
      _seriesControllers.removeAt(index);
      _repsControllers.removeAt(index);
    });
  }

  Future<void> _salvarTudo() async {
    for (int i = 0; i < _exercicios.length; i++) {
      _exercicios[i]['Exercicio'] = _nomeControllers[i].text;
      _exercicios[i]['Series'] = _seriesControllers[i].text;
      _exercicios[i]['Repeticoes'] = _repsControllers[i].text;
      
      await DartDB.instance.atualizarTreino(_exercicios[i]);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treinos salvos no banco de dados!')),
      );
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.nomeDoDia,
          style: const TextStyle(
            color: Color(0xFF295AF5),
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: false,
      ),
      body: _carregando 
          ? const Center(child: CircularProgressIndicator()) 
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _exercicios.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _construirCardExercicio(index),
                        );
                      },
                    ),
                  ),
                  _construirBotaoAdicionar(),
                  const SizedBox(height: 16),
                  _construirBotaoSalvar(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _construirCardExercicio(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _construirCampoTexto(
              _nomeControllers[index],
              dica: 'Ex: Supino',
            ), 
          ),
          const SizedBox(width: 8),
          _construirCampoTexto(
            _seriesControllers[index],
            dica: 'Sér', 
            largura: 50, 
            centralizar: true, 
            tecladoNumerico: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('x', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          _construirCampoTexto(
            _repsControllers[index],
            dica: 'Rep', 
            largura: 50, 
            centralizar: true, 
            tecladoNumerico: true,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _deletarExercicio(index), 
          ),
        ],
      ),
    );
  }

  Widget _construirCampoTexto(TextEditingController controller, {String? dica, double? largura, bool centralizar = false, bool tecladoNumerico = false}) {
    return Container(
      width: largura,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller, // Vinculando o controlador
        textAlign: centralizar ? TextAlign.center : TextAlign.left,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        keyboardType: tecladoNumerico ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: dica,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _construirBotaoAdicionar() {
    return OutlinedButton(
      onPressed: _adicionarExercicioVazio,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Colors.black87),
          SizedBox(width: 8),
          Text('Adicionar exercício', style: TextStyle(color: Colors.black87, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _construirBotaoSalvar() {
    return ElevatedButton(
      onPressed: _salvarTudo,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF295AF5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: const Text('Salvar', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}