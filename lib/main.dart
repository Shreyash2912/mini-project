import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/app_state.dart';
import 'screens/onboarding/language_select_screen.dart';
import 'screens/shell/root_nav.dart';
import 'screens/premium/premium_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Lingo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF58CC02)),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            home: _buildStart(appState),
            routes: {
              LanguageSelectScreen.routeName: (_) => const LanguageSelectScreen(),
              '/premium': (_) => const PremiumScreen(),
              RootNav.routeName: (_) => const RootNav(),
            },
          );
        },
      ),
    );
  }

  Widget _buildStart(AppState app) {
    if (!app.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (app.targetLanguageCode == null) {
      return const LanguageSelectScreen();
    }

    return const RootNav();
  }
}
