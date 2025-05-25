import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'state/state.dart';
import 'screens/login.dart';
import 'screens/home.dart';

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
        title: 'Namer App',
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Configurar la animación
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

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

      if (session != null) {
        // Configurar el usuario activo en el estado global
        appState.setActiveUser(session.user.email!);

        // Redirigir a MyHomePage si hay un usuario autenticado
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        // Si no hay usuario autenticado, redirigir al LoginPage
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
          // Fondo degradado azul oscuro (igual que login pero más profundo)
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A2636), // Azul más oscuro arriba
                  Color(0xFF283E51), // Azul intermedio abajo
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                ScaleTransition(
                  scale: _animation,
                  child: Image.asset(
                    'assets/icon.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                SizedBox(height: 32),
                // Texto "Cargando..."
                Text(
                  'Cargando...',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 16),
                // Nombre de la app grande
                Text(
                  'EdificApp',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black38,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                // Spinner
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 48),
                // Nombre de la alumna aún más grande
                Text(
                  'Magali Gracia',
                  style: TextStyle(
                    fontSize: 40, // Más grande
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 18),
                // Comisión aún más grande
                Text(
                  'A141-1',
                  style: TextStyle(
                    fontSize: 54, // Mucho más grande
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.1,
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
