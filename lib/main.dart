import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'core/routes/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Offline Persistence
  try {
    await FirebaseFirestore.instance.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );
  } catch (e) {
    print('Persistence not supported: $e');
  }

  runApp(const ProviderScope(child: RetailPosApp()));
}

class RetailPosApp extends ConsumerWidget {
  const RetailPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Retail POS',
      debugShowCheckedModeBanner: false,
      theme: _buildHighContrastTheme(),
      routerConfig: router,
    );
  }

  ThemeData _buildHighContrastTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.black87,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme).apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ).copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: const TextStyle(fontSize: 18, color: Colors.black),
        labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

    );
  }
}
