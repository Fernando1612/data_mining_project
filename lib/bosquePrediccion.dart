import 'package:data_mining_project/predecir.dart';
import 'package:data_mining_project/predecir_regresor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class BosquesPrediccion extends StatefulWidget {
  @override
  _BosquesPrediccionState createState() => _BosquesPrediccionState();
}

class _BosquesPrediccionState extends State<BosquesPrediccion> {
  List<String> columnNames = []; // Lista de nombres de columna
  String targetColumn = ''; // Columna objetivo
  int nEstimators = 100; // Número de estimadores
  String criterion = 'friendman_mse'; // Criterio
  int? maxDepth = null; // Profundidad máxima
  int minSamplesSplit = 2; // Número mínimo de muestras para dividir un nodo
  int minSamplesLeaf = 1; // Número mínimo de muestras para formar una hoja
  String maxFeatures = 'auto'; // Número de características a considerar
  double mse = 0.0; // Error cuadrático medio
  List<dynamic> featureImportances = ['']; // Importancia de características
  double meanAbsoluteError = 0.0; // Error absoluto medio
  double rmse = 0.0; // Error cuadrático medio de raíz
  double r2Score = 0.0; // Puntaje R2
  bool isButtonEnabled = false; // Estado del botón
  String savedFileName = ''; // Nombre de archivo guardado
  late Uint8List predictImage; // Imagen de pronóstico
  String encodedImage = ''; // Imagen codificada

  @override
  void initState() {
    super.initState();
    fetchColumnNames();
  }

  // Obtener los nombres de las columnas
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

  // Actualizar la columna objetivo
  void updateTargetColumn(String value) {
    setState(() {
      targetColumn = value;
    });
  }

  // Entrenar el modelo
  void trainModel() async {
    String apiUrl =
        'http://127.0.0.1:5000/forest-regressor-train?target_column=$targetColumn&n_estimators=$nEstimators&criterion=$criterion&max_depth=$maxDepth&min_samples_split=$minSamplesSplit&min_samples_leaf=$minSamplesLeaf&max_features=$maxFeatures';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        mse = data['mse'];
        criterion = data['criterion'];
        featureImportances = data['feature_importances'];
        meanAbsoluteError = data['mean_absolute_error'];
        rmse = data['RMSE'];
        r2Score = data['r2_score'];
        encodedImage = data['pronostico_image'];
        isButtonEnabled = true; // Activar el nuevo botón
      });
      predictImage = base64Decode(encodedImage);
    } else {
      // Manejar el error de la solicitud HTTP
    }
  }

  // Guardar el modelo computado
  void saveModelCompute(String name) async {
    String apiUrl =
        'http://127.0.0.1:5000/guardar-modelo-regresor?file_path=$name.pkl';
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

  // Guardar las columnas del modelo
  void saveColumnsModel(String name, String target) async {
    String apiUrl =
        'http://127.0.0.1:5000/guardar-column-names-regresor?file_path=$name.csv&target=$target';
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

  // Navegar a otra página
  void navigateToOtherPage() {
    // Filtrar las columnas y pasar solo las que no son la columna objetivo
    List<String> filteredColumns =
    columnNames.where((col) => col != targetColumn).toList();

    // Navegar a otra página y pasar columnNames
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PredecirRegresor(filteredColumns)),
    );
  }

  // Guardar el modelo
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
        title: Text('Bosques de Predicción'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
            children: [
              Text(
                'Parámetros para entrenar un Bosque de Predicción',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                textAlign: TextAlign.justify,
                'Un bosque de predicción, también conocido como bosque aleatorio '
                  'o Random Forest en inglés, es un algoritmo de aprendizaje '
                  'automático supervisado utilizado para la clasificación y regresión. '
                  'Se basa en la combinación de múltiples árboles de decisión independientes '
                  'entre sí para realizar predicciones.\n'
                'Cuando se realiza una predicción en un bosque de predicción, cada '
                'árbol del bosque emite su propia predicción y luego se toma una '
                  'votación (en el caso de clasificación) o se promedia (en el caso '
                  'de regresión) para obtener la predicción final del bosque.',
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                'Columnas Candidatas para ser Columna Objetivo',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
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
              Text(
                '\nTu columna objetivo representa la variable que se quiere predecir.' ''
                    'Introduce una de las mostradas anteriormente, tal cual apareció.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Columna Target',
                  border: OutlineInputBorder(),
                ),
                onChanged: updateTargetColumn,
              ),
              Text(
                '\nEl número de estimadores representa el número de árboles que '
                    'conformarán nuestro bosque. Un valor recomendado es 100. Valores '
                    'muy altos pueden ralentizar el algoritmo y valores muy bajos '
                    'podrían impactar negativamente en su desempeño.',
                style: TextStyle(fontSize: 16.0),
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
              Text(
                '\nEl criterio es la función que se utilizará para determinar '
                    'la mejor división en cada nodo. Se tienen las siguientes opciones:\n'
                    '• "squared_error" para utilizar el error medio cuadrado.\n'
                    '• "absolute_error" para utilizar el error medio absoluto. Más lento. \n'
                    '• "poisson" para utilizar la reducción de la desviacion de Poisson.',

                  style: TextStyle(fontSize: 16.0),
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
              Text(
                '\nEn número, la profundidad máxima es el nivel o expansión máxima de nodos '
                    'en los árboles. Por default no tiene esta restricción, se recomienda '
                    'modificar si se presenta un sobre ajuste.',
                style: TextStyle(fontSize: 16.0),
              ),
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
              Text(
                '\nEl número mínimo de muestras requeridas para particionar un nodo '
                    'de un árbol. Por Default tiene un mínimo de 2.',
                style: TextStyle(fontSize: 16.0),
              ),
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
              Text(
                '\nEl número mínimo de muestras requeridas para generar un nodo hoja '
                    'y considerarla valida. Determina si un nodo es o no, un nodo hoja.',
                style: TextStyle(fontSize: 16.0),
              ),
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
              Text(
                '\nEl número de caracteristicas a considerar para generar la mejor '
                    'división en un nodo de un árbol. Se puede configurar de la siguiente forma: \n'
                    '• "sqrt" para utilizar la raiz del numero de caracteristicas .\n'
                    '• "log2" para utilizar el logaritmo base 2 de las caracteristicas. \n'
                    '• "auto" para un valor igual al número de características',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Número máximo de características a considerar',
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
              if (mse != 0.0) // Mostrar los resultados del modelo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error Cuadrático Medio (MSE). : ${mse.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Criterio: $criterion',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Importancia de características: $featureImportances',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Error absoluto medio: ${meanAbsoluteError.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'RMSE: ${rmse.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R2 Score: ${r2Score.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (predictImage != null) ...[
                      Text(
                        '\n\nGráfica de Pronóstico',
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Es una representación gráfica utilizada para evaluar '
                            'el rendimiento de nuestras predicciones en comparación '
                            'con los valores reales. Si los colores se encuentran muy '
                            'dispersos, se puede intentar mejorar el modelo variando '
                            'los parámetros.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 16.0),
                      Image.memory(predictImage),
                    ],
                  ],
                ),
              SizedBox(height: 16.0),
              if (isButtonEnabled) // Mostrar el nuevo botón solo si el modelo se ha entrenado
                ElevatedButton(
                  onPressed: () => navigateToOtherPage(),
                  child: Text('Predecir'),
                ),
              SizedBox(height: 16.0),
              if (isButtonEnabled) // Mostrar el botón de guardar solo si el modelo se ha entrenado
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
