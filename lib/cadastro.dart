import 'package:flutter/material.dart';
import 'package:personaltech/models/usuario.dart';
import 'package:personaltech/services/usuario_service.dart';
import 'package:personaltech/meus_treinos.dart';

class TelaCadastro extends StatelessWidget {
  const TelaCadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return const CadastroScreen();
  }
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {

  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final dataController = TextEditingController();
  final comorbidadeController = TextEditingController();

  String? generoSelecionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'Cadastro',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    buildLabel('Usuário'),
                    buildInput('seu@email.com', controller: emailController),

                    buildLabel('Senha'),
                    buildInput('********', obscure: true, controller: senhaController),

                    buildLabel('Confirmação de senha'),
                    buildInput('********', obscure: true, controller: confirmarSenhaController),

                    buildLabel('Data de nascimento'),
                    buildInput('dd/mm/aaaa', controller: dataController, icon: Icons.calendar_today),

                    buildLabel('Gênero'),
                    buildDropdown(),

                    buildLabel('Comorbidade'),
                    buildInput('Ex: Hipertensão...', controller: comorbidadeController),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: cadastrarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Cadastrar'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Voltar'),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> cadastrarUsuario() async {

    if (emailController.text.isEmpty ||
        senhaController.text.isEmpty ||
        dataController.text.isEmpty ||
        generoSelecionado == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    if (senhaController.text != confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senhas não coincidem')),
      );
      return;
    }

    final usuario = Usuario(
      Email: emailController.text,
      Senha: senhaController.text,
      DataNascimento: dataController.text,
      Genero: generoSelecionado!,
      Comorbidade: comorbidadeController.text,
    );

    try {
      final idGerado = await UsuarioService().cadastrar(usuario);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MeusTreinos(idUsuario: idGerado),
        ),
      );
    } catch (e) {
      print("ERRO CADASTRO: $e");
    }
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget buildInput(String hint,
      {bool obscure = false,
      IconData? icon,
      required TextEditingController controller}) {

    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: icon != null ? Icon(icon, size: 18) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return DropdownButtonFormField<String>(
      value: generoSelecionado,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      hint: const Text('Selecione'),
      items: const [
        DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
        DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
        DropdownMenuItem(value: 'Outro', child: Text('Outro')),
      ],
      onChanged: (value) {
        setState(() {
          generoSelecionado = value;
        });
      },
    );
  }
}