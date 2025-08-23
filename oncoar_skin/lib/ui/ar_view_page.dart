import 'package:flutter/material.dart';

class ARViewPage extends StatelessWidget {
  final String diagnosisText;

  const ARViewPage({Key? key, required this.diagnosisText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vista RA")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              "Diagnóstico: $diagnosisText",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
