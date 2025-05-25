import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                        'Registrate en QR Saldo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Crea tu cuenta y gestiona tu dinero',
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
                              onPressed: _register,
                              icon: Icon(Icons.account_balance_wallet_rounded,
                                  color: Colors.white),
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
                                'Crear cuenta',
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
                          Navigator.pop(context); // Volver al LoginPage
                        },
                        child: Text(
                          '¿Ya tienes cuenta? Inicia sesión en QR Saldo',
                          style: TextStyle(color: Color(0xFF0D47A1)),
                        ),
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
