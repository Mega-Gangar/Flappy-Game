import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game.dart';

class Background extends Component with HasGameRef<FlappyBirdGame> {
  final List<Vector2> cloudPositions = [];
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Generate random cloud positions
    generateClouds();
  }

  void generateClouds() {
    cloudPositions.clear();
    for (int i = 0; i < 8; i++) {
      cloudPositions.add(Vector2(
        random.nextDouble() * gameRef.size.x,
        random.nextDouble() * (gameRef.size.y - 200) + 50,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw sky background
    final skyPaint = Paint()..color = const Color(0xFF70C5CE);
    canvas.drawRect(gameRef.size.toRect(), skyPaint);

    // Draw sun
    final sunPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(
      Offset(gameRef.size.x - 80, 80),
      40,
      sunPaint,
    );

    // Draw clouds
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.9);
    for (final position in cloudPositions) {
      _drawCloud(canvas, position, cloudPaint);
    }

    // Draw ground
    final groundPaint = Paint()..color = const Color(0xFFDDAE87);
    canvas.drawRect(
      Rect.fromLTWH(0, gameRef.size.y - 80, gameRef.size.x, 80),
      groundPaint,
    );

    // Draw grass line
    final grassPaint = Paint()..color = const Color(0xFF8DBF67);
    canvas.drawRect(
      Rect.fromLTWH(0, gameRef.size.y - 80, gameRef.size.x, 10),
      grassPaint,
    );
  }

  void _drawCloud(Canvas canvas, Vector2 position, Paint paint) {
    // Draw a simple cloud using circles
    canvas.drawCircle(Offset(position.x, position.y), 20, paint);
    canvas.drawCircle(Offset(position.x + 15, position.y - 10), 18, paint);
    canvas.drawCircle(Offset(position.x + 30, position.y), 20, paint);
    canvas.drawCircle(Offset(position.x + 15, position.y + 10), 16, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Only move clouds if game is playing
    if (gameRef.gameState != GameState.playing) return;

    // Move clouds slowly for parallax effect
    for (int i = 0; i < cloudPositions.length; i++) {
      cloudPositions[i] = Vector2(
        cloudPositions[i].x - 20 * dt, // Slow cloud movement
        cloudPositions[i].y,
      );

      // Reset cloud position when it goes off screen
      if (cloudPositions[i].x < -50) {
        cloudPositions[i] = Vector2(
          gameRef.size.x + 50,
          random.nextDouble() * (gameRef.size.y - 200) + 50,
        );
      }
    }
  }
}