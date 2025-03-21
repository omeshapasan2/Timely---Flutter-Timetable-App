import 'package:flutter/material.dart';
import 'package:timetable/input.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'timetable_entry.dart';
import 'display.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register the Hive adapter for TimetableEntry
  Hive.registerAdapter(TimetableEntryAdapter());

  // Open the Hive box
  await Hive.openBox('timetableBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timetable App',
      theme: ThemeData.dark().copyWith(
        // AMOLED black theme
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Color(0xFF121212), // Dark gray for cards
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white,
                width: 5.0,
              ),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey[800]!,
          surface: Colors.black,
          background: Colors.black,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        primaryColor: Colors.black,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.grey[400]),
          titleMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          fillColor: Colors.black,
          filled: true,
          labelStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
      home: DisplayPage(),
    );
  }
}
