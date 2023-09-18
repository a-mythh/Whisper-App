import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// screens
import 'package:chat_app/screens/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

final theme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme:
      ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 118, 240)),
  textTheme: GoogleFonts.ubuntuTextTheme(),
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: theme,
      home: const AuthScreen(),
    );
  }
}
