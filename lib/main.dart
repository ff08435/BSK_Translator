import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaran/screens/welcome_screen.dart'; // changed back
import 'package:yaran/utils/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://tzupvoqxizpxserbvzob.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6dXB2b3F4aXpweHNlcmJ2em9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2ODA2ODMsImV4cCI6MjA4NDI1NjY4M30.0TNbEdsZvF7cXlc41Vhbr096S1A9OLWUIwWWhQNB-_c',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YARAN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentOrange,
          brightness: Brightness.dark,
        ),
      ),
      home: const WelcomeScreen(), // back to welcome screen
    );
  }
}
