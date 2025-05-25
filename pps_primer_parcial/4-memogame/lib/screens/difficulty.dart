import 'package:flutter/material.dart';
import 'package:memojuego/screens/scores.dart';
import 'home.dart';
import 'login.dart';

class DifficultyScreen extends StatelessWidget {
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Fondo de burbujas animado
          AnimatedBubblesBackground(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Seleccionar Dificultad',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Negro
                        fontFamily: 'Comic Sans MS',
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    _buildDifficultyButton(
                      context,
                      'Fácil',
                      Icons.looks_one,
                      Colors.green,
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(difficulty: 'Fácil'),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildDifficultyButton(
                      context,
                      'Medio',
                      Icons.looks_two,
                      Colors.orange,
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(difficulty: 'Medio'),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildDifficultyButton(
                      context,
                      'Difícil',
                      Icons.looks_3,
                      Colors.red,
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyHomePage(difficulty: 'Difícil'),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    _buildScoresButton(
                      context,
                      'Ver Puntajes',
                      Icons.leaderboard,
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ScoresScreen()),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => _logout(context),
                      icon: Icon(Icons.logout, color: Colors.black),
                      label: Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.6, 50),
                        backgroundColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildDifficultyButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 50),
      label: Text(
        label,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 40),
        backgroundColor: color, // Color sólido, sin opacidad
        foregroundColor: Colors.white,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.85, 90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
      ),
    );
  }

  Widget _buildScoresButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 40),
      label: Text(
        label,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20),
        backgroundColor: color, // Color sólido, sin opacidad
        foregroundColor: Colors.white,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.85, 70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
      ),
    );
  }
}

// Fondo animado de burbujas de colores vivos
class AnimatedBubblesBackground extends StatefulWidget {
  @override
  State<AnimatedBubblesBackground> createState() =>
      _AnimatedBubblesBackgroundState();
}

class _AnimatedBubblesBackgroundState extends State<AnimatedBubblesBackground>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BubblesPainter(_controller.value),
        );
      },
    );
  }
}

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
