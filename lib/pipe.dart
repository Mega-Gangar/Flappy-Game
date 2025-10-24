import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game.dart';

class Pipe extends PositionComponent with HasGameRef<FlappyBirdGame> {
  @override
  final double height;
  final bool isTop;
  @override
  final FlappyBirdGame gameRef;
  bool hasScored = false;

  Pipe({
    required Vector2 position,
    required this.height,
    required this.isTop,
    required this.gameRef,
  }) : super(position: position) {
    size = Vector2(gameRef.pipeWidth, height);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameRef.shouldPipesMove) return;

    position.x -= gameRef.currentSpeed * dt;

    if (position.x < -width) {
      removeFromParent();
    }

    if (!hasScored && position.x + width < gameRef.player.position.x) {
      hasScored = true;
      gameRef.increaseScore();
    }
  }

  @override
  void render(Canvas canvas) {
    final pipeColor = gameRef.level >= 5
        ? const Color(0xFFD32F2F)
        : gameRef.level >= 3
        ? const Color(0xFFFF9800)
        : const Color(0xFF4CAF50);

    final pipePaint = Paint()
      ..color = pipeColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), pipePaint);

    final capColor = gameRef.level >= 5
        ? const Color(0xFFB71C1C)
        : gameRef.level >= 3
        ? const Color(0xFFF57C00)
        : const Color(0xFF388E3C);

    final capPaint = Paint()
      ..color = capColor
      ..style = PaintingStyle.fill;

    if (isTop) {
      canvas.drawRect(Rect.fromLTWH(0, height - 30, width, 30), capPaint);
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, height - 32, width, 2), shadowPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, width, 30), capPaint);
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 30, width, 2), shadowPaint);
    }

    // Draw pipe pattern
    final patternPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double i = 10; i < width; i += 15) {
      canvas.drawLine(Offset(i, 0), Offset(i, height), patternPaint);
    }
  }
}