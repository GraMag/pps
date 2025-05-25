import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyAppState extends ChangeNotifier {
  String? activeUser; // Usuario actualmente autenticado
  String? userPassword; // Contraseña del usuario autenticado

  MyAppState() {
    _validateState(); // Validar el estado al inicializar
  }

  Future<void> login(String email, String password) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        activeUser = email; // Guardar el correo del usuario autenticado
        userPassword = password; // Guardar la contraseña del usuario
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
      userPassword = null; // Limpiar la contraseña del usuario
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
        notifyListeners();
      } else {
        throw Exception('Error al registrar el usuario.');
      }
    } catch (e) {
      throw Exception('Error al registrar el usuario: ${e.toString()}');
    }
  }

  // Método para validar la contraseña ingresada
  bool validatePassword(String password) {
    return userPassword == password;
  }

  // Validar el estado al inicializar o en cualquier momento
  void _validateState() {
    if (activeUser == null && userPassword != null) {
      // Si no hay usuario activo pero hay contraseña, limpiar el estado
      userPassword = null;
      notifyListeners();
    }
  }
}
