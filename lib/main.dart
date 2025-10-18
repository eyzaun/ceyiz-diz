import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'core/themes/theme_provider.dart';
import 'core/services/version_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/providers/trousseau_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/router/app_router.dart';
import 'presentation/widgets/common/web_frame.dart';
import 'presentation/widgets/dialogs/update_available_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase App Check with Debug Token support
  if (kIsWeb) {
    // Web: ReCAPTCHA Enterprise provider (gerekli tip)
    try {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaEnterpriseProvider(
          '6LeLa-srAAAAAC7WSsymHEKckyhM8pocD01RMB6e',
        ),
      );
      
    } catch (e) {
      // App Check initialization failed
    }
  } else {
    // Android/iOS: Use debug provider in debug mode, Play Integrity in release
    if (kDebugMode) {
      // Debug mode: Use debug provider - automatically generates token
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      
    } else {
      // Release mode: Use Play Integrity
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
    }
  }
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Web version check (4 saniye sonra kontrol et - uygulama tamamen yüklendikten sonra)
    if (kIsWeb) {
      Future.delayed(const Duration(seconds: 4), _checkVersion);
    }
  }

  Future<void> _checkVersion() async {
    try {
      final result = await VersionService.checkVersion();
      
      if (result.needsUpdate && mounted) {
        // Navigator hazır olana kadar bekle
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        // Get the navigator context
        final navigatorContext = AppRouter.router.routerDelegate.navigatorKey.currentContext;
        if (navigatorContext != null && navigatorContext.mounted) {
          UpdateAvailableDialog.show(navigatorContext, result);
        }
      }
    } catch (e) {
      // Version check failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(widget.prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(),
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
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Çeyiz Diz',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            routerConfig: AppRouter.router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => WebAppFrame(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}