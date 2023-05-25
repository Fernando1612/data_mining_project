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

  // Variables para Tabla de EDA
  List<String> columnNames = [];
  List<Map<String, dynamic>> data = [];

  // Variables para Tabla de Estadisticas
  List<String> columnNamesStats = [];
  List<Map<String, dynamic>> dataStats = [];
  List<String> indexNameStats = [];

  // Variables para Tabla de Nulls
  List<String> columnNamesNulls = ['Columnas', 'Valores Nulos'];
  List<Map<String, dynamic>> dataNull = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataPreview();
    fetchDataStats();
    fetchDataNulls();
  }

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

  Future<void> fetchDataNulls() async {
    try {
      final response = await http.get(Uri.parse(apiUrlNulls));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
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
              SizedBox(height: 16.0),
              const Text(
                'Head preliminar de los datos',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                      .map((name) => DataColumn(label: Text(name)))
                      .toList(),
                  rows: data.map((rowData) {
                    return DataRow(
                      cells: rowData.entries.map((entry) {
                        return DataCell(Text(entry.value.toString()));
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Estadísticas de los datos',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              columnNamesStats.isNotEmpty && dataStats.isNotEmpty
                  ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('index')),
                    ...columnNamesStats.map(
                          (name) => DataColumn(label: Text(name)),
                    ),
                  ],
                  rows: dataStats.asMap().entries.map(
                        (entry) {
                      int index = entry.key;
                      Map<String, dynamic> rowData = entry.value;
                      return DataRow(
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
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              columnNamesNulls.isNotEmpty && dataNull.isNotEmpty
                  ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: columnNamesNulls
                      .map((name) => DataColumn(label: Text(name)))
                      .toList(),
                  rows: dataNull.map((rowData) {
                    return DataRow(
                      cells: rowData.entries.map((entry) {
                        return DataCell(Text(entry.value.toString()));
                      }).toList(),
                    );
                  }).toList(),
                ),
              )
                  : Container(
                child: Text('No hay datos de nulls disponibles.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
