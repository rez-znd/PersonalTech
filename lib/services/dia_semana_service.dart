import 'package:personaltech/dataBase/dartDb.dart';
import '../models/dia_semana.dart';

class DiaSemanaService {

  Future<List<DiaSemana>> listarDias() async {
    final db = await DartDB.instance.database;

    final result = await db.query('DiaSemana');

    return result.map((e) => DiaSemana.fromMap(e)).toList();
  }
}