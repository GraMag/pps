import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/difficulty.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlipCard extends StatelessWidget {
  final String imagePath; // Ruta de la imagen
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;

  FlipCard({
    required this.imagePath,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationYTransition(
            child: child,
            animation: animation,
          );
        },
        child: isFlipped || isMatched
            ? Container(
                key: ValueKey(true),
                width: double
                    .infinity, // Asegurar que ocupe todo el ancho disponible
                height: double
                    .infinity, // Asegurar que ocupe todo el alto disponible
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit
                        .contain, // Ajustar la imagen para que entre completamente
                  ),
                ),
              )
            : Container(
                key: ValueKey(false),
                width: double
                    .infinity, // Asegurar que ocupe todo el ancho disponible
                height: double
                    .infinity, // Asegurar que ocupe todo el alto disponible
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String difficulty;

  MyHomePage({required this.difficulty});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<dynamic> numbers;
  late List<bool> isMatched;
  late List<bool> isFlipped;
  int? firstSelectedIndex;
  int? secondSelectedIndex;
  bool isChecking = false;

  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancelar el temporizador al salir de la pantalla
    super.dispose();
  }

  void _initializeGame() {
    final cardCount = _getCardCount();
    final pairs = (cardCount / 2).floor();

    // Generar rutas de imágenes según la dificultad
    final basePath = _getAssetPath();
    numbers = List.generate(pairs, (index) => '$basePath${index + 1}.png') +
        List.generate(pairs, (index) => '$basePath${index + 1}.png');
    numbers.shuffle();

    isMatched = List.filled(cardCount, false);
    isFlipped = List.filled(cardCount, false);
    firstSelectedIndex = null;
    secondSelectedIndex = null;
    isChecking = false;
    _elapsedSeconds = 0; // Reiniciar el temporizador
  }

  String _getAssetPath() {
    switch (widget.difficulty) {
      case 'Fácil':
        return 'assets/animals/';
      case 'Medio':
        return 'assets/tools/';
      case 'Difícil':
        return 'assets/fruits/';
      default:
        return 'assets/animals/';
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        // Verificar si el widget está montado
        setState(() {
          _elapsedSeconds++;
        });
      } else {
        _timer
            .cancel(); // Cancelar el temporizador si el widget ya no está montado
      }
    });
  }

  int _getCardCount() {
    switch (widget.difficulty) {
      case 'Fácil':
        return 6;
      case 'Medio':
        return 10;
      case 'Difícil':
        return 16;
      default:
        return 6;
    }
  }

  void _onCardTap(int index) {
    if (isChecking || isMatched[index] || isFlipped[index]) return;

    setState(() {
      isFlipped[index] = true;

      if (firstSelectedIndex == null) {
        firstSelectedIndex = index;
      } else if (secondSelectedIndex == null && firstSelectedIndex != index) {
        secondSelectedIndex = index;
        isChecking = true;

        if (numbers[firstSelectedIndex!] == numbers[secondSelectedIndex!]) {
          setState(() {
            isMatched[firstSelectedIndex!] = true;
            isMatched[secondSelectedIndex!] = true;
          });

          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              firstSelectedIndex = null;
              secondSelectedIndex = null;
              isChecking = false;
            });

            if (isMatched.every((matched) => matched)) {
              _timer.cancel(); // Detener el temporizador al ganar
              _saveScore(_elapsedSeconds);

              // Mostrar el cuadro de diálogo de felicitaciones
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Evitar cerrar el diálogo tocando fuera
                builder: (context) {
                  return AlertDialog(
                    title: Text('¡Felicidades!'),
                    content: Text(
                      'Completaste el juego en ${_formatTime(_elapsedSeconds)}.',
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Cerrar el diálogo
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DifficultyScreen(),
                            ),
                          );
                        },
                        child: Text('Aceptar'),
                      ),
                    ],
                  );
                },
              );
            }
          });
        } else {
          Future.delayed(Duration(milliseconds: 1000), () {
            setState(() {
              isFlipped[firstSelectedIndex!] = false;
              isFlipped[secondSelectedIndex!] = false;
              firstSelectedIndex = null;
              secondSelectedIndex = null;
              isChecking = false;
            });
          });
        }
      }
    });
  }

  Future<void> _saveScore(int timeInSeconds) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint('No hay un usuario logueado.');
      return;
    }

    final now = DateTime.now();
    final formattedDate =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    try {
      final response = await supabase.from('scores').insert({
        'user_name': user.email, // Guardar el correo electrónico del usuario
        'time': timeInSeconds,
        'date': formattedDate,
        'difficulty': widget.difficulty, // Guardar la dificultad seleccionada
      });

      if (response.error != null) {
        debugPrint('Error al guardar el puntaje: ${response.error!.message}');
      } else {
        debugPrint('Puntaje guardado exitosamente.');
      }
    } catch (e) {
      debugPrint('Error al guardar el puntaje: $e');
    }
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardCount = _getCardCount();
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final crossAxisCount = isPortrait ? 2 : (cardCount / 2).ceil();
    final rowCount = (cardCount / crossAxisCount).ceil();

    final availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight -
        MediaQuery.of(context).padding.bottom;

    final availableWidth = MediaQuery.of(context).size.width - 16;

    final cardWidth =
        (availableWidth - ((crossAxisCount - 1) * 8)) / crossAxisCount;
    final cardHeight = ((availableHeight - ((rowCount - 1) * 8)) / rowCount) *
        0.97; // Reducir ligeramente el alto

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _getAppBarColor(widget.difficulty),
        elevation: 1, // Sombra ligera
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribuir elementos
          children: [
            // Botón "Atrás"
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DifficultyScreen()),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // Eliminar padding
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  SizedBox(width: 4),
                  Text(
                    'Atrás',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Contador en el centro
            Text(
              _formatTime(_elapsedSeconds),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            // Botón "Reiniciar"
            TextButton(
              onPressed: _restartGame,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // Eliminar padding
              ),
              child: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.white, size: 24),
                  SizedBox(width: 4),
                  Text(
                    'Reiniciar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Fondo de burbujas fijo (como ScoresScreen)
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _BubblesPainter(0.3), // valor fijo
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              clipBehavior: Clip.none,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: cardWidth / cardHeight,
              ),
              itemCount: cardCount,
              itemBuilder: (context, index) {
                return FlipCard(
                  imagePath: numbers[index],
                  isFlipped: isFlipped[index],
                  isMatched: isMatched[index],
                  onTap: () => _onCardTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Color _getAppBarColor(String difficulty) {
    switch (difficulty) {
      case 'Fácil':
        return Colors.green;
      case 'Medio':
        return Colors.orange;
      case 'Difícil':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class RotationYTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const RotationYTransition({required this.child, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 3.14159;
        return Transform(
          transform: Matrix4.rotationY(angle),
          alignment: Alignment.center,
          child: animation.value > 0.5
              ? Transform(
                  transform: Matrix4.rotationY(3.14159),
                  alignment: Alignment.center,
                  child: child,
                )
              : child,
        );
      },
      child: child,
    );
  }
}

// Fondo de burbujas fijo
class _BubblesPainter extends CustomPainter {
  final double progress;
  _BubblesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.pinkAccent,
      Colors.yellow,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
    ];
    final random = [0.1, 0.3, 0.5, 0.7, 0.85, 0.95];
    for (int i = 0; i < colors.length; i++) {
      final dx = size.width * random[i];
      final dy = size.height * ((random[i] + progress) % 1.0);
      final radius = 60.0 + 30.0 * (1 + (progress + i * 0.2) % 1.0);
      final paint = Paint()..color = colors[i].withOpacity(0.25);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter oldDelegate) => false;
}
