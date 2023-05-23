import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PCA extends StatefulWidget {
  @override
  _PCAState createState() => _PCAState();
}

class _PCAState extends State<PCA> {
  String apiUrl = 'http://127.0.0.1:5000/pca?n_components=2';
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
        title: Text('PCA Data'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'PCA Data',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
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
          ],
        ),
      ),
    );
  }
}
