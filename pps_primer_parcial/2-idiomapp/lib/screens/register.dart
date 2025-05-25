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
        Navigator.pop(context);
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
        backgroundColor: Colors.yellow[100],
        title: Text('¡Uy!',
            style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Stack(
        children: [
          // Fondo colorido con patrón
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.pink[100]!, blurRadius: 12)
                  ],
                ),
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icon.png', width: 80, height: 80),
                    SizedBox(height: 12),
                    Text(
                      '¡Crea tu cuenta!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo',
                        labelStyle: TextStyle(
                            color: Colors.pink[400],
                            fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.pink[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.pink[300]),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.lightBlue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.lightBlue),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 22),
                    isLoading
                        ? CircularProgressIndicator(color: Colors.purple)
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[400],
                              shape: StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 40),
                            ),
                            child: Text(
                              '¡Registrarme!',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(
                            color: Colors.pink[400],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
