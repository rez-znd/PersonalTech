import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DartDB {
  static final DartDB instance = DartDB._init();
  static Database? _database;

  DartDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {

    // Dias da semana
    await db.execute('''
    CREATE TABLE DiaSemana (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      Dia TEXT NOT NULL
    )
    ''');

    //Dias da semana inseridos automaticamente
    final dias = [
      'Domingo','Segunda','Terça','Quarta',
      'Quinta','Sexta','Sábado'
    ];

    for (var dia in dias) {
      await db.insert('DiaSemana', {'Dia': dia});
    }

    // Tabela de treinos 
    await db.execute('''
    CREATE TABLE Treino (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      IdUsuario TEXT NOT NULL,
      IdDiaSemana INTEGER NOT NULL,
      Exercicio TEXT NOT NULL,
      Series TEXT,
      Repeticoes TEXT,
      Concluido INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario),
      FOREIGN KEY (IdDiaSemana) REFERENCES DiaSemana(Id)
    )
    ''');

    // Chat com a IA
    await db.execute('''
    CREATE TABLE MensagemChat (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      IdUsuario TEXT NOT NULL,
      IsUser INTEGER NOT NULL,
      Conteudo TEXT NOT NULL,
      Tipo INTEGER NOT NULL,
      FOREIGN KEY (IdUsuario) REFERENCES Usuario (IdUsuario)
    )
    ''');
  }

  Future<int> inserirTreino(Map<String, dynamic> treino) async {
    final db = await instance.database;
    return await db.insert('Treino', treino);
  }

  Future<List<Map<String, dynamic>>> buscarTreinosPorDia(String idUsuario, int idDiaSemana) async {
    final db = await instance.database;
    return await db.query(
      'Treino',
      where: 'IdUsuario = ? AND IdDiaSemana = ?',
      whereArgs: [idUsuario, idDiaSemana],
    );
  }

  Future<int> atualizarTreino(Map<String, dynamic> treino) async {
    final db = await instance.database;
    int id = treino['Id'];
    return await db.update(
      'Treino',
      treino,
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletarTreino(int id) async {
    final db = await instance.database;
    return await db.delete(
      'Treino',
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> buscarDias() async {
  final db = await instance.database;
  return await db.query('DiaSemana');
}

Future<List<Map<String, dynamic>>> buscarTreinosPorUsuario(String idUsuario) async {
  final db = await instance.database;
  return await db.query(
    'Treino',
    where: 'IdUsuario = ?',
    whereArgs: [idUsuario],
  );
}

Future<List<Map<String, dynamic>>> buscarTodosOsDiasComTreinos(String idUsuario) async {
    final db = await instance.database;
    
    return await db.rawQuery('''
      SELECT 
        d.Id AS DiaId,
        d.Dia,
        t.Id AS TreinoId,
        t.Exercicio,
        t.Series,
        t.Repeticoes,
        t.Concluido
      FROM DiaSemana d
      LEFT JOIN Treino t ON d.Id = t.IdDiaSemana AND t.IdUsuario = ?
      ORDER BY d.Id
    ''', [idUsuario]);
  }

  Future<int> inserirMensagem(Map<String, dynamic> mensagem) async {
    final db = await instance.database;
    return await db.insert('MensagemChat', mensagem);
  }
  Future<List<Map<String, dynamic>>> buscarMensagens(String idUsuario) async {
    final db = await instance.database;
    return await db.query(
      'MensagemChat',
      where: 'IdUsuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'Id ASC',
    );
  }

}