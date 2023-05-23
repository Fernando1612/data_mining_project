import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchDataPreview() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:5000/data-preview'));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (jsonResponse is Map<String, dynamic>) {
      return jsonResponse;
    } else {
      return convertStringToFuture(jsonResponse);
    }
  } else {
    throw Exception('Failed to fetch data preview');
  }
}

Future<Map<String, dynamic>> convertStringToFuture(String jsonString) {
  Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
  return Future.value(jsonData);
}


class ExploracionDatos extends StatefulWidget {
  @override
  _ExploracionDatosState createState() => _ExploracionDatosState();
}

class _ExploracionDatosState extends State<ExploracionDatos> {
  Map<String, dynamic> dataPreview = {};

  @override
  void initState() {
    super.initState();
    fetchDataPreview().then((data) {
      setState(() {
        dataPreview = data;
      });
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exploración de Datos'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Key')),
              DataColumn(label: Text('Value')),
            ],
            rows: dataPreview.entries.map((entry) {
              String key = entry.key;
              dynamic value = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(key)),
                  DataCell(Text(value.toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
