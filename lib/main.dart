// import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixelline/helper/databse.dart';
import 'package:pixelline/screens/AuthScreen/auth_screen.dart';
import 'package:pixelline/screens/LocalAuthScreen/local_auth_screen.dart';
import 'package:pixelline/services/GlobalContext/global_context.dart';
import 'package:pixelline/util/functions.dart';
import 'package:pixelline/util/util.dart';
import 'services/Appwrite/appwrite_sevices.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'wallpaper_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  Permission.storage.request();
  Permission.manageExternalStorage.request();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  await dotenv.load(fileName: ".env");

  await WallpaperDatabaseHelper().initDb();
  runApp(const WallpaperApp());
}

class WallpaperApp extends StatefulWidget {
  const WallpaperApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WallpaperAppState createState() => _WallpaperAppState();
}

class _WallpaperAppState extends State<WallpaperApp> {
  Future<bool>? _userSessionFuture;
  Future<bool>? islockedEnabled;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();

    _userSessionFuture = checkUserSession();
    checkIsLocked();
  }

  MaterialColor createMaterialColor(Color color) {
    Map<int, Color> swatch = {
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color.withOpacity(0.6),
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color.withOpacity(1.0),
    };
    return MaterialColor(color.value, swatch);
  }

  void checkIsLocked() async {
    try {
      var prefs = await account.getPrefs();

      setState(() {
        isLocked = prefs.data['isLocked'] ?? false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user preferences: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        navigatorKey: GlobalContext.navigatorKey,
        title: 'Pixelline',
        theme: ThemeData(
          primarySwatch: createMaterialColor(Colors.black),
          fontFamily: 'garamond',
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            backgroundColor: Colors.black,
            contentTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: FutureBuilder<bool>(
          future: _userSessionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: CircularIndicator(),
              );
            } else {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              } else {
                if (snapshot.data == true) {
                  if (kDebugMode) {
                    print(snapshot.data);
                  }
                  if (isLocked) {
                    return const LocalAuthScreen();
                  } else {
                    return const WallpaperScreen();
                  }
                } else {
                  if (kDebugMode) {
                    print(snapshot.data);
                  }
                  return const AuthScreen();
                }
              }
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
