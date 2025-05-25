import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/photo.dart';

class MyAppState extends ChangeNotifier {
  String? activeUser; // Usuario activo
  List<Photo> photos = [];

  void setActiveUser(String? email) {
    activeUser = email;
    notifyListeners(); // Notificar a los widgets que el estado ha cambiado
  }

  Future<void> login(String email, String password) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        setActiveUser(email); // Usar el método setActiveUser
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
      setActiveUser(null); // Usar el método setActiveUser
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
        notifyListeners();
      } else {
        throw Exception('Error al registrar el usuario.');
      }
    } catch (e) {
      throw Exception('Error al registrar el usuario: ${e.toString()}');
    }
  }

  Future<void> addPhoto(Photo newPhoto) async {
    final supabase = Supabase.instance.client;

    if (activeUser == null) {
      throw Exception('No hay un usuario activo para agregar la foto.');
    }

    try {
      await supabase.from('photos').insert({
        'type': newPhoto.type,
        'user': newPhoto.user,
        'random_number': newPhoto.randomNumber,
        'votes': newPhoto.votes,
        'voted_users': newPhoto.votedUsers.join(','), // Guardar como texto
        'date_added': newPhoto.dateAdded.toIso8601String(),
        'base64_image': newPhoto.base64Image,
        'custom_name':
            newPhoto.customName, // Guardar el nombre personalizado si existe
      });

      photos.add(newPhoto);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al guardar la foto: ${e.toString()}');
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
          votedUsers: photoData['voted_users'] != null
              ? Set<String>.from(
                  (photoData['voted_users'] as String).split(','))
              : {},
          dateAdded: DateTime.parse(photoData['date_added']),
          base64Image: photoData['base64_image'],
          customName: photoData['custom_name'] ??
              '${photoData['type']}-${photoData['random_number']}', // Asignar un valor predeterminado si es null
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
