import 'package:flutter/material.dart';
import 'package:story_maker/screens/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fablet',
        theme: _buildLightTheme(),
        //darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: HomePage()
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      appBarTheme: AppBarTheme(
          color: Color(0xFF1E1F23),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontFamily: 'Thaleah',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
      iconTheme: IconThemeData(color: Colors.white),
      scaffoldBackgroundColor: Color(0xFF1E1F23),
      primaryColor: Colors.blue,
      hintColor: Colors.orange,
      fontFamily: 'Minecraft',
      brightness: Brightness.light,
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontFamily: 'Minecraft', fontSize: 18),
        bodySmall: TextStyle(fontFamily: 'Thaleah', fontSize: 16),
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.orange,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primaryColor: Colors.deepPurple,
      hintColor: Colors.amber,
      fontFamily: 'Minecraft', // İkinci font
      brightness: Brightness.dark,
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontFamily: 'Minecraft', fontSize: 18),
        bodySmall: TextStyle(fontFamily: 'Thaleah', fontSize: 16),
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.deepPurple,
        secondary: Colors.amber,
      ),
    );
  }
}


