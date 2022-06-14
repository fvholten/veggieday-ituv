import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'constants.dart';
import 'custom_route.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  const LoginScreen({Key? key}) : super(key: key);

  Future<String> _loginUser(LoginData data) {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: data.name, password: data.password)
        .then((_) => '', onError: (error) {
      debugPrint(error.message);
      return error.message;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: data.name!, password: data.password!)
        .then((_) => '', onError: (error) {
      debugPrint(error.message);
      return error.message;
    });
  }

  Future<String?> _recoverPassword(String name) {
    return FirebaseAuth.instance
        .sendPasswordResetEmail(email: name)
        .then((_) => '', onError: (error) {
      debugPrint(error.message);
      return error.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => const DashboardScreen(),
        ));
      }
    });

    return FlutterLogin(
      title: Constants.appName,
      logo: const AssetImage('assets/images/ecorp.png'),
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      navigateBackAfterRecovery: true,
      loginAfterSignUp: true,
      termsOfService: [
        TermOfService(
            id: 'general-term',
            mandatory: true,
            text: 'Nutzungsbedingungen',
            linkUrl: 'https://example.com'),
      ],
      initialAuthMode: AuthMode.login,
      userValidator: (value) {
        if (!value!.endsWith('@ituv-software.de')) {
          return "Email muss eine '@ituv-software.de'-Mail sein.";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password ist leer!';
        }
        if (value.length < 6) {
          return 'Password muss mindestens 6 Zeichen haben!';
        }
        return null;
      },
      onLogin: (loginData) {
        debugPrint('Login info');
        debugPrint('Name: ${loginData.name}');
        debugPrint('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (signupData) {
        debugPrint('Signup info');
        debugPrint('Name: ${signupData.name}');
        debugPrint('Password: ${signupData.password}');

        signupData.additionalSignupData?.forEach((key, value) {
          debugPrint('$key: $value');
        });
        if (signupData.termsOfService.isNotEmpty) {
          debugPrint('Terms of service: ');
          for (var element in signupData.termsOfService) {
            debugPrint(
                ' - ${element.term.id}: ${element.accepted == true ? 'accepted' : 'rejected'}');
          }
        }
        return _signupUser(signupData);
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => const DashboardScreen(),
        ));
      },
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
    );
  }
}
