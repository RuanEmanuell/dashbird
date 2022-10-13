import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import "package:flame/game.dart";

class GameScreen extends FlameGame with TapDetector{

  var dash;
  var background;
  var ground;
  var pipe;
  var spriteSheet;
  var idleAnimation;
  var tapAnimation;

  var tapped=0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final screenWidth=size[0];
    final screenHeight=size[1];

    
    background=await ParallaxComponent.load(
      [
        ParallaxImageData("background.png")
      ],
      baseVelocity: Vector2(10,0),
      velocityMultiplierDelta: Vector2.all(10),
      size:size
    );

    add(background);


    pipe=SpriteComponent(
      sprite:await loadSprite("pipe.png"),
      size:Vector2(screenWidth/5, screenHeight*2), 
      position:Vector2(screenWidth/2, -600),
      );

    add(pipe);



    ground=await ParallaxComponent.load(
      [
        ParallaxImageData("ground.png")
      ],
      baseVelocity: Vector2(10,0),
      velocityMultiplierDelta: Vector2.all(10),
      position: Vector2(0, screenHeight/1.25),
      size:Vector2(screenWidth, screenHeight/3)
    );

    add(ground);

    spriteSheet=SpriteSheet(image: await images.load("dash.png"), srcSize:Vector2(680, 500));

    idleAnimation=spriteSheet.createAnimation(row:0, stepTime:0.1, to:1);
    tapAnimation=spriteSheet.createAnimation(row: 0, stepTime:0.1, from:1, to:2);

    dash=SpriteAnimationComponent(
      animation:idleAnimation,
      position:Vector2(screenWidth/6, screenWidth/2),
      size:Vector2(screenWidth/4, screenHeight/9)
    );

    add(dash);

    camera.followComponent(dash);
  }

  @override
  void update(dt) async{
    super.update(dt);
    dash.x=dash.x+1;

    if(tapped==0){
      dash.animation=idleAnimation;
    }else{
      dash.animation=tapAnimation;
    }

  
  }

  @override
  void onTap() async{
    tapped++;
    if(tapped>1){
      tapped=0;
    }
  }
}