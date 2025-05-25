import 'package:flutter/material.dart';
import 'package:superkinetico/screens/character_select.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login.dart';
import 'scores.dart';

class UniverseSelectPage extends StatelessWidget {
  const UniverseSelectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.black,
          ),
          Container(
            color: Colors.black, // Fondo negro detrás de los botones
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 6.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ScoresPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Color(0xFF222B3A), // Azul oscuro tipo cómic
                          foregroundColor: Colors.yellowAccent,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                                color: Colors.yellowAccent, width: 3),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shadowColor: Colors.yellowAccent.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.leaderboard,
                                size: 28, color: Colors.yellowAccent),
                            SizedBox(width: 10),
                            Text('Puntajes',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    letterSpacing: 1.2,
                                    color: Colors.yellowAccent,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 8,
                                          color: Colors.black,
                                          offset: Offset(2, 4))
                                    ])),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 6.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final supabase = Supabase.instance.client;
                          await supabase.auth.signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Color(0xFF222B3A), // Azul oscuro tipo cómic
                          foregroundColor: Colors.yellowAccent,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                                color: Colors.yellowAccent, width: 3),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shadowColor: Colors.yellowAccent.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout,
                                size: 28, color: Colors.yellowAccent),
                            SizedBox(width: 10),
                            Text('Cerrar sesión',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    letterSpacing: 1.2,
                                    color: Colors.yellowAccent,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 8,
                                          color: Colors.black,
                                          offset: Offset(2, 4))
                                    ])),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterSelectPage(universe: 'dc'),
                  ),
                );
              },
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Image.asset('assets/dc.png', width: 120, height: 120),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CharacterSelectPage(universe: 'marvel'),
                  ),
                );
              },
              child: Container(
                color: Colors.red[900],
                child: Center(
                  child:
                      Image.asset('assets/marvel.png', width: 120, height: 120),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
