import 'package:flutter/material.dart';
import 'package:qrsaldo/screens/home.dart';
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
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen()), // Redirigir a la selección de dificultad
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
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 4.0), // Espaciado entre botones
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            emailController.text = email;
            passwordController.text = password;
          });
        },
        icon: Icon(
          Icons.person, // Ícono de usuario
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0D47A1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16, // Ajustar el ancho del botón
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado azul financiero
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 48,
                        color: Color(0xFF0D47A1),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Iniciar sesión en QR Saldo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gestiona tu dinero de forma simple y segura',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          labelStyle: TextStyle(color: Color(0xFF0D47A1)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon:
                              Icon(Icons.email, color: Color(0xFF0D47A1)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFF0D47A1), width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Color(0xFF0D47A1)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon:
                              Icon(Icons.lock, color: Color(0xFF0D47A1)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFF0D47A1), width: 2),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 24),
                      isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _login,
                              icon: Icon(Icons.login, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0D47A1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                              ),
                              label: Text(
                                'Entrar',
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
                          '¿No tienes cuenta? Registrate en QR Saldo',
                          style: TextStyle(color: Color(0xFF0D47A1)),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Botones para usuarios de prueba
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
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
                            'Inv',
                          ),
                          _buildTestUserButton(
                            'usuario@usuario.com',
                            '333333',
                            'Usr',
                          ),
                          _buildTestUserButton(
                            'anonimo@anonimo.com',
                            '444444',
                            'Anon',
                          ),
                          _buildTestUserButton(
                            'tester@tester.com',
                            '555555',
                            'Test',
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
