import 'package:cucinami/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  // inizializza il binding
  WidgetsFlutterBinding.ensureInitialized();

  // Nasconde barra superiore e inferiore (fullscreen totale)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Blocca l'orientamento in verticale
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cucinami',

      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark, // o Brightness.light
          primary: Color(0xFFCBCACA),
          onPrimary: Color(0xFF1A1A1A),
          secondary: Color(0xFFF8E1A2),
          onSecondary: Color(0xFF000000),
          error: Color(0xFF980D0D),
          onError: Colors.white,
          onSurface: Color(0xFFE3E2E2),
          surface: Color(0xFF000000),
        ),
        useMaterial3: true,
      ),

      home: Home(nomeRicetta: '',),
    );
  }
}


