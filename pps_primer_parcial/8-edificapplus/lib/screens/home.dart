import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/state.dart';
import '../screens/vote.dart';
import '../screens/login.dart';
import '../screens/image_list.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [
          // Botón "Lindo"
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageListPage(type: 'Lindo'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Fondo verde
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Sin bordes redondeados
                ),
                minimumSize: Size(double.infinity, double.infinity),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt, // Ícono de cámara
                    size: 150, // Tamaño ajustado
                    color: Colors.white,
                  ),
                  SizedBox(height: 20), // Espaciado entre íconos
                  Icon(
                    Icons.sentiment_satisfied_alt, // Carita sonriente
                    size: 100, // Tamaño ajustado
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          // Botón "Feo"
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageListPage(type: 'Feo'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Fondo rojo
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Sin bordes redondeados
                ),
                minimumSize: Size(double.infinity, double.infinity),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt, // Ícono de cámara
                    size: 150, // Tamaño ajustado
                    color: Colors.white,
                  ),
                  SizedBox(height: 20), // Espaciado entre íconos
                  Icon(
                    Icons.sentiment_dissatisfied, // Carita triste
                    size: 100, // Tamaño ajustado
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          // Botones inferiores
          Row(
            children: [
              // Botón "Fotos"
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VotePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Fondo azul
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Sin bordes redondeados
                    ),
                    minimumSize: Size(double.infinity, 60), // Altura ajustada
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Mis Fotos', // Cambiado de 'Fotos' a 'Mis Fotos'
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón "Cerrar sesión"
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await appState.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800], // Fondo gris oscuro
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Sin bordes redondeados
                    ),
                    minimumSize: Size(double.infinity, 60), // Altura ajustada
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Cerrar sesión', // Texto sin el nombre del usuario
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
