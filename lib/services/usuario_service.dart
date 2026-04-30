import 'package:personaltech/dataBase/dartDb.dart';
import 'package:personaltech/models/usuario.dart';

class UsuarioService {

  Future<int> cadastrar(Usuario usuario) async {
    final db = await DartDB.instance.database;
    return await db.insert('Usuario', usuario.toMap());
  }

  Future<Usuario?> login(String email, String senha) async {
    final db = await DartDB.instance.database;

    final result = await db.query(
      'Usuario',
      where: 'Email = ? AND Senha = ?',
      whereArgs: [email, senha],
    );

    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    } else {
      return null;
    }
  }
}