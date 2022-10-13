import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import "package:flame/game.dart";
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends FlameGame with TapDetector{

  var dash;
  var background;
  var ground;
  var pipe;
  var spriteSheet;
  var idleAnimation;
  var tapAnimation;

  var tapped=0;
  var count=0;


  TextPaint textPaint = TextPaint(
  style: GoogleFonts.vt323(
    textStyle:const TextStyle(
    fontSize: 60.0,
    fontWeight:FontWeight.bold
   )
  ),
);

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
      position:Vector2(screenWidth, -screenHeight/1.5),
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

    spriteSheet=SpriteSheet(image: await images.load("dash.png"), srcSize:Vector2(700, 500));

    idleAnimation=spriteSheet.createAnimation(row:0, stepTime:0.1, to:1);
    tapAnimation=spriteSheet.createAnimation(row: 0, stepTime:0.1, from:1, to:2);

    dash=SpriteAnimationComponent(
      animation:idleAnimation,
      position:Vector2(screenWidth/6, screenWidth/2),
      size:Vector2(screenWidth/9, screenHeight/20),
      angle:0
    );

    add(dash);

  }

  @override
  void update(dt) async{
    super.update(dt);
    pipe.x=pipe.x-3.5;
    dash.y=dash.y+1.75;
    dash.angle=dash.angle+0.002;

    var random=Random();
    var randomNumber=random.nextInt(340)+100;

    if(tapped==0){
      dash.animation=idleAnimation;
    }else{
      dash.animation=tapAnimation;
    }

    if(pipe.x<-size[0]+300){
      pipe.x=size[0];
      pipe.y=-size[1]+randomNumber;
      count++;
    }

  
  }

  @override
  void onTap() async{
    tapped++;
    dash.angle=dash.angle-0.075;
    dash.y=dash.y-50;
    if(tapped>1){
      tapped=0;
    }
  }

  @override
  void render(canvas){
    super.render(canvas);
    textPaint.render(canvas, "$count", Vector2(size[0]/2.2, size[1]/20));
  }
}