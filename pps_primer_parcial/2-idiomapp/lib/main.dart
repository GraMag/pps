import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'state/state.dart';
import 'screens/login.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rwkyemcyvgsbrqrrykpe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3a3llbWN5dmdzYnJxcnJ5a3BlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY0MDI0ODYsImV4cCI6MjA2MTk3ODQ4Nn0.XSGZoTy0GAn8K5ct3G5JjdaMkd64DWDa2FawbS-R5zw',
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
        title: 'IdiomApp',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily:
              'ComicNeue', // Usa una fuente amigable (agrega en pubspec.yaml)
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: SplashScreen(),
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final supabase = Supabase.instance.client;
    final appState = context.read<MyAppState>();

    try {
      await appState.loadPhotos();
      final session = supabase.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
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
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: Stack(
        children: [
          // Fondo colorido con degradado y círculos
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Curso muy grande
                Text(
                  'A141-1',
                  style: TextStyle(
                    fontSize: width * 0.18, // Muy grande, casi todo el ancho
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                          blurRadius: 0,
                          color: Colors.black,
                          offset: Offset(0, 0)), // Borde negro
                      Shadow(blurRadius: 6, color: Colors.white),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                // Nombre muy grande
                Text(
                  'Magali Gracia',
                  style: TextStyle(
                    fontSize: width * 0.10, // Grande, pero menos que el curso
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                          blurRadius: 0,
                          color: Colors.black,
                          offset: Offset(0, 0)), // Borde negro
                      Shadow(blurRadius: 4, color: Colors.white),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 32),
                ScaleTransition(
                  scale: _animation,
                  child: Image.asset(
                    'assets/icon.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                SizedBox(height: 24),
                // Nombre de la app muy grande
                Text(
                  'IdiomApp',
                  style: TextStyle(
                    fontSize: width * 0.13, // Muy grande
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                    shadows: [
                      Shadow(
                          blurRadius: 0,
                          color: Colors.black,
                          offset: Offset(0, 0)), // Borde negro
                      Shadow(blurRadius: 6, color: Colors.white),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Text(
                  'Aprender es divertido',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.pink[400],
                    shadows: [
                      Shadow(
                          blurRadius: 0,
                          color: Colors.black,
                          offset: Offset(0, 0)), // Borde negro
                    ],
                  ),
                ),
                SizedBox(height: 32),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para círculos de colores
class _SplashPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Colors.pinkAccent.withOpacity(0.18);
    final paint2 = Paint()..color = Colors.yellowAccent.withOpacity(0.18);
    final paint3 = Paint()..color = Colors.lightBlueAccent.withOpacity(0.18);

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 90, paint1);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 70, paint2);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 110, paint3);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 50, paint1);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.6), 60, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
