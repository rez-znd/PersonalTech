import 'package:flutter/material.dart';
import 'package:personaltech/chatIA.dart';
import 'tela_edicao.dart';
import 'dataBase/dartDb.dart';
import 'package:personaltech/main.dart';

class Exercicio {
  int id; 
  String nome;
  String series;
  bool concluido;

  Exercicio({required this.id, required this.nome, required this.series, this.concluido = false});
}

class TreinoDia {
  int idDia; 
  String dia;
  Color cor;
  List<Exercicio> exercicios;

  TreinoDia({required this.idDia, required this.dia, required this.cor, required this.exercicios});
}

class MeusTreinos extends StatefulWidget {
  final String idUsuario;
  final String token;

  const MeusTreinos({super.key, required this.idUsuario, required this.token});

  @override
  State<MeusTreinos> createState() => _MeusTreinosState();
}

class _MeusTreinosState extends State<MeusTreinos> {
  bool loading = true;
  List<TreinoDia> meusTreinos = [];

  final Map<int, Color> coresDosDias = {
    1: Colors.grey,
    2: Colors.blue,
    3: Colors.green,
    4: Colors.orange,
    5: Colors.purple,
    6: Colors.red, 
    7: Colors.teal,
  };

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final result = await DartDB.instance.buscarTodosOsDiasComTreinos(widget.idUsuario);

    Map<int, TreinoDia> diasMap = {};

    for (var row in result) {
      int diaId = row['DiaId'];
      String nomeDia = row['Dia'];

      if (!diasMap.containsKey(diaId)) {
        diasMap[diaId] = TreinoDia(
          idDia: diaId,
          dia: nomeDia,
          cor: coresDosDias[diaId] ?? Colors.blue,
          exercicios: [],
        );
      }

      if (row['TreinoId'] != null) {
        diasMap[diaId]!.exercicios.add(Exercicio(
          id: row['TreinoId'],
          nome: row['Exercicio'],
          series: "${row['Series'] ?? ''} ${row['Repeticoes'] != null ? 'x ${row['Repeticoes']}' : ''}",
          concluido: row['Concluido'] == 1, 
        ));
      }
    }

    setState(() {
      meusTreinos = diasMap.values.toList();
      loading = false;
    });
  }

  Future<void> alternarStatusTreino(Exercicio exercicio, bool novoStatus) async {
    setState(() {
      exercicio.concluido = novoStatus;
    });
    
    final db = await DartDB.instance.database;
    await db.update(
      'Treino',
      {'Concluido': novoStatus ? 1 : 0},
      where: 'Id = ?',
      whereArgs: [exercicio.id],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Meus Treinos',
          style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatIA(
                      idUsuario: widget.idUsuario,
                      token: widget.token,
                    ),
                  ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () {
              Navigator.pushReplacement( 
                context,
                MaterialPageRoute(builder: (context) => TelaLogin()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meusTreinos.length,
              itemBuilder: (context, index) {
                final treinoDoDia = meusTreinos[index];

                int concluidos = treinoDoDia.exercicios.where((e) => e.concluido).length;
                int total = treinoDoDia.exercicios.length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: treinoDoDia.cor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            treinoDoDia.dia,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(width: 8),
                          
                          if (total > 0)
                            Text(
                              "$concluidos/$total",
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaEdicao(
                                nomeDoDia: treinoDoDia.dia,
                                idDiaSemana: treinoDoDia.idDia,
                                idUsuario: widget.idUsuario, 
                              ),
                            ),
                          ).then((_) => carregarDados());
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                      ),
                      children: treinoDoDia.exercicios.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text("Dia de descanso ou nenhum treino cadastrado.", style: TextStyle(color: Colors.grey)),
                              )
                            ]
                          : treinoDoDia.exercicios.map((exercicio) {
                              return ListTile(
                                leading: Checkbox(
                                  value: exercicio.concluido,
                                  shape: const CircleBorder(),
                                  activeColor: treinoDoDia.cor,
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      
                                      alternarStatusTreino(exercicio, value);
                                    }
                                  },
                                ),
                                title: Text(
                                  exercicio.nome,
                                  style: TextStyle(
                                    decoration: exercicio.concluido ? TextDecoration.lineThrough : null,
                                    color: exercicio.concluido ? Colors.grey : Colors.black87,
                                  ),
                                ),
                                trailing: Text(exercicio.series, style: const TextStyle(color: Colors.grey)),
                              );
                            }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}