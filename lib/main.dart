import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ATBApp());
}

class ATBApp extends StatelessWidget {
  const ATBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TGAP',
      debugShowCheckedModeBanner: false,
      theme: ATBTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
