import 'package:flutter/material.dart';

import 'inicio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
              title: Text('Acerca de'),
              onTap: () {
                // Acción al hacer clic en "Acerca de"
              },
            ),
            ListTile(
              title: Text('Contacto'),
              onTap: () {
                // Acción al hacer clic en "Contacto"
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
