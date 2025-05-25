import 'package:edificappro/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/state.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final darkBlue = Color(0xFF486581); // Azul-gris moderno

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
        context
            .read<MyAppState>()
            .setActiveUser(email); // Configurar el usuario activo

        // Redirigir a la pantalla principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        _showError('Error al iniciar sesión. Intenta nuevamente.');
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

  // Cambia el color de los botones de prueba a azul claro
  Widget _buildTestUserButton(String email, String password, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() {
            emailController.text = email;
            passwordController.text = password;
          });
        },
        icon: Icon(
          Icons.person,
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          'Precargar como $label',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Color(0xFF232526).withOpacity(0.85),
          // Sin borde dorado
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // fallback
      body: Stack(
        children: [
          // Fondo degradado igual al splash
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF232526), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          labelStyle: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white54,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white54,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(
                                  0xFFFFD700), // Amarillo dorado SOLO en el borde
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(Icons.email,
                              color:
                                  Colors.white70), // Ícono igual que register
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor:
                            Color(0xFFFFD700), // Amarillo dorado en el cursor
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white54,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white54,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(
                                  0xFFFFD700), // Amarillo dorado SOLO en el borde
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(Icons.lock,
                              color:
                                  Colors.white70), // Ícono igual que register
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        obscureText: true,
                        cursorColor:
                            Color(0xFFFFD700), // Amarillo dorado en el cursor
                      ),
                      SizedBox(height: 24),
                      isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF444444),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              child: Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      SizedBox(height: 16),
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
                          style: TextStyle(color: Color(0xFFFFD700)),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Botones para usuarios de prueba
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
        ],
      ),
    );
  }
}
