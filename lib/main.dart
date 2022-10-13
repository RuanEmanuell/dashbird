import 'package:flutter/material.dart';
import "package:flame/game.dart";

import "screens/game.dart";

Future<void> main() async {
  runApp(
      MaterialApp(
        initialRoute: "/home", 
        routes: {
          "/home": (context) => GameWidget(game:GameScreen())
        }
      )
  );
}
