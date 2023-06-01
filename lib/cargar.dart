import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CargarModelo extends StatefulWidget {
  @override
  _CargarModeloState createState() => _CargarModeloState();
}

class _CargarModeloState extends State<CargarModelo> {
  List<String> archivosPkl = [];

  @override
  void initState() {
    super.initState();
    obtenerArchivosPkl();
  }

  Future<void> obtenerArchivosPkl() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/archivos_pkl'));
      if (response.statusCode == 200) {
        setState(() {
          archivosPkl = List<String>.from(jsonDecode(response.body));
        });
      } else {
        print('Error al obtener la lista de archivos');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  void abrirVentanaArchivoSeleccionado(String archivo) {
    cargarModeloClasificador(archivo);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallesArchivoPkl(nombreArchivo: archivo),
      ),
    );
  }

  Future<void> cargarModeloClasificador(String filePath) async {
    final url = Uri.parse('http://127.0.0.1:5000/cargar-modelo-clasificador?file_path=$filePath.pkl');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'];
        print(message); // Mostrar el mensaje de respuesta en la consola
      } else {
        print('Error al cargar el modelo');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cargar Modelo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Archivos .pkl:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: archivosPkl.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(archivosPkl[index]),
                    onTap: () {
                      abrirVentanaArchivoSeleccionado(archivosPkl[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetallesArchivoPkl extends StatefulWidget {
  final String nombreArchivo;

  DetallesArchivoPkl({required this.nombreArchivo});

  @override
  _DetallesArchivoPklState createState() => _DetallesArchivoPklState();
}

class _DetallesArchivoPklState extends State<DetallesArchivoPkl> {
  List<String> columnNames = [];

  @override
  void initState() {
    super.initState();
    cargarColumnas();
  }

  Future<void> cargarColumnas() async {
    final url = Uri.parse('http://127.0.0.1:5000/cargar-column-names?file_path=${widget.nombreArchivo}.csv');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          columnNames = List<String>.from(data['column_names']);
        });
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del archivo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nombre del archivo seleccionado: ${widget.nombreArchivo}'),
            SizedBox(height: 20),
            Text('Columnas:'),
            Column(
              children: columnNames.map((columnName) => Text(columnName)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

