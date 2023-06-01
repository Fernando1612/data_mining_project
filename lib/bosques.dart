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
  List<String> columnNames = [];
  String targetColumn = '';
  int nEstimators = 100;
  String criterion = 'gini';
  int? maxDepth = null;
  int minSamplesSplit = 2;
  int minSamplesLeaf = 1;
  String maxFeatures = 'auto';
  late Uint8List rocImage;
  late Uint8List matrixImage;
  double accuracy = 0.0;
  String encodedImage = '';
  String encodedImageMatrix = '';
  bool isButtonEnabled = false;
  String savedFileName = ''; // Nombre de archivo guardado


  @override
  void initState() {
    super.initState();
    fetchColumnNames();
  }

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

  void updateTargetColumn(String value) {
    setState(() {
      targetColumn = value;
    });
  }

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
        isButtonEnabled = true; // Activar el nuevo botón
      });
      // Decodificar la imagen codificada en base64
      rocImage = base64Decode(encodedImage);
      matrixImage = base64Decode(encodedImageMatrix);
    } else {
      // Manejar el error de la solicitud HTTP
    }
  }

  void saveModelCompute(String name) async{
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

  void saveColumnsModel(String name) async{
    String apiUrl = 'http://127.0.0.1:5000/guardar-column-names?file_path=$name.csv';
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

  void navigateToOtherPage() {
    // Filtrar las columnas y pasar solo las que no son la columna objetivo
    List<String> filteredColumns = columnNames.where((col) => col != targetColumn).toList();

    // Navegar a otra página y pasar columnNames
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Predecir(filteredColumns)),
    );
  }

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
                saveColumnsModel(savedFileName);
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
        title: Text('Bosques'),
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


class Predecir extends StatelessWidget {
  final List<String> columnNames;

  Predecir(this.columnNames);

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
                // Ejecutar el método predict_data y mostrar el resultado
                _executePrediction(context, textControllers);
              },
              child: Text('Predecir'),
            );
          }
        },
      ),
    );
  }

  void _executePrediction(
      BuildContext context, List<TextEditingController> textControllers) {
    // Obtener los valores de las características ingresadas
    List<String> featureValues = textControllers
        .map((controller) => controller.text)
        .toList(); // Obtener los valores de los controladores

    // Construir el URL de la solicitud GET para enviar las características a la API Flask
    String url = 'http://127.0.0.1:5000/forest-predict?';
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


