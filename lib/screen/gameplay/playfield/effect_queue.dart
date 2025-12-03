// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';

class EffectItem {
  final String text;
  final double duration;
  final double delay; // Thời gian giữ lại sau animation
  final double startTime;
  final Offset from;
  final Offset to;
  final TextStyle style;

  EffectItem({
    required this.text,
    required this.duration,
    this.delay = 0.2,
    required this.startTime,
    required this.from,
    required this.to,
    this.style = const TextStyle(
      color: Colors.black,
      fontSize: 25,
      fontWeight: FontWeight.w900,
    ),
  });
}

class EffectQueue {
  final List<EffectItem> queue = [];
  double globalTime = 0.0;

  void addEffect(EffectItem effect) {
    queue.add(effect);
  }

  void update(double dt) {
    globalTime += dt;
    queue.removeWhere(
      (effect) =>
          globalTime - effect.startTime > effect.duration + effect.delay,
    );
  }

  void draw(Canvas canvas) {
    for (int i = 0; i < queue.length; i++) {
      final effect = queue[i];
      double elapsed = globalTime - effect.startTime;
      if (elapsed < 0 || elapsed > effect.duration + effect.delay) continue;

      double t = (elapsed / effect.duration).clamp(0.0, 1.0);
      double drawX = effect.from.dx + (effect.to.dx - effect.from.dx) * t;
      double drawY = effect.from.dy + (effect.to.dy - effect.from.dy) * t;

      double baseOpacity = (1 - t).clamp(0.0, 1.0);
      if (elapsed > effect.duration) baseOpacity = 0.0;

      double queueOpacity = 1.0 - ((queue.length - 1 - i) * 0.4);
      queueOpacity = queueOpacity.clamp(0.2, 1.0);

      double finalOpacity = baseOpacity * queueOpacity;

      final textPainter = TextPainter(
        text: TextSpan(
          text: effect.text,
          style: effect.style.copyWith(
            color: effect.style.color?.withOpacity(finalOpacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Nếu là item cuối cùng (mới nhất), vẽ shadow
      if (i == queue.length - 1) {
        final shadowPainter = TextPainter(
          text: TextSpan(
            text: effect.text,
            style: effect.style.copyWith(
              color: Colors.black.withOpacity(finalOpacity * 0.7),
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 6,
                  color: Colors.black.withOpacity(finalOpacity * 0.7),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        shadowPainter.paint(canvas, Offset(drawX + 2, drawY + 2));
      }

      textPainter.paint(canvas, Offset(drawX, drawY));
    }
  }
}
