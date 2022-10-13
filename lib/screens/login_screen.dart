import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';

class LoginScreen extends StatelessWidget {
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

  Future<String?> _recoverPassword(String email) {
    return FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((_) => '', onError: (error) {
      debugPrint(error.message);
      return error.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: Constants.appName,
      logo: const AssetImage('assets/images/ituvlong.png'),
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      navigateBackAfterRecovery: true,
      loginAfterSignUp: true,
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
        return _signupUser(signupData);
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
