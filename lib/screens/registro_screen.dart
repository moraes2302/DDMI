import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:provider/provider.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaController = TextEditingController();
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar(AuthController auth) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await auth.cadastrarUsuario(
      _nomeController.text.trim(),
      _emailController.text.trim(),
      _senhaController.text,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cadastro realizado! Faça login.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.erro)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar conta")),
      body: Consumer<AuthController>(
        builder: (context, auth, child) => Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) => (valor == null || valor.trim().isEmpty)
                        ? "Informe o nome"
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return "Informe o e-mail";
                      }
                      if (!valor.contains('@')) return "E-mail inválido";
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _ocultarSenha,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _ocultarSenha = !_ocultarSenha),
                        icon: Icon(_ocultarSenha
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmaController,
                    obscureText: _ocultarSenha,
                    decoration: InputDecoration(
                      labelText: "Confirmar senha",
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) => valor != _senhaController.text
                        ? "As senhas não conferem"
                        : null,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          auth.carregando ? null : () => _cadastrar(auth),
                      child: auth.carregando
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text("Cadastrar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
