import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SQLite for all platforms, especially for desktop
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Suan Cards',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
    );
  }
  
  ThemeData _buildDarkTheme() {
    // Paleta de colores específica para modo oscuro
    const primaryColor = Color(0xFF6A77E5);  // Tono azul-indigo más suave
    const backgroundColor = Color(0xFF121212);  // Fondo negro suave
    const surfaceColor = Color(0xFF1E1E1E);  // Superficie un poco más clara que el fondo
    const accentColor = Color(0xFF94A3FF);  // Acento azul claro
    
    return ThemeData(
      colorScheme: ColorScheme(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.black, // Texto casi blanco sobre fondo
        surface: surfaceColor,
        onSurface: const Color(0xFFE1E1E1),
        error: const Color(0xFFCF6679), // Rojo suave para errores
        onError: Colors.black,
        brightness: Brightness.dark,
        tertiary: const Color(0xFF9277E5), // Tono púrpura para acentos secundarios
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black54,
        color: const Color(0xFF252525), // Color de tarjeta ligeramente más claro
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade800, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 4,
        backgroundColor: Color(0xFF1A1A2E), // Azul muy oscuro
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      iconTheme: const IconThemeData(color: Color(0xFFBBBBBB)), // Iconos con gris claro
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: const Color(0xFFE1E1E1),
        displayColor: Colors.white,
      ),
      brightness: Brightness.dark,
      dividerColor: Colors.grey.shade800, dialogTheme: DialogThemeData(backgroundColor: surfaceColor),
    );
  }
}
