import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:utilwise/Pages/auth_pages/splash.dart';
import 'package:utilwise/Pages/main_pages/home_page.dart';

import 'Pages/auth_pages/phone.dart';
import 'Pages/main_pages/no_internet_page.dart';
import 'provider/data_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'OpenSans',
          scaffoldBackgroundColor: Colors.green.shade50,
        ),
        home: const SplashPage(),
        routes: {
          '/home': (context) => const MyHomePage(),
          '/login': (context) => const MyPhone(),
          '/noInternet': (context) => const NoInternetPage(),
        },
      ),
    );
  }
}
