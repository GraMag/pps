import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import 'dart:convert';
import '../state/state.dart';
import '../screens/photo_detail.dart';

class UserPhotosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Filtrar las fotos del usuario activo
    List<Photo> userPhotos = appState.photos
        .where((photo) => photo.user == appState.activeUser)
        .toList();

    return Scaffold(
      body: userPhotos.isNotEmpty
          ? ListView.builder(
              itemCount: userPhotos.length,
              itemBuilder: (context, index) {
                final photo = userPhotos[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: photo.type == 'Lindo'
                      ? Colors.green[100]
                      : Colors.red[100], // Fondo según el tipo
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagen ajustada dinámicamente
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.memory(
                              base64Decode(photo.base64Image),
                              width: double.infinity,
                              fit: BoxFit
                                  .contain, // Ajustar la imagen sin recortarla
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título
                                Text(
                                  photo.customName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Votos
                                Row(
                                  children: [
                                    Icon(Icons.thumb_up,
                                        size: 16, color: Colors.grey[700]),
                                    SizedBox(width: 8),
                                    Text(
                                      '${photo.votes} votos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Fecha
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 16, color: Colors.grey[700]),
                                    SizedBox(width: 8),
                                    Text(
                                      '${photo.dateAdded.toLocal()}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Botón para ver detalles
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoDetailsPage(photo: photo),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.info, size: 18),
                                    label: Text('Detalles'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Carita sonriente o triste con fondo ajustado
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: photo.type == 'Lindo'
                                ? Colors.green // Fondo verde intenso
                                : Colors.red, // Fondo rojo intenso
                            shape: BoxShape.circle,
                          ),
                          width: 36, // Ajustar el tamaño del fondo al ícono
                          height: 36, // Ajustar el tamaño del fondo al ícono
                          alignment: Alignment.center,
                          child: Icon(
                            photo.type == 'Lindo'
                                ? Icons
                                    .sentiment_satisfied_alt // Carita sonriente
                                : Icons.sentiment_dissatisfied, // Carita triste
                            color: Colors.white, // Trazos blancos
                            size: 24, // Tamaño del ícono
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'No hay fotos agregadas por el usuario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
