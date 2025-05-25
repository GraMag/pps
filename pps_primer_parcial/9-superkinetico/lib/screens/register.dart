import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
// Fondo animado tipo "comic burst"
import '../widgets/animated_comic_background.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });

    final supabase = Supabase.instance.client;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Navigator.pop(context); // Volver al LoginPage
      } else {
        _showError('Error al registrar. Intenta nuevamente.');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado tipo "comic burst"
          AnimatedComicBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: Colors.white, width: 3),
                ),
                elevation: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0), // Menos padding
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¡Registrar Nuevo Héroe! 🦸',
                            style: TextStyle(
                              fontSize: 26,
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
                          SizedBox(height: 12),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.18),
                              labelText: 'Correo Electrónico',
                              labelStyle: TextStyle(
                                color: Colors.yellowAccent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 15,
                                shadows: [
                                  Shadow(
                                      blurRadius: 4,
                                      color: Colors.black,
                                      offset: Offset(1, 2)),
                                ],
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.yellowAccent, width: 2.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.orangeAccent, width: 2.8),
                              ),
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.yellowAccent),
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                    blurRadius: 4,
                                    color: Colors.black,
                                    offset: Offset(1, 2)),
                              ],
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.18),
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 15,
                                shadows: [
                                  Shadow(
                                      blurRadius: 4,
                                      color: Colors.black,
                                      offset: Offset(1, 2)),
                                ],
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.cyanAccent, width: 2.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.blueAccent, width: 2.8),
                              ),
                              prefixIcon:
                                  Icon(Icons.lock, color: Colors.cyanAccent),
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                    blurRadius: 4,
                                    color: Colors.black,
                                    offset: Offset(1, 2)),
                              ],
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 18),
                          isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 18,
                                    ),
                                  ),
                                  child: Text(
                                    'Registrar',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Volver al LoginPage
                            },
                            child: Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
