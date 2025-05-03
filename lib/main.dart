import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';

void main() {
  runApp(CarDamageAIApp());
}

class CarDamageAIApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  CarDamageAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoAssess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'PT-Mono',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _authService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSplashScreen();
          }

          final isLoggedIn = snapshot.data ?? false;

          if (isLoggedIn) {
            return HomeScreen();
          } else {
            return FutureBuilder<bool>(
              future: _hasSeenOnboarding(),
              builder: (context, onboardingSnapshot) {
                if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final hasSeenOnboarding = onboardingSnapshot.data ?? false;
                return hasSeenOnboarding ? AuthScreen() : OnboardingScreen();
              },
            );
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> _hasSeenOnboarding() async {
    return await PreferencesService().hasSeenOnboarding();
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.car_repair,
              size: 80,
              color: Colors.blueGrey[700],
            ),
            SizedBox(height: 24),
            Text(
              'AutoAssess',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}


// // main.dart
// import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Insurance App',
//       theme: ThemeData(
//         primaryColor: Color(0xFF6366F1),
//         scaffoldBackgroundColor: Color(0xFFF6F7F9),
//         fontFamily: 'Roboto',
//         appBarTheme: AppBarTheme(
//           backgroundColor: Color(0xFF6366F1),
//           elevation: 0,
//         ),
//       ),
//       home: HomeScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }