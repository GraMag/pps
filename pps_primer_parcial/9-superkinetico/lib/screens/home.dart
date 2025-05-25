import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import '../state/state.dart';
import '../screens/login.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
// Texto que refleja el estado actual
  String?
      _alertState; // Estado de alerta: "izquierda", "derecha", "vertical", "horizontal", o null
  bool isAlarmActive = false; // Estado del botón de alarma
  bool isAlarmTriggered = false; // Indica si la alarma está activada por giro
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Instancia de AudioPlayer

  @override
  void initState() {
    super.initState();
    _startListeningToAccelerometer();
    _startSoundLoop(); // Iniciar el bucle de sonido
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (!isAlarmActive) return; // Solo procesar si la alarma está activa

      setState(() {
        // Detectar inclinaciones y posiciones
        if (event.x < -2) {
          // Giro a la izquierda
          if (_alertState != "izquierda") {
            _updateAlertState("izquierda");
          }
        } else if (event.x > 2) {
          // Giro a la derecha
          if (_alertState != "derecha") {
            _updateAlertState("derecha");
          }
        } else if (event.z < 8) {
          // Vertical
          if (_alertState != "vertical") {
            _updateAlertState("vertical");
          }
        } else if (event.z.abs() > 8) {
          // Estable (horizontal) mientras está alarmado
          if (isAlarmTriggered && _alertState != "horizontal") {
            _updateAlertState("horizontal");
          } else if (!isAlarmTriggered) {
            // Si no está alarmado, volver a estado estable
            _updateAlertState(null); // Sin alerta
          }
        }
      });
    });
  }

  void _updateAlertState(String? newState) async {
    if (_alertState == newState)
      return; // Si el estado no cambia, no hacer nada

    _alertState = newState;

    if (newState != null) {
      isAlarmTriggered = true; // Activar el estado de alarma

      // Activar vibración o linterna según el estado
      if (newState == "horizontal") {
        _triggerVibration(); // Vibrar por 5 segundos
      } else if (newState == "vertical") {
        _triggerFlashlight(); // Encender linterna por 5 segundos
      }
    } else {
      isAlarmTriggered =
          false; // Desactivar el estado de alarma si no hay alerta
    }
  }

  void _triggerVibration() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 5000); // Vibrar por 5 segundos
    }
  }

  void _triggerFlashlight() async {
    try {
      await TorchLight.enableTorch(); // Encender linterna
      await Future.delayed(Duration(seconds: 5)); // Esperar 5 segundos
      await TorchLight.disableTorch(); // Apagar linterna
    } catch (e) {
      print("Error al controlar la linterna: $e");
    }
  }

  void _startSoundLoop() async {
    while (true) {
      if (isAlarmTriggered && _alertState != null) {
        String soundPath;

        // Determinar el sonido según el estado actual
        switch (_alertState) {
          case "izquierda":
            soundPath = 'audio/left.mp3';
            break;
          case "derecha":
            soundPath = 'audio/right.mp3';
            break;
          case "vertical":
            soundPath = 'audio/alerta.mp3';
            break;
          case "horizontal":
            soundPath = 'audio/explode.mp3';
            break;
          default:
            soundPath = '';
        }

        if (soundPath.isNotEmpty) {
          try {
            await _audioPlayer
                .play(AssetSource(soundPath)); // Reproducir el sonido
            await Future.delayed(
                Duration(seconds: 2)); // Esperar antes de repetir
          } catch (e) {
            print("Error al reproducir sonido: $e");
          }
        }
      } else {
        await Future.delayed(Duration(
            milliseconds: 100)); // Esperar antes de verificar nuevamente
      }
    }
  }

  void _stopAlarm() async {
    setState(() {
      isAlarmTriggered = false; // Desactivar estado de alarma
// Reiniciar el texto de estado
      _alertState = null; // Limpiar el estado de alerta
    });

    // Detener el sonido actual
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print("Error al detener el sonido: $e");
    }

    // Apagar linterna
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print("Error al apagar la linterna: $e");
    }

    // Detener vibración
    try {
      Vibration.cancel();
    } catch (e) {
      print("Error al detener la vibración: $e");
    }
  }

  @override
  void dispose() {
    _stopListeningToAccelerometer();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _stopListeningToAccelerometer() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  void _toggleAlarm() {
    if (isAlarmTriggered) {
      // Solicitar contraseña para desactivar la alarma
      final TextEditingController passwordController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Desactivar Alarma'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Por favor, ingresa tu contraseña para desactivar la alarma.'),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cerrar el diálogo
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final password = passwordController.text.trim();
                  final appState = context.read<MyAppState>();

                  if (password == appState.userPassword) {
                    // Contraseña correcta, desactivar alarma
                    Navigator.pop(context); // Cerrar el diálogo
                    _stopAlarm();
                  } else {
                    // Contraseña incorrecta
                    Navigator.pop(context); // Cerrar el diálogo
                    _triggerVibration();
                    _triggerFlashlight();
                    _playErrorSound();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Contraseña Incorrecta'),
                        content: const Text(
                            'La contraseña ingresada no es correcta.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
    } else {
      // Activar o desactivar la alarma sin contraseña
      setState(() {
        isAlarmActive = !isAlarmActive;
        if (!isAlarmActive) {
          _alertState = null;
        }
      });
    }
  }

  Color _getButtonColor() {
    if (isAlarmTriggered) {
      return Colors.red; // Fondo rojo cuando la alarma está activada
    } else if (!isAlarmActive) {
      return Colors.white; // Fondo blanco cuando la alarma está apagada
    } else {
      return Colors
          .green; // Fondo verde cuando la alarma está encendida pero no activada
    }
  }

  void _logoutWithPassword(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final appState = context.read<MyAppState>();
        return AlertDialog(
          title: const Text('Confirmar Deslogueo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Usuario actual: ${appState.activeUser ?? "Desconocido"}'),
              const SizedBox(height: 10),
              const Text('Por favor, ingresa tu contraseña para desloguearte.'),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext), // Cerrar el diálogo
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text.trim();

                if (password == appState.userPassword) {
                  // Contraseña correcta, cerrar sesión
                  Navigator.pop(
                      dialogContext); // Cerrar el diálogo de confirmación

                  try {
                    await appState.logout();
                    if (mounted) {
                      // Redirigir al LoginPage
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false, // Eliminar todas las rutas anteriores
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      // Mostrar error usando el contexto principal
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content:
                              Text('Error al cerrar sesión: ${e.toString()}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                } else {
                  // Contraseña incorrecta
                  Navigator.pop(
                      dialogContext); // Cerrar el diálogo de confirmación

                  // Activar vibración, linterna y reproducir audio
                  _triggerVibration();
                  _triggerFlashlight();
                  _playErrorSound();

                  // Mostrar mensaje de contraseña incorrecta
                  showDialog(
                    context: context, // Usar el contexto principal
                    builder: (context) => AlertDialog(
                      title: const Text('Contraseña Incorrecta'),
                      content:
                          const Text('La contraseña ingresada no es correcta.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _playErrorSound() async {
    final player = AudioPlayer();
    try {
      await player
          .play(AssetSource('audio/password.mp3')); // Reproducir el audio
    } catch (e) {
      print('Error al reproducir el audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Stack(
        children: [
          // Asegurarse de que no haya widgets superpuestos con colores diferentes
          Positioned.fill(
            child: ElevatedButton(
              onPressed: _toggleAlarm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(),
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                minimumSize: Size(double.infinity, double.infinity),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAlarmTriggered
                        ? Icons.lock_open // Ícono para "Desbloquear"
                        : (isAlarmActive
                            ? Icons
                                .notifications // Ícono para "Alarma Activada"
                            : Icons
                                .notifications_none), // Ícono para "Alarma Desactivada"
                    size: 150, // Tamaño grande para los íconos
                    color: Colors.black, // Mismo color que el texto
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isAlarmTriggered
                        ? "Desbloquear"
                        : (isAlarmActive
                            ? "Desactivar Alarma"
                            : "Activar Alarma"),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Texto en negro
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                heroTag: 'fabLogout',
                onPressed: () => _logoutWithPassword(context),
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
