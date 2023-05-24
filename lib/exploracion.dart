import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExploracionDatos extends StatefulWidget {
  @override
  _ExploracionDatosState createState() => _ExploracionDatosState();
}

class _ExploracionDatosState extends State<ExploracionDatos> {
  String apiUrl = 'http://127.0.0.1:5000/data-preview?num_rows=5';
  List<String> columnNames = [];
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataPreview();
  }

  Future<void> fetchDataPreview() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          columnNames = List<String>.from(jsonData['column_names']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EDA Data'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'EDA Data',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(), // Muestra un indicador de carga mientras los datos se están cargando
              )
                  : DataTable(
                columns: columnNames.map((name) => DataColumn(label: Text(name))).toList(),
                rows: data.map((rowData) {
                  return DataRow(
                    cells: rowData.entries.map((entry) {
                      return DataCell(Text(entry.value.toString()));
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
