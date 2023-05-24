import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BosquesScreen extends StatefulWidget {
  @override
  _BosquesScreenState createState() => _BosquesScreenState();
}

class _BosquesScreenState extends State<BosquesScreen> {
  double accuracy = 0.0;
  List<dynamic> predictions = [];
  Future<void> cargarDatos() async {
    final url = Uri.parse('http://127.0.0.1:5000/?target_column=clase_objetivo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        accuracy = data['accuracy'];
      });
    } else {
      throw Exception('Error en la solicitud GET');
    }
  }

  Future<void> obtenerPredicciones() async {
    final nuevosDatos = [{'feature1': 1, 'feature2': 4}, {'feature1': 2, 'feature2': 5}];
    final url = Uri.parse('http://127.0.0.1:5000/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(nuevosDatos),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        predictions = data['predictions'];
      });
    } else {
      throw Exception('Error en la solicitud POST');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bosques'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                cargarDatos();
              },
              child: Text('Cargar Datos'),
            ),
            SizedBox(height: 16.0),
            Text('Exactitud del modelo: $accuracy'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                obtenerPredicciones();
              },
              child: Text('Obtener Predicciones'),
            ),
            SizedBox(height: 16.0),
            Text('Predicciones:'),
            Column(
              children: predictions.map((prediction) {
                return Text(prediction.toString());
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
