import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/state.dart';
import '../screens/login.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedTheme = 'animals'; // Tema seleccionado por defecto
  String selectedLanguage = 'es'; // Idioma seleccionado por defecto (español)

  // Palabras por tema e idioma
  final Map<String, Map<String, List<String>>> words = {
    'animals': {
      'es': ['Perro', 'Vaca', 'Gato', 'Caballo', 'Ave', 'Oveja'],
      'en': ['Dog', 'Cow', 'Cat', 'Horse', 'Bird', 'Sheep'],
      'pt': ['Cachorro', 'Vaca', 'Gato', 'Cavalo', 'Pássaro', 'Ovelha'],
    },
    'colors': {
      'es': ['Rojo', 'Azul', 'Verde', 'Amarillo', 'Negro', 'Blanco'],
      'en': ['Red', 'Blue', 'Green', 'Yellow', 'Black', 'White'],
      'pt': ['Vermelho', 'Azul', 'Verde', 'Amarelo', 'Preto', 'Branco'],
    },
    'numbers': {
      'es': ['Uno', 'Dos', 'Tres', 'Cuatro', 'Cinco', 'Seis'],
      'en': ['One', 'Two', 'Three', 'Four', 'Five', 'Six'],
      'pt': ['Um', 'Dois', 'Três', 'Quatro', 'Cinco', 'Seis'],
    },
  };

  // Colores para el tema "colors"
  final Map<String, Color> colorMap = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.yellow,
    'Black': Colors.black,
    'White': Colors.white,
  };

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playAudio(String theme, String lang, String word) async {
    final fileName = '${theme}_${lang}_${word.toLowerCase()}.mp3';
    final assetPath =
        'audio/$fileName'; // No incluyas 'assets/' al usar AssetSource

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error reproduciendo el audio: $e');
    }
  }

  Widget _buildIconButton(String assetPath, String tooltip, bool isSelected,
      VoidCallback onPressed) {
    return Container(
      decoration: isSelected
          ? BoxDecoration(
              border: Border.all(
                  color: Colors.purpleAccent, // Cambiado de naranja a violeta
                  width: 2),
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
            )
          : null, // Sin decoración si no está seleccionado
      child: SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          onPressed: onPressed,
          icon: Image.asset(assetPath),
          tooltip: tooltip,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Stack(
        children: [
          // Fondo colorido con patrón
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink[100]!,
                    Colors.lightBlue[100]!,
                    Colors.yellow[100]!
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(
                painter: _SplashPatternPainter(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Barra superior con fondo semitransparente y bordes redondeados
                Container(
                  margin: const EdgeInsets.all(12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[100]!.withOpacity(0.5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botones de cambiar idioma
                      Row(
                        children: [
                          _buildIconButton(
                            'assets/flags/spain.png',
                            'Español',
                            selectedLanguage == 'es',
                            () {
                              setState(() {
                                selectedLanguage = 'es';
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          _buildIconButton(
                            'assets/flags/uk.png',
                            'Inglés',
                            selectedLanguage == 'en',
                            () {
                              setState(() {
                                selectedLanguage = 'en';
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          _buildIconButton(
                            'assets/flags/portugal.png',
                            'Portugués',
                            selectedLanguage == 'pt',
                            () {
                              setState(() {
                                selectedLanguage = 'pt';
                              });
                            },
                          ),
                        ],
                      ),
                      // Botones de cambiar tema
                      Row(
                        children: [
                          _buildIconButton(
                            'assets/themes/colors.png',
                            'Colores',
                            selectedTheme == 'colors',
                            () {
                              setState(() {
                                selectedTheme = 'colors';
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          _buildIconButton(
                            'assets/themes/animals.png',
                            'Animales',
                            selectedTheme == 'animals',
                            () {
                              setState(() {
                                selectedTheme = 'animals';
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          _buildIconButton(
                            'assets/themes/numbers.png',
                            'Números',
                            selectedTheme == 'numbers',
                            () {
                              setState(() {
                                selectedTheme = 'numbers';
                              });
                            },
                          ),
                        ],
                      ),
                      // Botón de logout
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              await appState.logout();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            } catch (e) {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text(
                                      'Error al cerrar sesión: ${e.toString()}'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.logout, color: Colors.red),
                          tooltip: 'Cerrar sesión',
                        ),
                      ),
                    ],
                  ),
                ),
                // Botones principales que ocupan el resto de la pantalla
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0, left: 8.0, right: 8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Determinar el número de columnas y filas según la orientación
                        final isPortrait = MediaQuery.of(context).orientation ==
                            Orientation.portrait;
                        final crossAxisCount = isPortrait ? 2 : 3; // Columnas
                        final rowCount = isPortrait ? 3 : 2; // Filas
                        final buttonWidth =
                            constraints.maxWidth / crossAxisCount;
                        final buttonHeight = constraints.maxHeight / rowCount;

                        return GridView.builder(
                          physics:
                              NeverScrollableScrollPhysics(), // Evitar scroll
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                crossAxisCount, // Número de columnas
                            crossAxisSpacing: 8, // Espaciado horizontal
                            mainAxisSpacing: 8, // Espaciado vertical
                            childAspectRatio: buttonHeight > 0
                                ? buttonWidth / buttonHeight
                                : 1, // Relación de aspecto válida
                          ),
                          itemCount: 6, // Número de botones
                          itemBuilder: (context, index) {
                            final wordInEnglish =
                                words[selectedTheme]!['en']![index];

                            return Container(
                              margin: const EdgeInsets.all(
                                  4), // Margen entre botones
                              child: ElevatedButton(
                                onPressed: () {
                                  _playAudio(selectedTheme, selectedLanguage,
                                      wordInEnglish); // Llamar al método _playAudio
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedTheme == 'colors'
                                      ? colorMap[wordInEnglish] ??
                                          Colors
                                              .grey // Color del botón para colores
                                      : Colors.purple[
                                          300], // Cambiado de naranja a violeta pastel
                                  foregroundColor: selectedTheme == 'colors' &&
                                          wordInEnglish == 'White'
                                      ? Colors
                                          .black // Texto negro para botones blancos
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Bordes redondeados sutiles
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (selectedTheme ==
                                        'animals') // Mostrar imagen para animales
                                      Expanded(
                                        child: Image.asset(
                                          'assets/animals/${wordInEnglish.toLowerCase()}.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    if (selectedTheme ==
                                        'numbers') // Mostrar imagen para números
                                      Expanded(
                                        child: Image.asset(
                                          'assets/numbers/${index + 1}.png', // Cargar imágenes de números
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    if (selectedTheme ==
                                        'colors') // Mostrar color como fondo
                                      Container(
                                        width: 40,
                                        height: 40,
                                        color: colorMap[wordInEnglish] ??
                                            Colors.grey,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Implementación del patrón de fondo
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
