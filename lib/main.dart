import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'web_admin_login.dart';
import 'web_admin_dashboard.dart';
import 'mobile_customer_login.dart';
import 'mobile_customer_products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Store Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 207, 162, 74)),
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                body: Center(child: CircularProgressIndicator())
            );
          }

          if (snapshot.hasData) {
            return kIsWeb ? AdminDashboard() : CustomerProducts();
          } else {
            return kIsWeb ? AdminLogin() : CustomerLogin();
          }
        },
      ),
    );
  }
}