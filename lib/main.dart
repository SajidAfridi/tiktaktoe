import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiktaktoe/pages/welcome_and_difficulty_selection_screen.dart';

import 'classes/multiplayer_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => MultiplayerService('https://spiny-trite-breeze.glitch.me/')),
      ],
      child: MaterialApp(
        title: 'TikTakToe',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SelectDifficultyScreen(),
      ),
    );
  }
}
