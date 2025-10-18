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
      
      if (kDebugMode) {
        debugPrint('🌐 Web: App Check aktif (ReCAPTCHA Enterprise)');
        try {
          await FirebaseAppCheck.instance.getToken();
          debugPrint('✅ Web App Check token alındı');
        } catch (e) {
          debugPrint('⚠️  Token hatası: $e');
        }
      } else {
        debugPrint('🌐 Web: App Check aktif (Production mode)');
      }
    } catch (e) {
      debugPrint('❌ Web App Check başlatılamadı: $e');
    }
  } else {
    // Android/iOS: Use debug provider in debug mode, Play Integrity in release
    if (kDebugMode) {
      // Debug mode: Use debug provider - automatically generates token
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      
      // Wait for token to be generated
      await Future.delayed(const Duration(seconds: 2));
      try {
        final token = await FirebaseAppCheck.instance.getToken();
        if (token != null) {
          debugPrint('');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('🔐 FIREBASE APP CHECK DEBUG TOKEN');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('');
          debugPrint('Token: $token');
          debugPrint('');
          debugPrint('📋 BU TOKEN\'I FIREBASE CONSOLE\'A EKLEYİN:');
          debugPrint('');
          debugPrint('1. https://console.firebase.google.com/project/ceyiz-diz/appcheck');
          debugPrint('2. "Apps" sekmesinde Android app\'i bulun');
          debugPrint('3. "Manage debug tokens" tıklayın');
          debugPrint('4. "Add debug token" tıklayın');
          debugPrint('5. Yukarıdaki token\'ı yapıştırın ve kaydedin');
          debugPrint('');
          debugPrint('⚠️  NOT: Token kaydettikten sonra uygulamayı yeniden başlatın!');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('');
        }
      } catch (e) {
        debugPrint('⚠️  Debug token alınamadı: $e');
      }
    } else {
      // Release mode: Use Play Integrity
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
      debugPrint('✅ App Check: Play Integrity aktif (Release mode)');
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
      if (kDebugMode) {
        debugPrint('⚠️ Version check failed: $e');
      }
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