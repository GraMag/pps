import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart'; // Importa esto para SystemChrome
import 'state/state.dart';
import 'screens/login.dart';
import 'screens/home.dart'; // Importar la nueva pantalla de dificultad

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevenir que la pantalla se gire
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Solo orientación vertical
  ]);

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
        title: 'QR Saldo',
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
    final appState = context.read<MyAppState>();
    try {
      await appState.loadPhotos();
      final session = supabase.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final iconSize = size.shortestSide * 0.22;
                final nameFont = size.height * 0.07;
                final appFont = size.height * 0.06;
                final subFont = size.height * 0.035;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 0.9, end: 1.15).animate(
                          CurvedAnimation(
                              parent: _controller, curve: Curves.easeInOut)),
                      child: Image.asset(
                        'assets/icon.png',
                        width: iconSize,
                        height: iconSize,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Container(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Magali Gracia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: nameFont * 0.85, // levemente más chico
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Container(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'A141-1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.height * 0.11, // levemente más chico
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.07),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'QR Saldo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: appFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Tu billetera digital segura',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: subFont,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.08),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
