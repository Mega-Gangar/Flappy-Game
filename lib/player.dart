import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'pipe.dart';

class Player extends PositionComponent with CollisionCallbacks, HasGameRef<FlappyBirdGame> {

  double velocity = 0.0;
  double gravity = 900.0;
  double jumpStrength = -350.0;

  Player() {
    size = Vector2(40, 40);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = Vector2(gameRef.size.x * 0.2, gameRef.size.y / 2);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.gameState != GameState.playing) return;

    velocity += gravity * dt;
    position.y += velocity * dt;

    // Check ceiling
    if (position.y < 0) {
      position.y = 0;
      velocity = 0;
    }

    // Check ground (80 pixels from bottom for ground height)
    final groundLevel = gameRef.size.y - 80;
    if (position.y > groundLevel - height) {
      position.y = groundLevel - height;
      gameRef.gameOver();
    }
  }

  void fly() {
    if (gameRef.gameState == GameState.playing) {
      velocity = jumpStrength;
    }
  }

  void reset() {
    position = Vector2(gameRef.size.x * 0.2, gameRef.size.y / 2);
    velocity = 0.0;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(width - 8, 12), 6, eyePaint);

    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(width - 6, 12), 3, pupilPaint);

    final beakPaint = Paint()..color = Colors.orange;
    final beakPath = Path();
    beakPath.moveTo(width - 4, 20);
    beakPath.lineTo(width + 8, 20);
    beakPath.lineTo(width - 4, 28);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Pipe && gameRef.gameState == GameState.playing) {
      gameRef.gameOver();
    }
  }
}