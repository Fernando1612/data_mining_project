import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PredecirRegresor extends StatelessWidget {
  final List<String> columnNames;

  PredecirRegresor(this.columnNames);

  @override
  Widget build(BuildContext context) {
    // Controladores para los TextFormField
    List<TextEditingController> textControllers = List.generate(
      columnNames.length,
          (index) => TextEditingController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Predicción'),
      ),
      body: ListView.builder(
        itemCount: columnNames.length + 1, // Agregar 1 para el botón adicional
        itemBuilder: (context, index) {
          if (index < columnNames.length) {
            return ListTile(
              title: TextFormField(
                controller: textControllers[index], // Asignar el controlador correspondiente
                decoration: InputDecoration(
                  labelText: columnNames[index],
                ),
                // Aquí puedes agregar propiedades y controladores adicionales según tus necesidades
              ),
            );
          } else {
            return ElevatedButton(
              onPressed: () {
                // Ejecutar el método _executePrediction y mostrar el resultado
                _executePrediction(context, textControllers);
              },
              child: Text('Predecir'),
            );
          }
        },
      ),
    );
  }

  void _executePrediction(BuildContext context, List<TextEditingController> textControllers) {
    // Obtener los valores de las características ingresadas
    List<String> featureValues = textControllers.map((controller) => controller.text).toList(); // Obtener los valores de los controladores

    // Construir el URL de la solicitud GET para enviar las características a la API Flask
    String url = 'http://127.0.0.1:5000/forest-regressor-predict?';
    for (int i = 0; i < columnNames.length; i++) {
      String paramName = columnNames[i];
      String paramValue = featureValues[i];
      url += '$paramName=$paramValue';
      if (i < columnNames.length - 1) {
        url += '&';
      }
    }

    // Realizar la solicitud GET a la API Flask
    http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        // Analizar la respuesta JSON y mostrar el resultado en un diálogo o en otro lugar según tus necesidades
        Map<String, dynamic> result = jsonDecode(response.body);
        List<dynamic> prediction = result['prediction'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Resultado de la predicción'),
              content: Text('La predicción es: $prediction'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      // Manejar el error en caso de que ocurra
      print('Error: $error');
    });
  }
}
