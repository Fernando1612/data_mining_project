import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Clasificacion extends StatefulWidget {
  @override
  _ClasificacionState createState() => _ClasificacionState();
}

class _ClasificacionState extends State<Clasificacion> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clasificación'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
            ],
          ),
        ),
      ),
    );
  }
}