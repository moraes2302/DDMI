import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guia_turismo/services/camera_service.dart';

class CameraController extends ChangeNotifier{
  final CameraService _service = CameraService();
  bool carregando = false;
  File? _imagemSelecionada;
  File? get imagemSelecionada => _imagemSelecionada;

  Future <void> abrirGaleria() async {
    carregando = true;
    notifyListeners();
    final imagem = await _service.chamarGaleria();
    if (imagem != null) _imagemSelecionada = imagem;
    carregando = false;
    notifyListeners();
  }

  Future <void> abrirCamera() async{
    carregando = true;
    notifyListeners();
    final imagem = await _service.chamarCamera();
    if (imagem != null) _imagemSelecionada = imagem;
    carregando = false;
    notifyListeners();
  }

  void limpar() {
    _imagemSelecionada = null;
    notifyListeners();
  }
}
