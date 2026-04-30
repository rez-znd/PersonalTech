
class Treino {
  final int? id;
  final int? idUsuario;
  final String exercicio;
  final String? series;
  final int concluido; // 0 ou 1

  Treino({
    this.id,
    this.idUsuario,
    required this.exercicio,
    this.series,
    this.concluido = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'IdUsuario': idUsuario,
      'Exercicio': exercicio,
      'Series': series,
      'Concluido': concluido,
    };
  }

  factory Treino.fromMap(Map<String, dynamic> map) {
    return Treino(
      id: map['Id'],
      idUsuario: map['IdUsuario'],
      exercicio: map['Exercicio'],
      series: map['Series'],
      concluido: map['Concluido'],
    );
  }

}