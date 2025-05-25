import 'dart:async';
import 'package:superkinetico/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'state/state.dart';
import 'screens/login.dart';
import 'widgets/animated_comic_background.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 Fijar orientación a vertical (para evitar que se reinicie el widget al rotar)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inicializar Supabase
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
        title: 'SuperKinetico',
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 2)); // ⏳ Espera 2 segundos

      try {
        final session = supabase.auth.currentSession;

        if (session != null) {
          // Actualizar el estado global con el usuario activo
          final user = session.user;
          final appState = context.read<MyAppState>();
          appState.activeUser = user.email;

          // Validar si hay una contraseña almacenada
          if (appState.userPassword == null) {
            // Si no hay contraseña, redirigir al LoginPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            // Si hay contraseña, redirigir al Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          }
        } else {
          // Si no hay sesión activa, redirigir al LoginPage
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
    });
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
        fit: StackFit.expand,
        children: [
          AnimatedComicBackground(),
          // Fondo borroso sobre todo el splash
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.18),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: _animation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icon.png',
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Solo el texto principal, sin fondo borroso
                const Text(
                  '¡Cargando SuperKinetico! ⚡',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      // Solo el texto de comisión, sin fondo borroso
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'A141-1',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.6),
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Solo el texto de nombre, sin fondo borroso
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Magali Gracia',
                          style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.6),
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
