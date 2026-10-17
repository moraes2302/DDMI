import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/camera_controller.dart';
import 'package:guia_turismo/controller/categorias_controller.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:provider/provider.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  int? _categoriaId;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _salvar(LugaresController lugaresController) async {
    if (!_formKey.currentState!.validate()) return;
    final lugar = LugaresModel(
      id: 0,
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      latitude: double.parse(_latitudeController.text.replaceAll(',', '.')),
      longitude: double.parse(_longitudeController.text.replaceAll(',', '.')),
      categoriaId: _categoriaId!,
    );
    final camera = context.read<CameraController>();
    final ok = await lugaresController.cadastrarLugar(
      lugar,
      foto: camera.imagemSelecionada,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(lugaresController.mensagem)),
    );
    if (ok) {
      camera.limpar();
      lugaresController.listaLugares();
      Navigator.pop(context);
    }
  }

  String? _validarNumero(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) return "Informe $campo";
    if (double.tryParse(valor.replaceAll(',', '.')) == null) {
      return "Número inválido";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar lugar")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<CameraController>(
                builder: (context, controleCamera, _) => Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        border: Border.all(width: 2),
                        borderRadius: BorderRadius.circular(16),
                        image: exibirImagem(controleCamera),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => abrirModal(controleCamera, context),
                        icon: Icon(Icons.camera_alt_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: "Nome do lugar",
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? "Informe o nome"
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? "Informe a descrição"
                    : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: "Latitude",
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) => _validarNumero(valor, "a latitude"),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: "Longitude",
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) =>
                          _validarNumero(valor, "a longitude"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Consumer<CategoriasController>(
                builder: (context, categoriasController, _) {
                  if (categoriasController.carregando) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (categoriasController.erro != '' ||
                      categoriasController.categorias.isEmpty) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(categoriasController.erro != ''
                              ? categoriasController.erro
                              : "Nenhuma categoria encontrada"),
                        ),
                        IconButton(
                          onPressed: () => categoriasController.listaCategorias(),
                          icon: Icon(Icons.refresh),
                        ),
                      ],
                    );
                  }
                  return DropdownButtonFormField<int>(
                    initialValue: _categoriaId,
                    decoration: InputDecoration(
                      labelText: "Categoria",
                      border: OutlineInputBorder(),
                    ),
                    items: categoriasController.categorias
                        .map((categoria) => DropdownMenuItem<int>(
                              value: categoria.id,
                              child: Text(categoria.nome),
                            ))
                        .toList(),
                    onChanged: (valor) => setState(() => _categoriaId = valor),
                    validator: (valor) =>
                        valor == null ? "Escolha uma categoria" : null,
                  );
                },
              ),
              SizedBox(height: 24),
              Consumer<LugaresController>(
                builder: (context, lugaresController, _) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: lugaresController.carregando
                        ? null
                        : () => _salvar(lugaresController),
                    child: lugaresController.carregando
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text("Salvar lugar"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DecorationImage exibirImagem(CameraController controleCamera) {
  if (controleCamera.imagemSelecionada == null) {
    return DecorationImage(
      image: NetworkImage('https://placehold.co/150x150.png', scale: 1.0),
    );
  } else {
    return DecorationImage(
      image: FileImage(controleCamera.imagemSelecionada!),
      fit: BoxFit.cover,
    );
  }
}

void abrirModal(CameraController controleCamera, context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      bottom: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          ListTile(
            leading: Icon(Icons.camera),
            title: Text("Câmera"),
            onTap: () {
              controleCamera.abrirCamera();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text("Galeria"),
            onTap: () {
              controleCamera.abrirGaleria();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
