import 'package:flutter/material.dart';
import 'ui/home_page.dart'; // Asegúrate de importar tu HomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OncoAR Skin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(), // Aquí cargas tu HomePage con el botón
    );
  }
}
