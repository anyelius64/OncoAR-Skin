import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class IAService {
  Interpreter? _interpreter;

  /// Carga el modelo TFLite desde assets
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/tflite/model.tflite');
    print("Modelo cargado correctamente");
  }

  /// Verifica si el modelo está listo para usar
  bool get isReady => _interpreter != null;

  /// Ejecuta la inferencia en una imagen [File]
  List<double> predict(File imageFile) {
    if (_interpreter == null) {
      print("Error: El modelo no ha sido inicializado. Llama primero a loadModel().");
      return [];
    }

    // 1. Leer imagen desde archivo
    final rawImage = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(rawImage);

    if (image == null) {
      print("Error: no se pudo decodificar la imagen.");
      return [];
    }

    // 2. Redimensionar a 224x224
    img.Image resized = img.copyResize(image, width: 224, height: 224);

    // 3. Convertir a tensor normalizado [1,224,224,3]
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixelSafe(x, y);
            final r = img.getRed(pixel) / 255.0;
            final g = img.getGreen(pixel) / 255.0;
            final b = img.getBlue(pixel) / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );

    // 4. Crear salida [1,5] para 5 clases (modifica según tu modelo)
    var output = List.filled(5, 0.0).reshape([1, 5]);

    try {
      _interpreter!.run(input, output);
      print("Predicciones: $output");
      return output[0];
    } catch (e) {
      print("Error al ejecutar el modelo: $e");
      return [];
    }
  }
}
