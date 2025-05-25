import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'state/state.dart';
import 'screens/login.dart';
import 'screens/difficulty.dart'; // Importar la nueva pantalla de dificultad

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://rwkyemcyvgsbrqrrykpe.supabase.co', // Reemplaza con tu URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3a3llbWN5dmdzYnJxcnJ5a3BlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY0MDI0ODYsImV4cCI6MjA2MTk3ODQ4Nn0.XSGZoTy0GAn8K5ct3G5JjdaMkd64DWDa2FawbS-R5zw', // Reemplaza con tu clave anónima
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Memojuego',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: SplashScreen(), // Iniciar con el SplashScreen
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final supabase = Supabase.instance.client;
    final appState = context.read<MyAppState>();

    try {
      // Cargar las fotos desde Supabase
      await appState.loadPhotos();

      // Verificar si hay un usuario autenticado
      final session = supabase.auth.currentSession;
      final isActiveUser =
          appState.activeUser != null && appState.activeUser!.isNotEmpty;

      if (session != null && isActiveUser) {
        // Si hay un usuario autenticado y activo, redirigir a la pantalla de selección de dificultad
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DifficultyScreen()),
        );
      } else {
        // Si no hay usuario autenticado o no hay usuario activo, redirigir al LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      // Manejar errores (opcional)
      print('Error durante la inicialización: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado con círculos de colores vivos
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _BubblesPainter(_controller.value),
              );
            },
          ),
          Center(
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _OutlinedText(
                        text: 'Magali Gracia',
                        fontSize: MediaQuery.of(context).size.width *
                            0.16, // Más grande
                        color: Colors.deepPurpleAccent, // más intenso
                        outlineColor: Colors.black,
                        outlineWidth: 7, // Más grueso
                        glowColor:
                            Colors.deepPurple.shade900, // glow oscuro intenso
                        glowBlur: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0), // sin padding horizontal
                    child: FittedBox(
                      fit: BoxFit.fitWidth, // que ocupe todo el ancho
                      child: _OutlinedText(
                        text: 'A141-1',
                        fontSize: MediaQuery.of(context).size.width *
                            0.22, // aún más grande
                        color: Colors.amber.shade700,
                        outlineColor: Colors.black,
                        outlineWidth: 7,
                        glowColor: Colors.orange.shade900,
                        glowBlur: 18,
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Icono fijo (sin animación)
                  Image.asset(
                    'assets/icon.png',
                    width: MediaQuery.of(context).size.width * 0.40,
                    height: MediaQuery.of(context).size.width * 0.40,
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _OutlinedText(
                        text: '¡Bienvenidos a Memojuego!',
                        fontSize: MediaQuery.of(context).size.width * 0.09,
                        color: Colors.cyanAccent.shade400, // azul intenso
                        outlineColor: Colors.black,
                        outlineWidth: 5,
                        glowColor: Colors.blue.shade900, // azul oscuro intenso
                        glowBlur: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dibuja burbujas de colores animadas
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
      final dy =
          size.height * ((random[i] + progress) % 1.0); // animación vertical
      final radius = 60.0 + 30.0 * (1 + (progress + i * 0.2) % 1.0);
      final paint = Paint()..color = colors[i].withOpacity(0.35);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Texto con contorno para máxima legibilidad
class _OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color outlineColor;
  final double outlineWidth;
  final Color? glowColor;
  final double? glowBlur;

  const _OutlinedText({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.outlineColor,
    required this.outlineWidth,
    this.glowColor,
    this.glowBlur,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outline
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = outlineColor,
            letterSpacing: 2,
          ),
        ),
        // Glow (debajo del fill)
        if (glowColor != null && glowBlur != null)
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: glowColor,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  blurRadius: glowBlur!,
                  color: glowColor!,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        // Fill
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 2,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black26,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
