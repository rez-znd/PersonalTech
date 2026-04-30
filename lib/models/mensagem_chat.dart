
class MensagemChat {
  final int? id;
  final int idUsuario;
  final int isUser; // 0 = bot, 1 = usuário
  final String conteudo;
  final int tipo; // 1 = texto, 2 = imagem

  MensagemChat({
    this.id,
    required this.idUsuario,
    required this.isUser,
    required this.conteudo,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'IdUsuario': idUsuario,
      'IsUser': isUser,
      'Conteudo': conteudo,
      'Tipo': tipo,
    };
  }

  factory MensagemChat.fromMap(Map<String, dynamic> map) {
    return MensagemChat(
      id: map['Id'],
      idUsuario: map['IdUsuario'],
      isUser: map['IsUser'],
      conteudo: map['Conteudo'],
      tipo: map['Tipo'],
    );
  }

}