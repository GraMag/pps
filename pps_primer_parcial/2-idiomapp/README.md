# flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Cambiar iconos
flutter pub run flutter_launcher_icons:main

# Cambiar nombre de la app
android {
    defaultConfig {
        applicationId "com.example.idiomapp" // Cambia esto
    }
}

android/app/src/main/java/<tu_paquete>/MainActivity.java