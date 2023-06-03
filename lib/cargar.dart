import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'archivoPkl.dart';

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

  // Obtener la lista de archivos .pkl disponibles en el servidor
  Future<void> obtenerArchivosPkl() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/archivos_pkl'));
      if (response.statusCode == 200) {
        setState(() {
          archivosPkl = List<String>.from(jsonDecode(response.body));
        });
      } else {
        print(response.statusCode);
        print('Error al obtener la lista de archivos');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  // Abrir la ventana de detalles del archivo seleccionado y cargar el modelo clasificador correspondiente
  void abrirVentanaArchivoSeleccionado(String archivo) {
    cargarModeloClasificador(archivo);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallesArchivoPkl(nombreArchivo: archivo),
      ),
    );
  }

  // Cargar el modelo clasificador utilizando el archivo .pkl seleccionado
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