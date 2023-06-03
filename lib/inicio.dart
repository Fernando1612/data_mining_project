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
  Uint8List? _csvBytes; // Bytes del archivo CSV seleccionado
  List<List<dynamic>>? _csvData; // Datos del archivo CSV convertidos en una matriz
  String? _message; // Mensaje para mostrar el estado del archivo

  Future<void> _openFileExplorer() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _csvBytes = result.files.single.bytes!; // Obtener los bytes del archivo seleccionado
        uploadFile(_csvBytes as List<int>); // Subir el archivo al servidor
        _csvData = CsvToListConverter().convert(utf8.decode(_csvBytes!)); // Convertir los bytes del archivo en una matriz de datos
        _message = 'Archivo cargado con éxito.'; // Actualizar el mensaje de estado
      });
    }
  }

  void uploadFile(List<int> fileBytes) async {
    String url = 'http://127.0.0.1:5000/upload'; // Cambia esto por la URL de tu servidor Flask
    var request = http.MultipartRequest('POST', Uri.parse(url)); // Crear una solicitud HTTP POST multipart
    request.files.add(
      http.MultipartFile.fromBytes(
        'archivo',
        fileBytes,
        filename: 'data.csv',
      ),
    ); // Agregar el archivo como un campo multipart en la solicitud
    var response = await request.send(); // Enviar la solicitud
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_csvBytes == null)
              const Text('No se ha cargado ningún archivo.')
            else
              Column(
                children: [
                  if (_message != null)
                    Text(
                      _message!,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ElevatedButton(
              onPressed: _openFileExplorer,
              child: const Text('Cargar archivo CSV'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                textStyle: TextStyle(fontSize: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
