import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;


class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  Uint8List? _csvBytes;
  List<List<dynamic>>? _csvData;

  Future<void> _openFileExplorer() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _csvBytes = result.files.single.bytes!;
        uploadFile(_csvBytes as List<int>);
        _csvData = CsvToListConverter().convert(utf8.decode(_csvBytes!));
      });
    }
  }

  void uploadFile(List<int> fileBytes) async {
    String url = 'http://127.0.0.1:5000/upload'; // Cambia esto por la URL de tu servidor Flask
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(
      http.MultipartFile.fromBytes(
        'archivo',
        fileBytes,
        filename: 'data.csv',
      ),
    );
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Archivo enviado correctamente');
    } else {
      print('Error al enviar el archivo: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_csvBytes == null)
            const Text('No se ha cargado ningún archivo.')
          else
            Column(
              children: [
                DataTable(
                  columns: _csvData!
                      .first
                      .map((e) => DataColumn(label: Text(e.toString())))
                      .toList(),
                  rows: _csvData!
                      .skip(1)
                      .take(10)
                      .map((row) => DataRow(
                    cells: row
                        .map((cell) => DataCell(Text(cell.toString())))
                        .toList(),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ElevatedButton(
            onPressed: _openFileExplorer,
            child: const Text('Cargar archivo CSV'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
              textStyle: TextStyle(fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}
