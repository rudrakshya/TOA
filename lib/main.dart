import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import './modules/profile/profile.dart';
import '../modules/Vehicle/vehicle.dart';
import './modules/Dashboard/dashboard.dart';
import './modules/scanner/scanner.dart';
import './modules/Vehicle/create_vehicle.dart';
import './modules/qr_generate/qr_generate.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  await dotenv.load(fileName: ".env");
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  late String initialRoute = "/";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          color: Colors.blue, // Explicitly setting AppBar color
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
        brightness: null,
      ),
      // home: const Scanner(),
      initialRoute: initialRoute,
      navigatorKey: navigatorKey,
      routes: {
        '/': (BuildContext context) => const Scanner(),
        // '/dashboard': (BuildContext context) => const Dashboard(),
        // '/vehicle': (BuildContext context) => const Vehicle(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          return CupertinoPageRoute(
            builder: (context) => const Dashboard(),
            settings: settings,
          );
        }
        if (settings.name == '/vehicle') {
          return CupertinoPageRoute(
            builder: (context) => const Vehicle(),
            settings: settings,
          );
        }

        if (settings.name == '/create_vehicle') {
          final args = settings.arguments as Map<String, dynamic>;
          return CupertinoPageRoute(
            builder: (context) => CreateVehicle(
              regNo: args['regNo'] as String,
              ownerName: args['ownerName'] as String,
              mobileNumber: args['mobileNumber'] as String,
              id: args['id'] as int,
            ),
            settings: settings,
          );
        }
        if (settings.name == '/qr_generate') {
          final args = settings.arguments as Map<String, dynamic>;
          return CupertinoPageRoute(
            builder: (context) => QRGenerate(
              regNo: args['regNo'] as String,
            ),
            settings: settings,
          );
        }

        if (settings.name == '/profile') {
          return CupertinoPageRoute(
            builder: (context) => const Profile(),
            settings: settings,
          );
        }
        // Handle other routes or return null
        return null;
      },
    );
  }
}
