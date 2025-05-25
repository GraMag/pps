import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScoresScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _getScores(String difficulty) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('scores')
          .select('time, date, user_name')
          .eq('difficulty', difficulty) // Filtrar por dificultad
          .order('time', ascending: true)
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error al obtener los puntajes: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors
              .blue, // Mismo color que el botón de puntajes en DifficultyScreen
          elevation: 4,
          title: Row(
            children: [
              Icon(Icons.leaderboard,
                  color: Colors.white,
                  size: 28), // Mismo icono que el botón de puntajes
              SizedBox(width: 8),
              Text(
                'Puntajes',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          iconTheme: IconThemeData(color: Colors.white),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(54),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  tabBarTheme: TabBarTheme(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    indicator: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.blue.shade900,
                  unselectedLabelColor: Colors.blueGrey.shade600,
                  labelStyle: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  tabs: [
                    Tab(text: 'Fácil'),
                    Tab(text: 'Medio'),
                    Tab(text: 'Difícil'),
                  ],
                  dividerColor:
                      Colors.transparent, // Elimina la línea bajo cada tab
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Fondo de burbujas fijo
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _BubblesPainter(0.3), // valor fijo
            ),
            TabBarView(
              children: [
                _buildScoresList(context, 'Fácil'),
                _buildScoresList(context, 'Medio'),
                _buildScoresList(context, 'Difícil'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoresList(BuildContext context, String difficulty) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getScores(difficulty),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron puntajes.'));
        }

        final scores = snapshot.data!;
        final totalItems = 5;
        final filledScores = List<Map<String, dynamic>>.from(scores);
        while (filledScores.length < totalItems) {
          filledScores.add({}); // Tarjetas vacías
        }

        return Padding(
          padding: EdgeInsets.only(top: 32, bottom: 32, left: 16, right: 16),
          child: Column(
            children: List.generate(totalItems, (index) {
              final score = filledScores[index];
              final isWinner = index == 0 && (score['user_name'] != null);
              final userName = score['user_name'] ?? '';
              final time = score['time']?.toString() ?? '';
              final date = score['date']?.toString() ?? '';
              final isEmpty = userName.isEmpty;
              final bgColor = isEmpty
                  ? Colors.white.withOpacity(0.3)
                  : index % 2 == 0
                      ? Colors.grey.shade200.withOpacity(isWinner ? 0.85 : 0.7)
                      : Colors.white.withOpacity(isWinner ? 0.85 : 0.7);

              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  constraints: BoxConstraints(minHeight: 80),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(1, 3),
                      ),
                    ],
                    border: isWinner
                        ? Border.all(color: Colors.amber, width: 2)
                        : null,
                  ),
                  child: isEmpty
                      ? SizedBox.shrink()
                      : ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          leading: CircleAvatar(
                            backgroundColor:
                                isWinner ? Colors.amber : Colors.blue.shade100,
                            radius: 28,
                            child: isWinner
                                ? Icon(Icons.emoji_events,
                                    color: Colors.deepOrange, size: 32)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 22),
                                  ),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.person,
                                  color: Colors.blueAccent, size: 22),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Icons.timer,
                                  size: 20, color: Colors.deepOrange),
                              SizedBox(width: 4),
                              Text('$time s',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade800)),
                              SizedBox(width: 16),
                              Icon(Icons.event,
                                  size: 20, color: Colors.blueAccent),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text('$date',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          trailing: isWinner
                              ? Icon(Icons.star, color: Colors.amber, size: 36)
                              : null,
                        ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// Fondo de burbujas fijo
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
      final paint = Paint()..color = colors[i].withOpacity(0.25);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter oldDelegate) => false;
}
