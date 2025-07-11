import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_adoption_app/firebase_options.dart';
import 'package:pet_adoption_app/src/core/constants/app_constants.dart';
import 'package:pet_adoption_app/src/core/di/index.dart' as di;
import 'package:pet_adoption_app/src/core/utils/timeago_config.dart';
import 'package:pet_adoption_app/src/presentation/config/routes/index.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/authentication_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/onboarding_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_registration_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/theme_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  TimeAgoConfig.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.init();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => OnboardingProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => PetRegistrationProvider()),
        ChangeNotifierProvider(create: (_) => AdoptionRequestProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.currentThemeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
