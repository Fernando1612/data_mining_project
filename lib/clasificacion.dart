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
  String apiUrl = '';
  List<String> columnNames = [];
  List<Map<String, dynamic>> data = [];
  bool isDataLoaded = false;
  bool isLoadingPlot = false;
  bool isLoadingData = false; // Track loading data state
  TextEditingController componentsController = TextEditingController();
  int components = 2;
  String selectedScaler = 'StandardScaler';
  List<String> scalerOptions = ['StandardScaler', 'MinMaxScaler', 'Normalizer'];
  late Uint8List? imageElbow;
  List<String> columnNamesCentroide = [];
  List<Map<String, dynamic>> dataCentroide = [];
  List<String> columnNamesCount = [];
  List<Map<String, dynamic>> dataCount = [];
  late Uint8List predictImage;
  String encodedImage = '';

  late String savedFileName;

  @override
  void initState() {
    super.initState();
    fetchDataPlot();
  }

  isColumnDataNotEmpty() {
    return columnNames.isNotEmpty && data.isNotEmpty;
  }

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
      throw Exception('Failed to fetch data');
    }
  }

  void fetchData() async {
    setState(() {
      isLoadingData = true; // Set loading data state to true
    });

    apiUrl = 'http://127.0.0.1:5000/kmeans?n_clusters=$components&scaler_type=$selectedScaler';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        columnNames = List<String>.from(jsonData['column_names']);
        columnNames.sort();
        data = List<Map<String, dynamic>>.from(jsonData['data']);
        isDataLoaded = true;
        columnNamesCentroide = List<String>.from(jsonData['column_names_centroide']);
        columnNamesCentroide.sort();
        dataCentroide = List<Map<String, dynamic>>.from(jsonData['data_centroide']);
        columnNamesCount = List<String>.from(jsonData['column_names_count']);
        columnNamesCount.sort();
        dataCount = List<Map<String, dynamic>>.from(jsonData['data_count']);

        encodedImage = jsonData['kmeans_image'];

        isLoadingData = false; // Set loading data state to false
      });
      predictImage = base64Decode(encodedImage);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  void saveDataCSV(String name,String type,int n) async{
    String apiUrl = 'http://127.0.0.1:5000/guardar-data-frame?file_path=$name.csv&scaler_type=$type&n_clusters=$n';
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
        title: Text('Kmeans'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: componentsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
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
              isLoadingData // Check if data is loading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: isColumnDataNotEmpty() && isDataLoaded
                    ? DataTable(
                  columns: columnNames
                      .map((name) => DataColumn(label: Text(name)))
                      .toList(),
                  rows: data.map((rowData) {
                    return DataRow(
                      cells: rowData.entries.map((entry) {
                        return DataCell(Text(entry.value.toString()));
                      }).toList(),
                    );
                  }).toList(),
                )
                    : Container(),
              ),
              SizedBox(height: 16.0),
              isLoadingData // Check if data is loading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: isColumnDataNotEmpty() && isDataLoaded
                    ? DataTable(
                  columns: columnNamesCount
                      .map((name) => DataColumn(label: Text(name)))
                      .toList(),
                  rows: dataCount.map((rowData) {
                    return DataRow(
                      cells: rowData.entries.map((entry) {
                        return DataCell(Text(entry.value.toString()));
                      }).toList(),
                    );
                  }).toList(),
                )
                    : Container(),
              ),
              SizedBox(height: 16.0),
              isLoadingData // Check if data is loading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: isColumnDataNotEmpty() && isDataLoaded
                    ? DataTable(
                  columns: columnNamesCentroide
                      .map((name) => DataColumn(label: Text(name)))
                      .toList(),
                  rows: dataCentroide.map((rowData) {
                    return DataRow(
                      cells: rowData.entries.map((entry) {
                        return DataCell(Text(entry.value.toString()));
                      }).toList(),
                    );
                  }).toList(),
                )
                    : Container(),
              ),
              SizedBox(height: 16.0),
              if (encodedImage != '') ...[
                SizedBox(height: 16.0),
                Image.memory(predictImage),
              ],
              SizedBox(height: 16.0),
              if (!isLoadingData && isDataLoaded) ...[
                ElevatedButton(
                  onPressed: saveDataframe,
                  child: Text('Guardar dataframe'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
