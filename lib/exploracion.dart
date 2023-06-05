import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExploracionDatos extends StatefulWidget {
  @override
  _ExploracionDatosState createState() => _ExploracionDatosState();
}

class _ExploracionDatosState extends State<ExploracionDatos> {
  String apiUrl = 'http://127.0.0.1:5000/data-preview?num_rows=5';
  String apiUrlStats = 'http://127.0.0.1:5000/data-statistics';
  String apiUrlNulls = 'http://127.0.0.1:5000/data-nulls';
  String apiUrlAll = 'http://127.0.0.1:5000/data-all';

  String histogramImageUrl = '';
  String boxplotImageUrl = '';
  String heatmapImageUrl = '';
  late Uint8List? imageBytesHeat;
  late Uint8List? imageBytesBox;
  late Uint8List? imageBytesHist;

  // Variables para Tabla de EDA
  List<String> columnNames = [];
  List<Map<String, dynamic>> data = [];

  // Variables para Tabla de Estadisticas
  List<String> columnNamesStats = [];
  List<Map<String, dynamic>> dataStats = [];
  List<String> indexNameStats = [];

  // Variables para Tabla de Nulls
  List<String> columnNamesNulls = ['Valores Nulos'];
  List<String> indexNameNulls = [];
  List<Map<String, dynamic>> dataNull = [];

  // TODAS las Variables para Tabla de EDA
  List<String> columnNamesAll = [];
  List<Map<String, dynamic>> dataAll = [];

  bool isLoading = true;
  bool isImageLoadedHist = false;
  bool isImageLoadedBox = false;
  bool isImageLoadedHeat = false;

