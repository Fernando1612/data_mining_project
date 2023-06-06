import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Clasificacion extends StatefulWidget {
  @override
  _ClasificacionState createState() => _ClasificacionState();
}

class _ClasificacionState extends State<Clasificacion> {
  String apiUrl = ''; // URL de la API
  List<String> columnNames = []; // Nombres de las columnas del conjunto de datos
  List<Map<String, dynamic>> data = []; // Datos del conjunto de datos
  bool isDataLoaded = false; // Indicador de si los datos han sido cargados correctamente
  bool isLoadingPlot = false; // Indicador de si el gráfico está cargando
  bool isLoadingData = false; // Indicador de si los datos están cargando
  TextEditingController componentsController = TextEditingController(); // Controlador del campo de entrada del número de clusters
  int components = 2; // Número de clusters seleccionado
  String selectedScaler = 'StandardScaler'; // Escalador seleccionado
  List<String> scalerOptions = ['StandardScaler', 'MinMaxScaler', 'Normalizer']; // Opciones de escalador
  late Uint8List? imageElbow; // Imagen del gráfico
  List<String> columnNamesCentroide = []; // Nombres de las columnas del conjunto de datos de centroides
  List<Map<String, dynamic>> dataCentroide = []; // Datos del conjunto de datos de centroides
  List<String> columnNamesCount = []; // Nombres de las columnas del conjunto de datos de conteo
  List<Map<String, dynamic>> dataCount = []; // Datos del conjunto de datos de conteo
  late Uint8List predictImage; // Imagen del resultado de la predicción
  String encodedImage = ''; // Imagen codificada en base64
  late String savedFileName; // Nombre del archivo guardado

  @override
  void initState() {
    super.initState();
    fetchDataPlot();
  }

  // Comprueba si los datos de las columnas no están vacíos
  bool isColumnDataNotEmpty() {
    return columnNames.isNotEmpty && data.isNotEmpty;
  }

