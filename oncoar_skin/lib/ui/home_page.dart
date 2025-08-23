import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ia_service.dart';
import 'ar_view_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final IAService iaService = IAService();
  File? _image;
  List<double>? _predictions;
  String _diagnosis = "";
  bool _modelReady = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    await iaService.loadModel();
    setState(() {
      _modelReady = iaService.isReady;
    });
  }

  Future<void> _pickImage() async {
    if (!_modelReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El modelo aún no está listo")),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      File imageFile = File(picked.path);
      final predictions = await iaService.predict(imageFile);

      if (predictions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al procesar la imagen")),
        );
        return;
      }

      // Encontrar índice con mayor probabilidad
      int maxIndex = 0;
      double maxProb = predictions[0];
      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxProb) {
          maxProb = predictions[i];
          maxIndex = i;
        }
      }

      List<String> labels = ["Benigno", "Melanoma", "Nevus", "Queratosis", "Otra"];
      String diagnosis = (maxIndex < labels.length) ? labels[maxIndex] : "Desconocido";

      setState(() {
        _image = imageFile;
        _predictions = predictions;
        _diagnosis = "$diagnosis - Precisión ${(maxProb * 100).toStringAsFixed(1)}%";
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ARViewPage(diagnosisText: _diagnosis),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OncoAR - Diagnóstico RA")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_modelReady)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Tomar Foto de Lesión"),
                ),
              const SizedBox(height: 20),
              if (_image != null)
                Image.file(
                  _image!,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              const SizedBox(height: 20),
              if (_predictions != null)
                Text(
                  "Predicciones: ${_predictions!.map((e) => e.toStringAsFixed(2)).join(", ")}",
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
