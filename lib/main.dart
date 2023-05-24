import 'package:data_mining_project/exploracion.dart';
import 'package:data_mining_project/pca.dart';
import 'package:flutter/material.dart';
import 'bosques.dart';
import 'inicio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Página Principal',
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
        title: Text('Mi Página Principal'),
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
              title: Text('Bosques'),
              onTap: () {
                // Acción al hacer clic en "Contacto"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BosquesScreen()
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          '¡Bienvenido a mi página principal!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
