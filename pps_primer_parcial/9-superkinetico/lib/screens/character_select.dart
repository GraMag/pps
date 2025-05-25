import 'package:flutter/material.dart';
import 'package:superkinetico/screens/game_screen.dart';

class CharacterSelectPage extends StatelessWidget {
  final String universe;
  const CharacterSelectPage({Key? key, required this.universe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 4 personajes por universo
    final List<String> characters = List.generate(4, (i) => (i + 1).toString());
    final Color bgColor = universe == 'dc' ? Colors.black : Colors.red[900]!;
    final String assetPrefix = universe == 'dc'
        ? 'assets/characters/dc/'
        : 'assets/characters/marvel/';
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Elegí tu personaje',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                    blurRadius: 8, color: Colors.black, offset: Offset(2, 4)),
              ],
            )),
        backgroundColor: bgColor,
        elevation: 8,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(Icons.person, color: Colors.yellowAccent, size: 32),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.yellowAccent, size: 32),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double spacing = 16;
          final double padding = 12;
          final double totalSpacingH = spacing + 2 * padding;
          final double totalSpacingV = spacing + 2 * padding + kToolbarHeight;
          final double cellWidth = (constraints.maxWidth - totalSpacingH) / 2;
          final double cellHeight = (constraints.maxHeight - totalSpacingV) / 2;
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (int row = 0; row < 2; row++)
                  Expanded(
                    child: Row(
                      children: [
                        for (int col = 0; col < 2; col++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: col == 0 ? spacing : 0,
                                bottom: row == 0 ? spacing : 0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  final name = characters[row * 2 + col];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GameScreen(
                                        character: name,
                                        universe: universe,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Center(
                                    child: Image.asset(
                                      assetPrefix +
                                          '${characters[row * 2 + col]}.png',
                                      fit: BoxFit.contain,
                                      width: cellWidth,
                                      height: cellHeight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
