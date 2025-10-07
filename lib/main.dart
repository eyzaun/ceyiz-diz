import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'core/themes/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/trousseau_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Optionally initialize Firebase App Check on web if a site key is provided at build time
  const appCheckSiteKey = String.fromEnvironment('APP_CHECK_RECAPTCHA_V3_SITE_KEY');
  if (kIsWeb && appCheckSiteKey.isNotEmpty) {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(appCheckSiteKey),
    );
  }
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TrousseauProvider>(
          create: (_) => TrousseauProvider(),
          update: (_, auth, trousseau) => trousseau!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (_, auth, product) => product!..updateAuth(auth),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Çeyiz Diz',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}