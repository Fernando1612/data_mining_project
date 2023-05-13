import 'package:data_mining_project/widgets/tasks.dart';
import 'package:flutter/material.dart';

class Acerca extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de'),
      ),
      body: TasksWidget(),
    );
  }
}
