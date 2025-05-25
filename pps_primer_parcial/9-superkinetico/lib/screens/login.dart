import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/state.dart';
import 'register.dart';
import '../widgets/animated_comic_background.dart';
import 'dart:ui';
import 'universe_select.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    final supabase = Supabase.instance.client;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        context.read<MyAppState>().login(email, password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UniverseSelectPage()),
        );
      } else {
        _showError('Error al iniciar sesión. Verifica tus credenciales.');
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

  // Método para construir botones de usuarios de prueba
  Widget _buildTestUserButton(String email, String password, String label) {
    // Personalidad y color por usuario
    final Map<String, Map<String, dynamic>> userStyles = {
      'Admin': {
        'icon': Icons.shield,
        'color': Colors.redAccent,
        'bg': Colors.red.withOpacity(0.18),
      },
      'Invitado': {
        'icon': Icons.visibility,
        'color': Colors.blueAccent,
        'bg': Colors.blue.withOpacity(0.18),
      },
      'Usuario': {
        'icon': Icons.person,
        'color': Colors.greenAccent,
        'bg': Colors.green.withOpacity(0.18),
      },
      'Anónimo': {
        'icon': Icons.visibility_off,
        'color': Colors.grey,
        'bg': Colors.white.withOpacity(0.13),
      },
      'Tester': {
        'icon': Icons.bug_report,
        'color': Colors.purpleAccent,
        'bg': Colors.purple.withOpacity(0.18),
      },
    };
    final style = userStyles[label] ?? userStyles['Usuario']!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            emailController.text = email;
            passwordController.text = password;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: style['bg'],
          foregroundColor: style['color'],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: style['color'], width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          minimumSize: Size(90, 38),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style['icon'], color: style['color'], size: 20),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: style['color'],
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                      blurRadius: 4,
                      color: Colors.black45,
                      offset: Offset(1, 2)),
                ],
              ),
            ),
          ],
        ),
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
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¡Iniciar Sesión! ⚡',
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
                                  onPressed: _login,
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
                                    'Iniciar Sesión',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage()),
                              );
                            },
                            child: Text(
                              '¿No tienes cuenta? Regístrate',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 10),
                          // Botones para usuarios de prueba
                          Wrap(
                            spacing: 6, // Espaciado horizontal
                            runSpacing: 6, // Espaciado vertical
                            alignment: WrapAlignment.center,
                            children: [
                              _buildTestUserButton(
                                'admin@admin.com',
                                '111111',
                                'Admin',
                              ),
                              _buildTestUserButton(
                                'invitado@invitado.com',
                                '222222',
                                'Invitado',
                              ),
                              _buildTestUserButton(
                                'usuario@usuario.com',
                                '333333',
                                'Usuario',
                              ),
                              _buildTestUserButton(
                                'anonimo@anonimo.com',
                                '444444',
                                'Anónimo',
                              ),
                              _buildTestUserButton(
                                'tester@tester.com',
                                '555555',
                                'Tester',
                              ),
                            ],
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