  // Obtiene los datos del gráfico de elbow desde la API
  void fetchDataPlot() async {
    apiUrl =
    'http://127.0.0.1:5000/kmeans-elbow?n_components=$components&scaler_type=$selectedScaler';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        imageElbow = response.bodyBytes;
        isLoadingPlot = true;
      });
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  // Obtiene los datos del conjunto de datos desde la API
  void fetchData() async {
    setState(() {
      isLoadingData = true; // Establece el indicador de carga de datos en true
    });

    apiUrl =
    'http://127.0.0.1:5000/kmeans?n_clusters=$components&scaler_type=$selectedScaler';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        columnNames = List<String>.from(jsonData['column_names']);
        columnNames.sort();
        data = List<Map<String, dynamic>>.from(jsonData['data']);
        isDataLoaded = true;
        columnNamesCentroide =
        List<String>.from(jsonData['column_names_centroide']);
        columnNamesCentroide.sort();
        dataCentroide = List<Map<String, dynamic>>.from(jsonData['data_centroide']);
        columnNamesCount = List<String>.from(jsonData['column_names_count']);
        columnNamesCount.sort();
        dataCount = List<Map<String, dynamic>>.from(jsonData['data_count']);

        encodedImage = jsonData['kmeans_image'];

        isLoadingData = false; // Establece el indicador de carga de datos en false
      });
      predictImage = base64Decode(encodedImage);
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  // Guarda los datos del conjunto de datos en formato CSV
  void saveDataCSV(String name,String type,int n) async{
    String apiUrl = 'http://127.0.0.1:5000/guardar-data-frame?file_path=$name.csv&scaler_type=$type&n_clusters=$n';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        // La solicitud fue exitosa y se recibió la imagen
        //= response.body;
      });
    } else {
      throw Exception('Error al guardar el modelo');
    }
  }

  // Muestra un diálogo para guardar el conjunto de datos
  Future<void> saveDataframe() async {
    final textFieldController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Guardar dataframe'),
          content: TextField(
            controller: textFieldController,
            decoration: InputDecoration(
              hintText: 'Nombre de archivo',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                savedFileName = textFieldController.text;
                saveDataCSV(savedFileName,selectedScaler,components);
                Navigator.of(context).pop();
              },
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
        title: Text('Modelo de Kmeans'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
            children: [
              Text(
                'K-means para Clustering Particional',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
          Text(
            'Permite crear grupos (clusters) para organizar y segmentar datos similares '
            'dentro de ellos. Está orientado a resolver problemas de optimización.\n'
            'Como entrada, se indica el numero de clusters que quieres generar. Para '
            'escoger un número adecuado de clusters, se provee una gráfica por el método del codo '
            '(Elbow Method). El valor indicado por la línea naranja que parte al eje X '
            'es el número adecuado de clusters a ingresar.\n',
            style: TextStyle(fontSize: 16.0),
            textAlign: TextAlign.justify,
          ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: componentsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Número de clusters',
                      ),
                      onChanged: (value) {
                        setState(() {
                          components = int.tryParse(value) ?? 2;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  DropdownButton<String?>(
                    value: selectedScaler,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Colors.blueAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedScaler = newValue!;
                      });
                    },
                    items: scalerOptions.map<DropdownMenuItem<String?>>((String value) {
                      return DropdownMenuItem<String?>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      fetchData();
                    },
                    child: Text('Clusterización de datos'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 600,
                  width: MediaQuery.of(context).size.width - 32.0,
                  child: isLoadingPlot
                      ? FittedBox(
                    fit: BoxFit.fill,
                    child: Image.memory(imageElbow!),
                  )
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
              SizedBox(height: 16.0),
              isLoadingData // Verifica si los datos se están cargando
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: isColumnDataNotEmpty() && isDataLoaded
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Head de datos clusterizados en columna ClusterP',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'La siguiente gráfica muestra a que cluster se agrupó la celda '
                      'con relación a la columna ClusterP. Los clusteres comienzan con '
                      'una notación en 0 y avanza segun el numero de clusteres definidos.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    DataTable(
                      // DataTable Completa
                      columns: columnNames.map((name) {
                        return DataColumn(
                          label: Text(
                            name,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      rows: data.asMap().entries.map((entry) {
                        final index = entry.key;
                        final rowData = entry.value;
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                            }
                            if (index % 2 == 1) {
                              // Filas pares (empezando desde el índice 0)
                              return Colors.grey.withOpacity(0.3);
                            }
                            return null;
                          }),
                          cells: rowData.entries.map((entry) {
                            return DataCell(Text(entry.value.toString()));
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ],
                )
                    : Container(),
              ),
              SizedBox(height: 16.0),
              isLoadingData // Verifica si los datos se están cargando
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: isColumnDataNotEmpty() && isDataLoaded
                    ? Column(
                  children: [
                    Text(
                      'Conteo de agrupaciones por clusteres',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Se observa cuántos elementos tiene en total cada cluster',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    DataTable(
                      columns: columnNamesCount.map((name) {
                        return DataColumn(
                          label: Text(
                            name,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      rows: dataCount.asMap().entries.map((entry) {
                        final index = entry.key;
                        final rowData = entry.value;
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                            }
                            if (index % 2 == 1) { // Filas pares (empezando desde el índice 0)
                              return Colors.grey.withOpacity(0.3);
                            }
                            return null;
                          }),
                          cells: rowData.entries.map((entry) {
                            return DataCell(Text(entry.value.toString()));
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ],
                )
                    : Container(),
              ),
              SizedBox(height: 16.0),
              isLoadingData // Verifica si los datos se están cargando
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: isColumnDataNotEmpty() && isDataLoaded
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      child: Text(
                        "Centroides y valores de cada cluster creado",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataTable(
                      columns: columnNamesCentroide.map((name) {
                        return DataColumn(
                          label: Text(
                            name,
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      rows: dataCentroide.asMap().entries.map((entry) {
                        final index = entry.key;
                        final rowData = entry.value;
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                            }
                            if (index % 2 == 1) { // Filas pares (empezando desde el índice 0)
                              return Colors.grey.withOpacity(0.3);
                            }
                            return null;
                          }),
                          cells: rowData.entries.map((entry) {
                            return DataCell(Text(entry.value.toString()));
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ],
                )
                    : Container(),
              ),
              SizedBox(height: 16.0),
              if (encodedImage != '') ...[
                SizedBox(height: 16.0),
                Text(
                    "Gráfica de elementos y Centros del Cluster",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                ),
                Image.memory(predictImage),
              ],
              SizedBox(height: 16.0),
              if (!isLoadingData && isDataLoaded) ...[
                Center(
                  child: ElevatedButton(
                    onPressed: saveDataframe,
                    child: Text('Guardar dataframe'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
