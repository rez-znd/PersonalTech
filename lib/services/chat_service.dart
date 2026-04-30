import 'package:personaltech/dataBase/dartDb.dart';
import '../models/mensagem_chat.dart';

class ChatService {

  Future<int> enviarMensagem(MensagemChat msg) async {
    final db = await DartDB.instance.database;
    return db.insert('MensagemChat', msg.toMap());
  }

  Future<List<MensagemChat>> listarMensagens(int idUsuario) async {
    final db = await DartDB.instance.database;

    final result = await db.query(
      'MensagemChat',
      where: 'IdUsuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'Id ASC',
    );

    return result.map((e) => MensagemChat.fromMap(e)).toList();
  }
}