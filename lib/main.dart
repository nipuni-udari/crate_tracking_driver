import 'package:crate_tracking_driver/screens/vehicle_checking.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Set the background color
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => SplashScreen(),
        '/vehicle': (context) => VehicleScreen(),
        '/home': (context) => HomeScreen(vehicleNumber: ''),
      },
    );
  }
}
