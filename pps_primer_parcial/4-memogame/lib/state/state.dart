import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/photo.dart';
import 'dart:math';

class MyAppState extends ChangeNotifier {
  List<Photo> photos = [];
  String? activeUser; // Usuario actualmente autenticado

  Future<void> login(String email, String password) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        activeUser = email; // Guardar el correo del usuario autenticado
        notifyListeners();
      } else {
        throw Exception('Error al iniciar sesión. Verifica tus credenciales.');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.auth.signOut(); // Cerrar sesión en Supabase
      activeUser = null; // Limpiar el usuario activo
      notifyListeners();
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  Future<void> registerUser(String email, String password) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Opcional: Agregar el usuario a una lista local si es necesario
        notifyListeners();
      } else {
        throw Exception('Error al registrar el usuario.');
      }
    } catch (e) {
      throw Exception('Error al registrar el usuario: ${e.toString()}');
    }
  }

  Future<void> addPhoto(String type, String base64Image) async {
    final supabase = Supabase.instance.client;

    if (activeUser != null) {
      try {
        final newPhoto = Photo(
          type: type,
          user: activeUser!,
          randomNumber: Random().nextInt(1000),
          votes: 0,
          votedUsers: {},
          dateAdded: DateTime.now(),
          base64Image: base64Image,
        );

        await supabase.from('photos').insert({
          'type': newPhoto.type,
          'user': newPhoto.user,
          'random_number': newPhoto.randomNumber,
          'votes': newPhoto.votes,
          'voted_users': newPhoto.votedUsers.join(','), // Guardar como texto
          'date_added': newPhoto.dateAdded.toIso8601String(),
          'base64_image': newPhoto.base64Image,
        });

        photos.add(newPhoto);
        notifyListeners();
      } catch (e) {
        throw Exception('Error al guardar la foto: ${e.toString()}');
      }
    }
  }

  Future<void> loadPhotos() async {
    final supabase = Supabase.instance.client;

    try {
      final List data = await supabase.from('photos').select();

      photos = data.map((photoData) {
        return Photo(
          type: photoData['type'],
          user: photoData['user'],
          randomNumber: photoData['random_number'],
          votes: photoData['votes'],
          votedUsers:
              Set<String>.from((photoData['voted_users'] as String).split(',')),
          dateAdded: DateTime.parse(photoData['date_added']),
          base64Image: photoData['base64_image'],
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      throw Exception('Error al cargar las fotos: ${e.toString()}');
    }
  }

  void votePhoto(Photo photo, bool isLike) async {
    if (photo.votedUsers.contains(activeUser)) {
      return;
    }

    photo.votedUsers.add(activeUser!);
    photo.votes += isLike ? 1 : -1;

    notifyListeners();

    final supabase = Supabase.instance.client;

    try {
      await supabase.from('photos').update({
        'votes': photo.votes,
        'voted_users': photo.votedUsers.join(','),
      }).eq('random_number', photo.randomNumber);

      // No hace falta revisar `response.status`
    } catch (e) {
      throw Exception('Error al actualizar los votos: ${e.toString()}');
    }
  }
}
