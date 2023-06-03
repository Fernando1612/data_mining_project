import 'package:data_mining_project/clasificacion.dart';
import 'package:data_mining_project/exploracion.dart';
import 'package:data_mining_project/pca.dart';
import 'package:flutter/material.dart';
import 'bosquePrediccion.dart';
import 'bosques.dart';
import 'cargar.dart';
import 'inicio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mineria de Datos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyecto de mineria de datos'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Inicio'),
              onTap: () {
                // Acción al hacer clic en "Inicio"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Inicio()),
                );
              },
            ),
            ListTile(
              title: Text('EDA'),
              onTap: () {
                // Acción al hacer clic en "Contacto"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExploracionDatos()
                  ),
                );
              },
            ),
            ListTile(
              title: Text('PCA'),
              onTap: () {
                // Acción al hacer clic en "Contacto"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PCA()
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Bosques Clasificación'),
              onTap: () {
                // Acción al hacer clic en "Contacto"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BosquesScreen()
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Bosques Predicción'),
              onTap: () {
                // Acción al hacer clic en "Contacto"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BosquesPrediccion()
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Kmeans'),
              onTap: () {
                // Acción al hacer clic en "Contacto"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Clasificacion()
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Cargar modelo'),
              onTap: () {
                // Acción al hacer clic en "Contacto"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CargarModelo()
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Proyecto de mineria de datos',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
