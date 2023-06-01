import 'dart:typed_data';

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
  bool isLoadingPlot = false;
  TextEditingController componentsController = TextEditingController();
  int components = 2;
  String selectedScaler = 'StandardScaler';
  List<String> scalerOptions = ['StandardScaler', 'MinMaxScaler', 'Normalizer'];
  double? varianza;
  late Uint8List? imagePCA;

  @override
  void initState() {
    super.initState();
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });

    apiUrl = 'http://127.0.0.1:5000/pca?n_components=$components&scaler_type=$selectedScaler';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        columnNames = List<String>.from(jsonData['column_names']);
        data = List<Map<String, dynamic>>.from(jsonData['data']);
        varianza = jsonData['varianza'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  void fetchDataPlot() async {
    apiUrl = 'http://127.0.0.1:5000/pca-plot?n_components=$components&scaler_type=$selectedScaler';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        // La solicitud fue exitosa y se recibió la imagen
        imagePCA = response.bodyBytes;
        isLoadingPlot = true;
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
      body: SingleChildScrollView(
        child: Container(
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
                        labelText: 'Número de componentes (Default 2)',
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
                      fetchDataPlot();
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (varianza != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Varianza obtenida con $components componentes: $varianza',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                    SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          height: 600,
                          width: MediaQuery.of(context).size.width - 32.0,
                          child: isLoadingPlot
                              ? FittedBox(
                            fit: BoxFit.fill,
                            child: Image.memory(imagePCA!),
                          )
                              : Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
