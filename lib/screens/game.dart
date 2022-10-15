import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import "package:flame/game.dart";
import "package:flame/input.dart";
import 'package:google_fonts/google_fonts.dart';

bool died = false;

class GameScreen extends FlameGame with TapDetector, HasCollisionDetection {
  int count = 0;
  int highCount = 0;
  bool up = false;
  int removeButton = 0;

  void playDeath() async {
    restartButton = SpriteComponent()
      ..sprite = await loadSprite("restart.png")
      ..position = Vector2(size[0] / 6, size[1] / 3)
      ..size = Vector2(size[0] / 1.5, size[1] / 3);

    if (removeButton == 1) {
      add(restartButton);
    }
  }

  void movePipeY() {
    var random = Random().nextInt(200);
    if (up) {
      pipe1.y = pipe1.y + random;
      pipe2.y = pipe2.y + random;
    } else {
      pipe1.y = pipe1.y - random;
      pipe2.y = pipe2.y - random;
    }

    print(pipe1.y);
  }

  void movePipeX() {
    pipe1.x = size[0];
    pipe2.x = size[0];
  }

  void resetGame() async {
    playDeath();

    if (removeButton == 2) {
      count = 0;
      tapped = 0;
      died = false;
      removeButton = 0;
      remove(restartButton);
      dash.angle = 0.1;
      dash.y = size[1] / 2;
      pipe1.x = size[0];
      pipe2.x = size[0];
      pipe1.y = -size[1] / 1.65;
      pipe2.y = -pipe1.y;
    }
  }

  late SpriteAnimationComponent dash;
  late ParallaxComponent background;
  late SpriteComponent ground;
  late SpriteComponent pipe1;
  late SpriteComponent pipe2;
  late SpriteComponent restartButton;
  late SpriteSheet spriteSheet;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation tapAnimation;

  int tapped = 0;

  //Defining how the text will be displayed
  TextPaint textPaint = TextPaint(
    style: GoogleFonts.vt323(
      textStyle: const TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    FlameAudio.bgm.play("music.mp3", volume: 0.4);
    FlameAudio.audioCache.load("pipesound.mp3");

    //Taking the width and height of the screen
    final screenWidth = size[0];
    final screenHeight = size[1];

    //Loading the game assets

    background = await ParallaxComponent.load([ParallaxImageData("background.png")],
        baseVelocity: Vector2(10, 0), velocityMultiplierDelta: Vector2.all(10), size: size);

    add(background);

    pipe1 = Pipe()
      ..sprite = await loadSprite("pipe1.png")
      ..size = Vector2(screenWidth / 4, screenHeight)
      ..position = Vector2(screenWidth, -screenHeight / 1.65);

    add(pipe1);

    pipe2 = Pipe()
      ..sprite = await loadSprite("pipe2.png")
      ..size = pipe1.size
      ..position = Vector2(screenWidth, -pipe1.y);

    add(pipe2);

    ground = Ground()
      ..sprite = await loadSprite("ground.png")
      ..position = Vector2(0, screenHeight / 1.05)
      ..size = Vector2(screenWidth, screenHeight / 3);

    add(ground);

    spriteSheet = SpriteSheet(image: await images.load("dash.png"), srcSize: Vector2(700, 500));

    idleAnimation = spriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 1);
    tapAnimation = spriteSheet.createAnimation(row: 0, stepTime: 0.1, from: 1, to: 2);

    dash = Dash()
      ..animation = idleAnimation
      ..position = Vector2(screenWidth / 6, screenHeight / 2)
      ..size = Vector2(screenWidth / 6, screenHeight / 16)
      ..angle = 0;

    add(dash);
  }

  @override
  void update(dt) async {
    super.update(dt);

    /*If the player don't died, we move the pipes horizontally and the player
    vertically and change his angle to give the impression of falling
    */
    if (!died) {
      pipe1.x = pipe1.x - 3.5;
      pipe2.x = pipe2.x - 3.5;
      dash.y = dash.y + 3;
      dash.angle = dash.angle + 0.005;

      //Deciding which animation will be showed
      if (tapped == 0) {
        dash.animation = idleAnimation;
      } else {
        dash.animation = tapAnimation;
      }

      /*If the pipe passed the screenWidth, we play the sound, increase the count,
    move it to the other side of the screen and give it a random height
    */
      if (pipe1.x < -size[0]/2.2) {
        count++;
        up = !up;

        movePipeX();

        movePipeY();

        await FlameAudio.play("pipesound.mp3");
      }
    } else {
      /*If the player died, we remove his ability to change animations and
      increase angle and height
      */
      tapped = 1;
      //If the pipe count was higher than the highscore, we set it as the highscore
      if (count > highCount) {
        highCount = count;
      }
      /*Making Dash "fall" until he reaches the ground
      */
      if (dash.y < ground.y - dash.size[1]) {
        dash.y = dash.y + 10;
      }
    }
  }

  @override
  void onTap() async {
    //If the player is still alive, each tap will increase his height and angle
    if (!died) {
      tapped++;
      dash.angle = dash.angle - 0.09;
      dash.y = dash.y - size[1]/15;
      //Reseting the tap count to handle Dash's animation
      if (tapped > 1) {
        tapped = 0;
      }
    } else {
      //If the player died and taps on the screen 2 times, we reset the game
      removeButton++;
      resetGame();
    }
  }

  @override
  void render(canvas) {
    super.render(canvas);
    /*If he don't died it will only show the score, if he dies and not taps it
    will display a message, else it will be the Highscore and the restart button*/
    if (!died) {
      textPaint.render(canvas, "$count", Vector2(size[0] / 2.25, size[1] / 20));
    } else if (removeButton == 0) {
      textPaint.render(canvas, "$count", Vector2(size[0] / 2.25, size[1] / 20));
      textPaint.render(canvas, "YOU DIED!", Vector2(size[0] / 5, size[1] / 2));
    } else {
      textPaint.render(canvas, "Highscore: $highCount", Vector2(size[0] / 7.5, size[1] / 1.5));
      textPaint.render(canvas, "Highscore: $highCount", Vector2(size[0] / 7.5, size[1] / 1.5));
    }
  }
}

//Adding the collisions to Dash, Pipe and the Ground

class Dash extends SpriteAnimationComponent with CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent dash) {
    if (dash is Pipe) {
      died = true;
    }
  }
}

class Pipe extends SpriteComponent with CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }
}

class Ground extends SpriteComponent with CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent ground) {
    if (ground is Dash) {
      died = true;
    }
  }
}
