import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'pipe.dart';
import 'background.dart';
import 'services/setting_service.dart';

enum GameState { waiting, playing, gameOver }

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Player player;
  late Background background;
  final Random random = Random();

  // Use the singleton SettingsService
  final SettingsService settings = SettingsService();

  // Game state
  GameState gameState = GameState.waiting;
  int score = 0;
  int level = 1;
  bool _pipesMoving = true;
  bool _isInitialized = false;

  // Dynamic settings-based properties
  double get pipeGap {
    switch (settings.difficultySync) {
      case 'easy': return 300.0;
      case 'hard': return 180.0;
      default: return 250.0; // normal
    }
  }

  double get baseSpeed {
    switch (settings.difficultySync) {
      case 'easy': return 300.0;
      case 'hard': return 500.0;
      default: return 400.0; // normal
    }
  }

  double get currentSpeed => baseSpeed * (1 + (level - 1) * 0.1);

  double minPipeHeight = 100.0;
  double pipeWidth = 80.0;
  double pipeGenerationInterval = 1.9;

  TimerComponent? pipeTimer;

  final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  );

  final TextPaint smallTextPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugMode = false;

    // Initialize settings
    await settings.ensureInitialized();
    _isInitialized = true;

    // Add your background first
    background = Background();
    add(background);

    // Add player
    player = Player();
    add(player);

    // Show start screen
    overlays.add('Start');
  }

  void startGame() {
    if (!_isInitialized) return;

    gameState = GameState.playing;
    _pipesMoving = true;
    score = 0;
    level = 1;
    pipeGenerationInterval = 2.0;

    // Reset player
    player.reset();

    // Remove all pipes
    children.whereType<Pipe>().forEach(remove);

    // Remove overlays
    overlays.remove('Start');
    overlays.remove('GameOver');

    // Start pipe generation
    _startPipeGeneration();
  }

  void _startPipeGeneration() {
    if (pipeTimer != null) {
      remove(pipeTimer!);
    }

    pipeTimer = TimerComponent(
      period: pipeGenerationInterval,
      repeat: true,
      onTick: _addPipePair,
    );
    add(pipeTimer!);
  }

  void _updatePipeGeneration() {
    if (gameState == GameState.playing) {
      _startPipeGeneration();
    }
  }

  void _addPipePair() {
    if (gameState != GameState.playing || !_isInitialized) return;

    double availableHeight = size.y - pipeGap - 80;

    if (availableHeight < minPipeHeight * 2) {
      return;
    }

    double maxTopPipeHeight = availableHeight - minPipeHeight;
    double topPipeHeight = minPipeHeight + random.nextDouble() * (maxTopPipeHeight - minPipeHeight);
    double bottomPipeHeight = availableHeight - topPipeHeight;

    if (topPipeHeight < minPipeHeight || bottomPipeHeight < minPipeHeight) {
      topPipeHeight = minPipeHeight;
      bottomPipeHeight = availableHeight - minPipeHeight;
    }

    // Top pipe
    final topPipe = Pipe(
      position: Vector2(size.x, 0),
      height: topPipeHeight,
      isTop: true,
      gameRef: this,
    );
    add(topPipe);

    // Bottom pipe
    final bottomPipe = Pipe(
      position: Vector2(size.x, topPipeHeight + pipeGap),
      height: bottomPipeHeight,
      isTop: false,
      gameRef: this,
    );
    add(bottomPipe);
  }

  @override
  void onTap() {
    if (!_isInitialized) return;

    if (gameState == GameState.waiting) {
      startGame();
    } else if (gameState == GameState.playing) {
      player.fly();
    }
  }

  void gameOver() {
    gameState = GameState.gameOver;
    _pipesMoving = false;

    overlays.add('GameOver');
  }

  void restartGame() {
    if (!_isInitialized) return;

    startGame();
  }

  void increaseScore() {
    if (gameState == GameState.playing && _isInitialized) {
      score++;

      if (score % 10 == 0) {
        _increaseDifficulty();
      }
    }
  }

  void _increaseDifficulty() {
    level++;

    if (level % 2 == 0 && pipeGenerationInterval > 1.2) {
      pipeGenerationInterval = (pipeGenerationInterval - 0.1).clamp(1.2, 2.0);
      _updatePipeGeneration();
    }
  }

  bool get shouldPipesMove => _pipesMoving && gameState == GameState.playing && _isInitialized;

  // Get current difficulty description for UI
  String get difficultyDescription {
    if (!_isInitialized) return 'Loading...';

    switch (settings.difficultySync) {
      case 'easy':
        return 'Easy - Larger gaps, slower speed';
      case 'hard':
        return 'Hard - Smaller gaps, faster speed';
      default:
        return 'Normal - Balanced gameplay';
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (gameState == GameState.playing && _isInitialized) {
      textPaint.render(canvas, '$score', Vector2(size.x / 2 - 15, 100));

      // Show current difficulty in top corner
      smallTextPaint.render(
          canvas,
          difficultyDescription.split(' - ')[0],
          Vector2(20, 20)
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Ensure settings are initialized before game logic
    if (!_isInitialized) return;
  }
}