  @override
  void initState() {
    super.initState();
    fetchDataPreview();
    fetchDataStats();
    fetchDataNulls();
    // Retrasar el inicio de fetchHistogramImage() durante 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      fetchHistogramImage().then((_) {
        // La función fetchHistogramImage() ha terminado
        fetchBoxplotImage().then((_) {
          // La función fetchBoxplotImage() ha terminado
          fetchHeatmapImage();
        });
      });
    });
  }

  // Obtener los datos de vista previa
  Future<void> fetchDataPreview() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          columnNames = List<String>.from(jsonData['column_names']);
          columnNames.sort(); // Ordenar columnNames en orden alfabético
          data = List<Map<String, dynamic>>.from(jsonData['data']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print(e);
    }
  }

  // Obtener los datos de estadísticas
  Future<void> fetchDataStats() async {
    try {
      final response = await http.get(Uri.parse(apiUrlStats));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          columnNamesStats = List<String>.from(jsonData['column_names']);
          columnNamesStats.sort(); // Ordenar columnNames en orden alfabético
          indexNameStats = List<String>.from(jsonData['index_names']);
          dataStats = List<Map<String, dynamic>>.from(jsonData['data']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print(e);
    }
  }

  // Obtener los datos de valores nulos
  Future<void> fetchDataNulls() async {
    try {
      final response = await http.get(Uri.parse(apiUrlNulls));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          indexNameNulls = List<String>.from(jsonData['index_names']);
          dataNull = List<Map<String, dynamic>>.from(jsonData['data']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print(e);
    }
  }

  // Obtener la imagen del histograma
  Future<void> fetchHistogramImage() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/plot-histogram'));
      if (response.statusCode == 200) {
        setState(() {
          // La solicitud fue exitosa y se recibió la imagen
          imageBytesHist = response.bodyBytes;
          isImageLoadedHist = true;
        });
      } else {
        throw Exception('Failed to fetch histogram image');
      }
    } catch (e) {
      print(e);
    }
  }

  // Obtener la imagen del diagrama de caja
  Future<void> fetchBoxplotImage() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/plot-boxplot'));
      if (response.statusCode == 200) {
        setState(() {
          // La solicitud fue exitosa y se recibió la imagen
          imageBytesBox = response.bodyBytes;
          isImageLoadedBox = true;
        });
      } else {
        throw Exception('Failed to fetch boxplot image');
      }
    } catch (e) {
      print(e);
    }
  }

  // Obtener la imagen del mapa de calor
  Future<void> fetchHeatmapImage() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/plot-heatmap'));
      if (response.statusCode == 200) {
        setState(() {
          // La solicitud fue exitosa y se recibió la imagen
          imageBytesHeat = response.bodyBytes;
          isImageLoadedHeat = true;
        });
      } else {
        throw Exception('Failed to fetch heatmap image');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EDA Data'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Análisis Exploratorio de Datos (EDA)',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const Text(
                'El análisis nos permitirá tener una idea de la estructura de '
                    'los datos. Esto dará paso a la selección de tu variable y '
                    'las características que la acompañan. También permite '
                    'elegir el mejor modelo.',
                    style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              const Text(
                'Head preliminar de los datos',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const Text(
                'A continuación desplegamos solo los 5 primeros datos de cada '
                'columna. Puedes observar la información que los acompaña.'
                'Reiteramos que el Head no es la totalidad de los datos.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              isLoading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: columnNames
                      .map((name) => DataColumn(
                    label: Text(
                      name,
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ))
                      .toList(),
                  rows: data.asMap().map((index, rowData) {
                    return MapEntry(
                      index,
                      DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                            }
                            if (index.isEven) {
                              return Colors.grey.withOpacity(0.3);
                            }
                            return null;
                          },
                        ),
                        cells: rowData.entries.map((entry) {
                          return DataCell(Text(entry.value.toString()));
                        }).toList(),
                      ),
                    );
                  }).values.toList(),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Estadísticas de los datos',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'Se ofrecen los siguientes valores para describir los datos: \n'
                'Count: Número de valores no nulos. \n'
                'Mean: El valor promedio de los datos \n'
                'Std: La desviación estandar \n'
                'Min: El valor mínimo encontrado en la serie de datos \n'
                'Porcentajes %: El percentil al 25%, 50% y 75%, respectivamente \n'
                'Max: El valor máximo encontrado en la serie de datos.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              columnNamesStats.isNotEmpty && dataStats.isNotEmpty
                  ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label:
                    Text(
                        'index',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    )
                    ),
                    ...columnNamesStats.map(
                          (name) => DataColumn(label:
                          Text(
                              name,
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          )
                          ),
                    ),
                  ],
                  rows: dataStats.asMap().entries.map(
                        (entry) {
                      int index = entry.key;
                      Map<String, dynamic> rowData = entry.value;
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                            }
                            if (index.isEven) {
                              return Colors.grey.withOpacity(0.3);
                            }
                            return null;
                          },
                        ),
                        cells: [
                          DataCell(Text(indexNameStats[index])),
                          ...rowData.entries.map((entry) {
                            return DataCell(Text(entry.value.toString()));
                          }).toList(),
                        ],
                      );
                    },
                  ).toList(),
                ),
              )
                  : Container(
                child: Text('No hay datos de estadísticas disponibles.'),
              ),
              SizedBox(height: 16.0),
              Text(
                'Tabla de Nulls:',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'Se muestra una tabla que otorga el conteo de los valores nulos '
                'o vacíos por columna. Un valor de 0 indica que no se hayaron '
                'estos valores en el set de datos provisto.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              columnNamesNulls.isNotEmpty && dataNull.isNotEmpty
                  ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label:
                    Text(
                        'Columnas',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    )),
                    ...columnNamesNulls.map(
                          (name) => DataColumn(label: Text(
                              name,
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)
                          )),
                    ),
                  ],
                  rows: dataNull.asMap().entries.map(
                        (entry) {
                      int index = entry.key;
                      Map<String, dynamic> rowData = entry.value;
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                            }
                            if (index.isEven) {
                              return Colors.grey.withOpacity(0.3);
                            }
                            return null;
                          },
                        ),
                        cells: [
                          DataCell(Text(indexNameNulls[index])),
                          ...rowData.entries.map((entry) {
                            return DataCell(Text(entry.value.toString()));
                          }).toList(),
                        ],
                      );
                    },
                  ).toList(),
                ),
              )
                  : Container(
                child: Text('No hay datos de nulls disponibles.'),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Histogramas',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Representación visual de la distribución de frecuencia de un '
                  'conjunto de datos. Se utiliza para mostrar cómo se '
                  'distribuyen los valores en un conjunto de datos y proporciona '
                  'información sobre la forma de la distribución, los valores '
                  'más comunes y los valores extremos.\n'
                'En un histograma, el eje horizontal representa las diferentes '
                  'categorías o rangos de valores del conjunto de datos, y el '
                  'eje vertical muestra la frecuencia o la cantidad de veces que '
                  'ocurre cada categoría o rango. Cada barra en el histograma '
                  'representa una categoría o rango y su altura representa la '
                  'frecuencia de esa categoría.',
                style: TextStyle(fontSize: 16.0),
              ),

              SizedBox(height: 8.0),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 600,
                    width: MediaQuery.of(context).size.width - 32.0,
                    child: isImageLoadedHist
                        ? FittedBox(
                      fit: BoxFit.fill,
                      child: Image.memory(imageBytesHist!),
                    )
                        : Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Diagramas de caja',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Un diagrama de caja, también conocido como diagrama de caja y '
                  'bigotes o box plot en inglés, es una herramienta gráfica '
                  'que se utiliza para representar la distribución estadística '
                  'de un conjunto de datos numéricos. Proporciona información '
                  'sobre la posición central, la dispersión y los valores '
                  'atípicos de los datos.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 600,
                    width: MediaQuery.of(context).size.width - 32.0,
                    child: isImageLoadedBox
                        ? FittedBox(
                      fit: BoxFit.fill,
                      child: Image.memory(imageBytesBox!),
                    )
                        : Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Mapa de calor',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Un mapa de calor, también conocido como mapa de colores o '
                  'heatmap en inglés, es una representación visual de datos '
                  'donde se utilizan colores para mostrar la intensidad o el '
                  'valor relativo de una variable en diferentes regiones o '
                  'puntos de un espacio bidimensional.\n'
                  'En un mapa de calor, se asigna un color específico a cada '
                  'valor o rango de valores de la variable que se está '
                  'representando. Generalmente, se utiliza una escala de '
                  'colores donde los tonos más oscuros o intensos representan '
                  'valores altos, y los tonos más claros o suaves representan '
                  'valores bajos.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 600,
                    width: MediaQuery.of(context).size.width - 32.0,
                    child: isImageLoadedHeat
                        ? FittedBox(
                      fit: BoxFit.fill,
                      child: Image.memory(imageBytesHeat!),
                    )
                        : Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

