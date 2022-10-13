import 'dart:async';

import 'package:flutter/material.dart';

import '../constants.dart';

class VeggiedayCountDownScreen extends StatefulWidget {
  const VeggiedayCountDownScreen({Key? key}) : super(key: key);

  @override
  VeggiedayCountDownScreenState createState() =>
      VeggiedayCountDownScreenState();
}

class VeggiedayCountDownScreenState extends State<VeggiedayCountDownScreen> {
  Timer? timer;

  Duration? untilVeggieday =
      Constants.nextWednesday12().difference(DateTime.now());
  Duration? untilSignupClose =
      Constants.nextMonday14().difference(DateTime.now());

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        untilSignupClose = Constants.nextMonday14().difference(DateTime.now());
        untilVeggieday = Constants.nextWednesday12().difference(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var secondsUntilSignupClose = untilSignupClose!.inSeconds;
    var secondsUntilVeggieday = untilVeggieday!.inSeconds;

    Duration relevantDuration = secondsUntilVeggieday < secondsUntilSignupClose
        ? untilVeggieday!
        : untilSignupClose!;

    String nextEvent = secondsUntilVeggieday < secondsUntilSignupClose
        ? 'Veggieday'
        : 'Anmeldeschluss';

    final days = relevantDuration.inDays;
    final hours = relevantDuration.inHours.remainder(24);
    final minutes = relevantDuration.inMinutes.remainder(60);
    final seconds = relevantDuration.inSeconds.remainder(60);
    if (days > 1) {
      return Text(
          'Noch ${daysString(days)} und ${hoursString(hours)} bis zum $nextEvent!',
          style: const TextStyle(color: Colors.white));
    } else if (hours > 1) {
      return Text(
          'Noch ${hoursString(hours)} und ${minutesString(minutes)} bis zum $nextEvent!',
          style: const TextStyle(color: Colors.white));
    } else if (minutes > 1) {
      return Text(
          'Noch ${minutesString(minutes)} und ${secondsString(seconds)} bis zum $nextEvent!',
          style: const TextStyle(color: Colors.white));
    } else {
      return Text('Noch ${secondsString(seconds)} bis zum $nextEvent!',
          style: const TextStyle(color: Colors.white));
    }
  }

  String daysString(int days) => '$days ${days == 1 ? 'Tag' : 'Tage'}';
  String hoursString(int hours) =>
      '$hours ${hours == 1 ? 'Stunde' : 'Stunden'}';
  String minutesString(int minutes) =>
      '$minutes ${minutes == 1 ? 'Minute' : 'Minuten'}';
  String secondsString(int seconds) =>
      '$seconds ${seconds == 1 ? 'Sekunde' : 'Sekunden'}';
}
