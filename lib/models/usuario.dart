class Usuario {
  final int? IdUsuario;
  final String Email;
  final String Senha;
  final String DataNascimento;
  final String Genero;
  final String Comorbidade;

  Usuario({
    this.IdUsuario,
    required this.Email,
    required this.Senha,
    required this.DataNascimento,
    required this.Genero,
    required this.Comorbidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'IdUsuario': IdUsuario,
      'Email': Email,
      'Senha': Senha,
      'DataNascimento': DataNascimento,
      'Genero': Genero,
      'Comorbidade': Comorbidade,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      IdUsuario: map['IdUsuario'],
      Email: map['Email'],
      Senha: map['Senha'],
      DataNascimento: map['DataNascimento'],
      Genero: map['Genero'],
      Comorbidade: map['Comorbidade'],
    );
  }
}