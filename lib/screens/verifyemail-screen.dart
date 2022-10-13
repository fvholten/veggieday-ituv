import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/veggieday_appbar.dart';
import 'dashboard_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  VerifyEmailScreenState createState() => VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;

    isEmailVerified = user!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
          const Duration(seconds: 5), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    await user!.sendEmailVerification();

    setState(() => canResendEmail = false);
    await Future.delayed(const Duration(seconds: 15));
    setState(() => canResendEmail = true);
  }

  Future checkEmailVerified() async {
    await user!.reload();

    setState(() {
      isEmailVerified = user!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const DashboardScreen()
      : Scaffold(
          appBar: const VeggiedayAppBar(
                title: 'Email verifizieren!',
                key: Key('VerifyEmail-Appbar'),
              ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    'Eine Verifizierungs-Email wurde an "${user!.email}" gesendet. ' +
                        'Bitte die Anmeldung über den Link bestätigen!'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    icon: canResendEmail
                        ? const Icon(Icons.email, size: 24)
                        : Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.grey,
                              strokeWidth: 3,
                            ),
                          ),
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    label: const Text('Erneut senden!')),
                const SizedBox(height: 8),
                TextButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    onPressed: FirebaseAuth.instance.signOut,
                    child: const Text('Abbrechen'))
              ],
            ),
          ));
}
