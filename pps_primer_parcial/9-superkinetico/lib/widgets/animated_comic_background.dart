import 'dart:math';
import 'package:flutter/material.dart';

/// Fondo animado usando imágenes PNG de la carpeta assets/background moviéndose y cayendo.
class AnimatedComicBackground extends StatefulWidget {
  const AnimatedComicBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedComicBackground> createState() =>
      _AnimatedComicBackgroundState();
}

class _AnimatedComicBackgroundState extends State<AnimatedComicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int imageCount = 7;
  final int floatingCount = 10;
  final Random random = Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final size = MediaQuery.of(context).size;
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF181A20)),
            // Dibujar los assets moviéndose/cayendo
            ...List.generate(floatingCount, (i) {
              final idx = (i % imageCount) + 1;
              final t = (progress + i * 0.11) % 1.0;
              final dx = size.width *
                  (0.08 +
                      0.84 * (i / floatingCount) +
                      0.08 * sin(progress * 2 * pi + i));
              final dy = size.height * (t - 0.2) * 1.2;
              final scale = 0.44 +
                  0.20 *
                      (0.5 +
                          0.5 *
                              sin(progress * 2 * pi +
                                  i)); // Doble del tamaño anterior
              return Positioned(
                left: dx,
                top: dy,
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/background/$idx.png',
                    width: 180 * scale,
                    height: 180 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
