import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'transition_route_observer.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('USER: ${FirebaseAuth.instance.currentUser}');
    return MaterialApp(
      title: 'IT.UV//Veggieday',
      theme: ThemeData(primarySwatch: Colors.blue),
      navigatorObservers: [TransitionRouteObserver()],
      initialRoute: (FirebaseAuth.instance.currentUser != null)
          ? DashboardScreen.routeName
          : LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
      },
    );
  }
}
