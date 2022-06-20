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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('USER: ${FirebaseAuth.instance.currentUser}');
    return MaterialApp(
      title: 'IT.UV//Veggieday',
      theme: ThemeData(
          textSelectionTheme:
              const TextSelectionThemeData(cursorColor: Colors.black),
          // fontFamily: 'SourceSansPro',
          textTheme: TextTheme(
            headline3: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 60.0,
              fontWeight: FontWeight.w400,
              color: Colors.blue[900],
            ),
            button: const TextStyle(
              // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
              fontFamily: 'OpenSans',
            ),
            caption: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
              color: Colors.blue[300],
            ),
            headline1: const TextStyle(fontFamily: 'Quicksand'),
            headline2: const TextStyle(fontFamily: 'Quicksand'),
            headline4: const TextStyle(fontFamily: 'Quicksand'),
            headline5: const TextStyle(fontFamily: 'NotoSans'),
            headline6: const TextStyle(fontFamily: 'NotoSans'),
            subtitle1: const TextStyle(fontFamily: 'NotoSans'),
            bodyText1: const TextStyle(fontFamily: 'NotoSans'),
            bodyText2: const TextStyle(fontFamily: 'NotoSans'),
            subtitle2: const TextStyle(fontFamily: 'NotoSans'),
            overline: const TextStyle(fontFamily: 'NotoSans'),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.blueGrey)),
      navigatorObservers: [TransitionRouteObserver()],
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
      },
    );
  }
}
