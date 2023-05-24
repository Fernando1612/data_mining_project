import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExploracionDatos extends StatefulWidget {
  @override
  _ExploracionDatosState createState() => _ExploracionDatosState();
}

class _ExploracionDatosState extends State<ExploracionDatos> {
  List<String> columnNames = [];
  List<Map<String, dynamic>> data = [];

  Future<void> fetchDataPreview() async {
    try {
      final fetchedData = await fetchData();
      setState(() {
        columnNames = fetchedData['columnNames'];
        data = fetchedData['data'];
      });
    } catch (e) {
      // Handle the error
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/data-preview'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final columnNames = List<String>.from(jsonData['column_names']);
      final data = List<Map<String, dynamic>>.from(jsonData['data']);
      return {
        'columnNames': columnNames,
        'data': data,
      };
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exploración de Datos'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
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
    );
  }
}
