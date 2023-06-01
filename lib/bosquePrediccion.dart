import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BosquesPrediccion extends StatefulWidget {
  @override
  _BosquesPrediccionState createState() => _BosquesPrediccionState();
}

class _BosquesPrediccionState extends State<BosquesPrediccion> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bosques Predicción'),
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