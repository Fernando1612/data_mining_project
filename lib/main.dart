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
      title: 'Open Mining',
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
        title: Text('Open Mining'),
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
              title: Text('Carga tu archivo'),
              onTap: () {
                // Acción al hacer clic en "Inicio"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Inicio()),
                );
              },
            ),
            ListTile(
              title: Text('Análisis Exploratorio de Datos (EDA)'),
              onTap: () {
                // Acción al hacer clic en "EDA"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExploracionDatos()),
                );
              },
            ),
            ListTile(
              title: Text('Análisis de Componentes Principales (PCA)'),
              onTap: () {
                // Acción al hacer clic en "PCA"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PCA()),
                );
              },
            ),
            ListTile(
              title: Text('Modelo: Bosques Clasificación'),
              onTap: () {
                // Acción al hacer clic en "Bosques Clasificación"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BosquesScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Modelo: Bosques Predicción'),
              onTap: () {
                // Acción al hacer clic en "Bosques Predicción"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BosquesPrediccion()),
                );
              },
            ),
            ListTile(
              title: Text('Modelo: Kmeans'),
              onTap: () {
                // Acción al hacer clic en "Kmeans"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Clasificacion()),
                );
              },
            ),
            ListTile(
              title: Text('Usar modelo generado'),
              onTap: () {
                // Acción al hacer clic en "Cargar modelo"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CargarModelo()),
                );
              },
            ),
          ],
        ),
      ),
      body: OnboardingPagePresenter(pages: [
        OnboardingPageModel(
          title: '¡Bienvenido a Open Mining!',
          description: 'A continuación te presentamos una serie de pasos para '
            'utilizar nuestra herramienta.',
          imageUrl: 'web/img/rocket.png',
          bgColor: Colors.indigo,
        ),
        OnboardingPageModel(
          title: 'Paso 1: Carga tu archivo',
          description: 'Desde nuestro menú, selecciona "Carga tu Archivo" para '
            'cargar tu set de datos. Debe ser de extensión .csv.',
          imageUrl: 'web/img/upload.png',
          bgColor: const Color(0xff1eb090),
        ),
        OnboardingPageModel(
          title: 'Paso 2: Consulta el Análisis Exploratorio',
          description:
          'En el menú, podrás observar un Análisis Exploratorio de Datos (EDA) '
            'con explicaciones de nuestra mano.',
          imageUrl: 'web/img/analyze.png',
          bgColor: const Color(0xfffeae4f),
        ),
        OnboardingPageModel(
          title: 'Paso 3: Elige y entrena tu modelo',
          description: 'Acorde a tu set de datos podrás elegir uno de nuestros '
            'modelos disponibles. ¡Selecciona, configura y observa!',
          imageUrl: 'web/img/modelate.png',
          bgColor: Colors.purple,
        ),
        OnboardingPageModel(
          title: 'Paso 4: Guarda tu modelo',
          description: 'Generamos un archivo .pkl (Pickle File) del modelo '
              'entrenado que puedes guardar. ¡Las gráficas también son descargables!',
          imageUrl: 'web/img/save.png',
          bgColor: const Color(0xFF6E40D2),
        ),
      ]),
    );
  }
}

class OnboardingPagePresenter extends StatefulWidget {
  final List<OnboardingPageModel> pages;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;

  const OnboardingPagePresenter(
      {Key? key, required this.pages, this.onSkip, this.onFinish})
      : super(key: key);

  @override
  State<OnboardingPagePresenter> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPagePresenter> {
  // Store the currently visible page
  int _currentPage = 0;
  // Define a controller for the pageview
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: widget.pages[_currentPage].bgColor,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                // Pageview to render each page
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.pages.length,
                  onPageChanged: (idx) {
                    // Change current page when pageview changes
                    setState(() {
                      _currentPage = idx;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final item = widget.pages[idx];
                    return Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Image.network(
                              item.imageUrl,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: item.textColor,
                                    )),
                              ),
                              Container(
                                constraints:
                                const BoxConstraints(maxWidth: 320),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 8.0),
                                child: Text(item.description,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      color: item.textColor,
                                    )),
                              )
                            ]))
                      ],
                    );
                  },
                ),
              ),

              // Current page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pages
                    .map((item) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _currentPage == widget.pages.indexOf(item)
                      ? 30
                      : 8,
                  height: 8,
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                ))
                    .toList(),
              ),

              // Bottom buttons
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.comfortable,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          if (_currentPage > 0 ) {
                            _pageController.animateToPage(_currentPage - 1,
                                curve: Curves.easeInOutCubic,
                                duration: const Duration(milliseconds: 250));
                          } else {
                            widget.onFinish?.call();
                          }
                        },
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Icon(_currentPage == 0
                                  ? Icons.done
                                  : Icons.arrow_back),
                              Text(
                                _currentPage > 0
                                    ? "Atrás"
                                    : "",
                              ),]
                          ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.comfortable,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (_currentPage == widget.pages.length - 1) {
                          widget.onFinish?.call();
                        } else {
                          _pageController.animateToPage(_currentPage + 1,
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 250));
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            _currentPage == widget.pages.length - 1
                                ? ""
                                : "Siguiente",
                          ),
                          const SizedBox(width: 8),
                          Icon(_currentPage == widget.pages.length - 1
                              ? Icons.done
                              : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPageModel {
  final String title;
  final String description;
  final String imageUrl;
  final Color bgColor;
  final Color textColor;

  OnboardingPageModel(
      {required this.title,
        required this.description,
        required this.imageUrl,
        this.bgColor = Colors.blue,
        this.textColor = Colors.white});
}