
class DiaSemana {
  final int? id;
  final String dia;

  DiaSemana({
    this.id,
    required this.dia,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Dia': dia,
    };
  }

  factory DiaSemana.fromMap(Map<String, dynamic> map) {
    return DiaSemana(
      id: map['Id'],
      dia: map['Dia'],
    );
  }
}