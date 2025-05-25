import 'package:flutter/material.dart';

class LoadingDialog {
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evitar que se cierre al tocar fuera
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Agregar el logo del asset
                Image.asset(
                  'assets/icon.png', // Ruta del asset
                  width: 80,
                  height: 80,
                ),
                SizedBox(height: 16),
                CircularProgressIndicator(),
                if (message != null) ...[
                  SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.pop(context); // Cerrar el diálogo
  }
}
