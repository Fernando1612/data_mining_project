import 'package:data_mining_project/predecir.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class BosquesScreen extends StatefulWidget {
  @override
  _BosquesScreenState createState() => _BosquesScreenState();
}

class _BosquesScreenState extends State<BosquesScreen> {
  List<String> columnNames = []; // Lista de nombres de columnas
  String targetColumn = ''; // Columna objetivo seleccionada
  int nEstimators = 100; // Número de estimadores para el modelo de bosques aleatorios
  String criterion = 'gini'; // Criterio para la selección de características en el modelo
  int? maxDepth = null; // Profundidad máxima de los árboles en el modelo
  int minSamplesSplit = 2; // Número mínimo de muestras requeridas para dividir un nodo
  int minSamplesLeaf = 1; // Número mínimo de muestras requeridas para formar una hoja
  String maxFeatures = 'auto'; // Número de características a considerar en cada división
  late Uint8List rocImage; // Imagen de la curva ROC
  late Uint8List matrixImage; // Imagen de la matriz de confusión
  double accuracy = 0.0; // Precisión del modelo
  String encodedImage = ''; // Imagen codificada en base64 (curva ROC)
  String encodedImageMatrix = ''; // Imagen codificada en base64 (matriz de confusión)
  bool isButtonEnabled = false; // Indicador de si el botón está habilitado
  String savedFileName = ''; // Nombre de archivo guardado

  @override
  void initState() {
    super.initState();
    fetchColumnNames();
  }

  // Obtener los nombres de las columnas desde el servidor
  Future<void> fetchColumnNames() async {
    final response =
    await http.get(Uri.parse('http://127.0.0.1:5000/column-names'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        columnNames = List<String>.from(data['column_names']);
      });
    }
  }

  // Actualizar la columna objetivo seleccionada
  void updateTargetColumn(String value) {
    setState(() {
      targetColumn = value;
    });
  }

  // Entrenar el modelo de bosques aleatorios
  void trainModel() async {
    String apiUrl =
        'http://127.0.0.1:5000/forest?target_column=$targetColumn&n_estimators=$nEstimators&criterion=$criterion&max_depth=$maxDepth&min_samples_split=$minSamplesSplit&min_samples_leaf=$minSamplesLeaf&max_features=$maxFeatures';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        accuracy = data['accuracy'];
        encodedImage = data['roc_image'];
        encodedImageMatrix = data['matrix_image'];
        isButtonEnabled = true; // Habilitar el botón adicional
      });
      // Decodificar la imagen codificada en base64
      rocImage = base64Decode(encodedImage);
      matrixImage = base64Decode(encodedImageMatrix);
    } else {
      // Manejar el error de la solicitud HTTP
    }
  }

  // Guardar el modelo de clasificación
  void saveModelCompute(String name) async {
    String apiUrl = 'http://127.0.0.1:5000/guardar-modelo-clasificador?file_path=$name.pkl';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        // La solicitud fue exitosa y se recibió la imagen
        //= response.body;
      });
    } else {
      throw Exception('Failed save model');
    }
  }

  // Guardar los nombres de las columnas
  void saveColumnsModel(String name, String target) async {
    String apiUrl = 'http://127.0.0.1:5000/guardar-column-names?file_path=$name.csv&target=$target';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        // La solicitud fue exitosa y se recibió la imagen
        //= response.body;
      });
    } else {
      throw Exception('Failed save model');
    }
  }

  // Navegar a la página de predicción
  void navigateToOtherPage() {
    // Filtrar las columnas y pasar solo las que no son la columna objetivo
    List<String> filteredColumns = columnNames.where((col) => col != targetColumn).toList();

    // Navegar a otra página y pasar columnNames
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Predecir(filteredColumns)),
    );
  }

  // Mostrar el diálogo para guardar el modelo
  void saveModel(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Guardar modelo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nombre del archivo:'),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    savedFileName = value;
                  });
                },
              ),
            ],
          ),
          contentPadding: EdgeInsets.all(16.0),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                saveModelCompute(savedFileName);
                saveColumnsModel(savedFileName, targetColumn);
                Navigator.of(context).pop();
                // Aquí puedes guardar el modelo utilizando savedFileName
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bosques Clasificación'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (String columnName in columnNames)
                      if (columnName != targetColumn) // Excluir la columna objetivo
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: Text(columnName),
                        ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Columna Target',
                  border: OutlineInputBorder(),
                ),
                onChanged: updateTargetColumn,
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número de estimadores',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    nEstimators = int.tryParse(value) ?? 100;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Criterio',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    criterion = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Profundidad máxima',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    maxDepth = int.tryParse(value);
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número mínimo de muestras para dividir un nodo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    minSamplesSplit = int.tryParse(value) ?? 2;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número mínimo de muestras para formar una hoja',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    minSamplesLeaf = int.tryParse(value) ?? 1;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número de características a considerar',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    maxFeatures = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: trainModel,
                child: Text('Entrenar modelo'),
              ),
              SizedBox(height: 16.0),
              if (accuracy != 0.0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'El valor de precisión del modelo es: ${accuracy.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (rocImage != null) ...[
                      SizedBox(height: 16.0),
                      Image.memory(rocImage),
                    ],
                    if (matrixImage != null) ...[
                      SizedBox(height: 16.0),
                      Image.memory(matrixImage),
                    ],
                  ],
                ),
              SizedBox(height: 16.0),
              if (isButtonEnabled) // Mostrar el nuevo botón si está habilitado
                ElevatedButton(
                  onPressed: navigateToOtherPage,
                  child: Text('Nueva clasificación'),
                ),
              SizedBox(height: 16.0),
              if (isButtonEnabled) // Mostrar el nuevo botón si está habilitado
                ElevatedButton(
                  onPressed: () => saveModel(context),
                  child: Text('Guardar modelo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
