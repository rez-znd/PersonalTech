import 'package:personaltech/dataBase/dartDb.dart';
import '../models/treino.dart';

class TreinoService {

  Future<int> inserir(Treino treino) async {
    final db = await DartDB.instance.database;
    return db.insert('Treino', treino.toMap());
  }

  Future<List<Treino>> listar() async {
    final db = await DartDB.instance.database;

    final result = await db.query('Treino');

    return result.map((e) => Treino.fromMap(e)).toList();
  }

  Future<void> marcarConcluido(int id, int valor) async {
    final db = await DartDB.instance.database;

    await db.update(
      'Treino',
      {'Concluido': valor},
      where: 'Id = ?',
      whereArgs: [id],
    );
  }
}