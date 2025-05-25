import 'package:flutter/material.dart';
import 'user_photos.dart';

class VotePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Fotos'),
        backgroundColor: Colors.blue, // Azul igual que el botón
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        color: Colors.blue, // Fondo azul igual que el AppBar y el botón
        child: UserPhotosPage(), // Sin Card ni Padding extra
      ),
    );
  }
}
