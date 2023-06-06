import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PCA extends StatefulWidget {
  @override
  _PCAState createState() => _PCAState();
}

class _PCAState extends State<PCA> {
  String apiUrl = '';
  List<String> columnNames = [];
  List<Map<String, dynamic>> data = [];
  bool isLoading = false;
  bool isLoadingPlot = false;
  TextEditingController componentsController = TextEditingController();
  int components = 2;
  String selectedScaler = 'StandardScaler';
  List<String> scalerOptions = ['StandardScaler', 'MinMaxScaler', 'Normalizer'];
  double? varianza;
  late Uint8List? imagePCA;

  @override
  void initState() {
    super.initState();
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });

    apiUrl = 'http://127.0.0.1:5000/pca?n_components=$components&scaler_type=$selectedScaler';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        columnNames = List<String>.from(jsonData['column_names']);
        data = List<Map<String, dynamic>>.from(jsonData['data']);
        varianza = jsonData['varianza'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  void fetchDataPlot() async {
    apiUrl = 'http://127.0.0.1:5000/pca-plot?n_components=$components&scaler_type=$selectedScaler';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        // La solicitud fue exitosa y se recibió la imagen
        imagePCA = response.bodyBytes;
        isLoadingPlot = true;
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PCA'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
            children: [
              Text(
                'Análisis de Componentes Principales (PCA)',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'El Análisis de Componentes Principales (PCA, por sus siglas en '
                  'inglés: Principal Component Analysis) es una técnica utilizada '
                  'en minería de datos y análisis de datos multivariados para '
                  'reducir la dimensionalidad de un conjunto de datos y encontrar '
                  'las variables o componentes más importantes que explican la mayor '
                  'parte de la variabilidad de los datos.\n'
                  'El PCA se utiliza con frecuencia para simplificar conjuntos '
                  'de datos complejos, eliminar variables redundantes o correlacionadas '
                  'y resaltar las relaciones y patrones subyacentes en los datos. '
                  'Al reducir la dimensionalidad de los datos, el PCA facilita el '
                  'análisis y la visualización de datos en un espacio de menor dimensión '
                  'sin perder información crítica.\n',
                textAlign: TextAlign.justify,
                style: TextStyle(
                    fontSize: 16.0),
              ),
              Text(
                'Componentes Principales',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'Introduce un número entero, que será el número de componentes '
                'principales. Esto quiere decir que se realizará un análisis '
                'para determinar la importancia de las variables en el '
                'componente principal. De no introducir un número, se tomarán '
                    'por defecto 2 variables. En general se recomienda tener '
                'entre 2 a 4 variables como componentes principales.\n',
                textAlign: TextAlign.justify,
                style: TextStyle(
                    fontSize: 16.0),
              ),
              Text(
                'Estandarización',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'La estandarización es un proceso común en el preprocesamiento '
                'de datos y se utiliza para asegurarse de que todas las '
                'variables tengan una escala similar, lo que puede ser beneficioso '
                'para muchos algoritmos de aprendizaje automático.\n'
                'La estandarización es útil cuando las características tienen '
                'diferentes escalas y se espera que tengan una distribución '
                'normal o aproximadamente normal. Al estandarizar las '
                'características, se puede evitar que las variables con valores '
                'más grandes dominen el modelo y afecten negativamente el '
                'rendimiento de algunos algoritmos de aprendizaje automático, '
                'como aquellos basados en la distancia euclidiana. A continuación '
                    'presentamos algunas de las técnicas de estadarización usadas.\n'
                    '• StandardScaler. Es una técnica utilizada para estandarizar '
                'características numéricas. Transforma los datos para que tengan '
                'una media de cero y una desviación estándar de uno. Esta técnica '
                'es útil cuando las características tienen diferentes escalas y se '
                'espera que sigan una distribución normal o aproximadamente normal.\n'
                '• MinMaxScaler. es una técnica utilizada para normalizar características '
                'numéricas en un rango específico, generalmente entre 0 y 1. '
                'Transforma los datos de tal manera que el valor mínimo de la '
                'característica se asigna a 0 y el valor máximo se asigna a 1. '
                'El MinMaxScaler es especialmente útil cuando se necesita conservar '
                'la forma de la distribución original de los datos y se desea mantener '
                'la interpretación relativa de las características.\n'
                '• Normalizer. es una técnica utilizada para normalizar las filas '
                  'de una matriz, lo que significa que cada fila se transforma '
                  'para tener una longitud de 1. Esto se logra dividiendo cada '
                  'valor de la fila por la norma (longitud) de la fila.\n',
                textAlign: TextAlign.justify,
                style: TextStyle(
                    fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                      ],
                      controller: componentsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Número de componentes (Default 2)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          components = int.tryParse(value) ?? 2;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  DropdownButton<String?>(
                    value: selectedScaler,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Colors.blueAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedScaler = newValue!;
                      });
                    },
                    items: scalerOptions.map<DropdownMenuItem<String?>>((String value) {
                      return DropdownMenuItem<String?>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 16.0),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        fetchData();
                        fetchDataPlot();
                      },
                      child: Text(
                        'Obtener datos',
                        style: TextStyle(
                          fontSize: 20.0, // Cambia el tamaño del texto
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              if (isLoading)
                CircularProgressIndicator()
              else if (data.isEmpty)
                Text('Presiona el botón para obtener los datos.')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (varianza != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Varianza obtenida con $components componentes: $varianza',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: columnNames
                            .map(
                              (name) => DataColumn(
                            label: Center(
                              child: Text(
                                name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                            .toList(),
                        rows: data
                            .sublist(0, 10)
                            .map(
                              (rowData) => DataRow(
                            cells: rowData.entries
                                .map(
                                  (entry) => DataCell(
                                Center(
                                  child: Text(entry.value.toString()),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          height: 600,
                          width: MediaQuery.of(context).size.width - 32.0,
                          child: isLoadingPlot
                              ? FittedBox(
                            fit: BoxFit.fill,
                            child: Image.memory(imagePCA!),
                          )
                              : Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
