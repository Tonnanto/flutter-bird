import 'package:flappy_bird/controller/flutter_bird_controller.dart';
import 'package:flappy_bird/view/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => FlutterBirdController()..init(),
      child: MaterialApp(
        title: 'Flappy Bird',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainMenuView(title: 'Flappy Bird'),
      ),
    );
  }
}
