import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ExploracionDatos extends StatefulWidget {
  @override
  _ExploracionDatosState createState() => _ExploracionDatosState();
}

class _ExploracionDatosState extends State<ExploracionDatos> {
  String apiUrl= 'http://127.0.0.1:5000/data-preview';
  List<String> columnNames = [];
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        columnNames = List<String>.from(jsonData['column_names']);
        data = List<Map<String, dynamic>>.from(jsonData['data']);
      });
    } else {
      throw Exception('Failed to fetch data');
    }
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
    );
  }
}
