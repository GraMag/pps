import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScoresPage extends StatelessWidget {
  const ScoresPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getScores() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('kinetic_score')
          .select('user_email, seconds, universe, character')
          .order('seconds', ascending: false)
          .limit(5);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.yellowAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mejores 5 Puntajes',
            style: TextStyle(
                color: Colors.yellowAccent,
                fontWeight: FontWeight.bold,
                fontSize: 26)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black, // Fondo negro detrás de la barra de notificaciones
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getScores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.yellowAccent));
            }
            final scores = snapshot.data ?? [];
            return Column(
              children: List.generate(5, (i) {
                final score = i < scores.length ? scores[i] : null;
                return Expanded(
                  child: score == null
                      ? Container()
                      : Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.yellowAccent, width: 2),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  'assets/characters/${score['universe']}/${score['character']}.png',
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  'assets/${score['universe']}.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      score['user_email'] ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tiempo: ${score['seconds']} s',
                                      style: TextStyle(
                                        color: Colors.yellowAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
