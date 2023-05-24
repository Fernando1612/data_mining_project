import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PCA extends StatefulWidget {
  @override
  _PCAState createState() => _PCAState();
}

class _PCAState extends State<PCA> {
  String apiUrl = '';
  List<String> columnNames = [];
  List<Map<String, dynamic>> data = [];
  bool isLoading = false;
  TextEditingController componentsController = TextEditingController();
  int components = 2;

  @override
  void initState() {
    super.initState();
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });

    apiUrl = 'http://127.0.0.1:5000/pca?n_components=$components';

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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: componentsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Número de componentes',
                    ),
                    onChanged: (value) {
                      setState(() {
                        components = int.tryParse(value) ?? 2;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    fetchData();
                  },
                  child: Text('Obtener datos'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (isLoading)
              CircularProgressIndicator()
            else if (data.isEmpty)
              Text('Presiona el botón para obtener los datos.')
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: DataTable(
                      columns: columnNames
                          .map(
                            (name) => DataColumn(
                          label: Center(
                            child: Text(
                              name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      rows: data
                          .sublist(0, 10)
                          .map(
                            (rowData) => DataRow(
                          cells: rowData.entries
                              .map(
                                (entry) => DataCell(
                              Center(
                                child: Text(entry.value.toString()),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
