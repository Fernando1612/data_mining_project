import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetallesArchivoPkl extends StatefulWidget {
  final String nombreArchivo;

  DetallesArchivoPkl({required this.nombreArchivo});

  @override
  _DetallesArchivoPklState createState() => _DetallesArchivoPklState();
}

class _DetallesArchivoPklState extends State<DetallesArchivoPkl> {
  List<String> columnNames = [];
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> textControllers = [];

  @override
  void initState() {
    super.initState();
    cargarColumnas();
  }

  // Cargar las columnas del archivo CSV
  Future<void> cargarColumnas() async {
    final url = Uri.parse('http://127.0.0.1:5000/cargar-column-names?file_path=${widget.nombreArchivo}.csv');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          columnNames = List<String>.from(data['column_names']);
          textControllers = List.generate(
            columnNames.length,
                (index) => TextEditingController(),
          );
        });
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  @override
  void dispose() {
    // Liberar todos los controladores de texto cuando el widget se elimine
    for (var controller in textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del archivo'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nombre del archivo seleccionado: ${widget.nombreArchivo}'),
              SizedBox(height: 20),
              Text('Columnas:'),
              Form(
                key: _formKey,
                child: Column(
                  children: List.generate(columnNames.length, (index) {
                    final columnName = columnNames[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: textControllers[index],
                        decoration: InputDecoration(
                          labelText: columnName,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese un valor';
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _executePrediction(context, textControllers);
                },
                child: Text('Predecir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ejecutar la predicción
  void _executePrediction(BuildContext context, List<TextEditingController> textControllers) {
    // Obtener los valores de las características ingresadas
    List<String> featureValues = textControllers.map((controller) => controller.text).toList();

    // Construir la URL de la solicitud GET para enviar las características a la API Flask
    String url = 'http://127.0.0.1:5000/predict-modelo?';
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
