import 'package:flutter/material.dart';
import '../models/photo.dart';
import 'dart:convert';

class PhotoDetailsPage extends StatelessWidget {
  final Photo photo;

  const PhotoDetailsPage({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color mainColor =
        photo.type == 'Lindo' ? Color(0xFF388E3C) : Color(0xFFB71C1C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          photo.customName.isNotEmpty ? photo.customName : 'Sin nombre',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mainColor.withOpacity(0.15),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.96),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagen principal
                    Image.memory(
                      base64Decode(photo.base64Image),
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.6,
                    ),
                    // Footer de datos
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 220,
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tipo
                              Row(
                                children: [
                                  Icon(Icons.category,
                                      color: mainColor, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    photo.type,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Votos
                              Row(
                                children: [
                                  Icon(Icons.thumb_up,
                                      color: Colors.grey[700], size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    '${photo.votes} votos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Usuario
                              Row(
                                children: [
                                  Icon(Icons.person,
                                      color: Colors.grey[700], size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    photo.user,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Fecha
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.grey[700], size: 18),
                                  SizedBox(width: 10),
                                  Text(
                                    '${photo.dateAdded.day}/${photo.dateAdded.month}/${photo.dateAdded.year}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
