import 'package:flutter/material.dart';
import 'package:memojuego/screens/difficulty.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/state.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          MaterialPageRoute(builder: (context) => DifficultyScreen()),
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

  Widget _buildTestUserButton(
      String email, String password, String label, Color color, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          emailController.text = email;
          passwordController.text = password;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        elevation: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _BubblesPainter(_controller.value),
              );
            },
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 12,
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.memory, color: Colors.purpleAccent, size: 60),
                      SizedBox(height: 12),
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.pink.withOpacity(0.2),
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 24),
                      isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
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
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildTestUserButton('admin@admin.com', '111111',
                              'Admin', Colors.redAccent, Icons.star),
                          _buildTestUserButton(
                              'invitado@invitado.com',
                              '222222',
                              'Invitado',
                              Colors.blueAccent,
                              Icons.face),
                          _buildTestUserButton('usuario@usuario.com', '333333',
                              'Usuario', Colors.green, Icons.person),
                          _buildTestUserButton('anonimo@anonimo.com', '444444',
                              'Anónimo', Colors.purple, Icons.visibility_off),
                          _buildTestUserButton('tester@tester.com', '555555',
                              'Tester', Colors.orange, Icons.bug_report),
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

// Fondo animado de burbujas de colores vivos
class _BubblesPainter extends CustomPainter {
  final double progress;
  _BubblesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.pinkAccent,
      Colors.yellow,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
    ];
    final random = [0.1, 0.3, 0.5, 0.7, 0.85, 0.95];
    for (int i = 0; i < colors.length; i++) {
      final dx = size.width * random[i];
      final dy = size.height * ((random[i] + progress) % 1.0);
      final radius = 60.0 + 30.0 * (1 + (progress + i * 0.2) % 1.0);
      final paint = Paint()..color = colors[i].withOpacity(0.35);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
