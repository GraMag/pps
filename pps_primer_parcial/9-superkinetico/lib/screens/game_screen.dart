import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../state/state.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  final String character;
  final String universe;
  const GameScreen({Key? key, required this.character, required this.universe})
      : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double posX = 0.5; // 0.0 izquierda, 1.0 derecha
  double posY = 0.5; // 0.0 arriba, 1.0 abajo
  late StreamSubscription<AccelerometerEvent> _accelSub;
  bool lost = false;
  int seconds = 0;
  Timer? timer;
  Timer? stillTimer;
  AccelerometerEvent? lastEvent;
  bool showMoveMsg = false;

  static const double stillThreshold =
      0.12; // Sensibilidad para detectar quietud
  static const int stillLoseTimeout = 5; // Segundos para perder por quietud

  @override
  void initState() {
    super.initState();
    _accelSub = accelerometerEvents.listen(_onAccel);
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (!lost) {
        setState(() {
          seconds++;
        });
      }
    });
    stillTimer = Timer.periodic(Duration(milliseconds: 500), (t) {
      if (lost) return;
      if (lastEvent == null) return;
      final dx = lastEvent!.x.abs();
      final dy = lastEvent!.y.abs();
      final dz = lastEvent!.z.abs();
      final moving =
          dx > stillThreshold || dy > stillThreshold || dz > stillThreshold;
      if (!moving) {
        if (!showMoveMsg) {
          setState(() {
            showMoveMsg = true;
          });
        }
        if (seconds >= stillLoseTimeout) {
          setState(() {
            lost = true;
          });
          timer?.cancel();
          stillTimer?.cancel();
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black
                .withOpacity(0.95), // Fondo negro detrás del diálogo
            builder: (context) => AlertDialog(
              backgroundColor: Colors.black.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.white, width: 3),
              ),
              title: Text('¡Perdiste por estar quieto!',
                  style: TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
              content: Text('Debías moverte. Puntaje: 0 segundos.',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Volver'),
                ),
              ],
            ),
          );
        }
      } else {
        if (showMoveMsg)
          setState(() {
            showMoveMsg = false;
          });
      }
    });
  }

  @override
  void dispose() {
    _accelSub.cancel();
    timer?.cancel();
    stillTimer?.cancel();
    super.dispose();
  }

  void _onAccel(AccelerometerEvent event) {
    if (lost) return;
    lastEvent = event;
    // Movimiento proporcional al ángulo/aceleración
    final double speed =
        0.012 + 0.03 * (event.x.abs() + event.y.abs()).clamp(0, 2);
    setState(() {
      posX += event.x * -speed;
      posY += event.y * speed;
      posX = posX.clamp(0.0, 1.0);
      posY = posY.clamp(0.0, 1.0);
      if (posX <= 0.01 || posX >= 0.99 || posY <= 0.01 || posY >= 0.99) {
        setState(() {
          lost = true;
        });
        _accelSub.cancel();
        timer?.cancel();
        stillTimer?.cancel();
        _onWin();
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor:
              Colors.black.withOpacity(0.95), // Fondo negro detrás del diálogo
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.white, width: 3),
            ),
            title: Text('¡Perdiste!',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            content: Text('Lograste un tiempo de $seconds segundos.',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.yellowAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Volver'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _onWin() async {
    final supabase = Supabase.instance.client;
    final appState = context.read<MyAppState>();
    final userEmail = appState.activeUser ?? supabase.auth.currentUser?.email;
    if (userEmail == null) return;
    try {
      await supabase.from('kinetic_score').insert({
        'user_email': userEmail,
        'seconds': seconds,
        'universe': widget.universe,
        'character': widget.character,
      });
    } catch (e) {
      // Puedes mostrar un error si lo deseas
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            border: Border(
                bottom: BorderSide(color: Colors.yellowAccent, width: 3)),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                '⏱ Tiempo: $seconds s',
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(1, 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black), // Fondo negro siempre
          ),
          if (showMoveMsg && !lost)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.yellowAccent, width: 3),
                  ),
                  child: Text(
                    '¡Mové el celular para jugar!',
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = min(constraints.maxWidth, constraints.maxHeight);
              final x = posX * (constraints.maxWidth - size * 0.2);
              final y = posY * (constraints.maxHeight - size * 0.2);
              return Stack(
                children: [
                  Positioned(
                    left: x,
                    top: y,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: size * 0.1,
                          backgroundColor: Colors.red,
                        ),
                        Image.asset(
                          'assets/characters/${widget.universe}/${widget.character}.png',
                          width: size * 0.18,
                          height: size * 0.18,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  if (lost)
                    SizedBox.shrink(), // No overlay, solo el AlertDialog
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
