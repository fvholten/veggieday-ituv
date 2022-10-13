import 'package:veggieday_ituv/utils/datetime-ext.dart';

class Constants {
  static const String appName = 'Veggieday';
  static const String logoTag = 'de.ituv.veggieday.logo';
  static const String titleTag = 'de.ituv.veggieday.title';

  static const String signupCollectionName = 'signups';
  static const String taskCollectionName = 'task';
  static const String foodCollectionName = 'food_choices';
  static const String foodFieldName = 'food';
  static const String nameFieldName = 'name';
  static const String taskFieldName = 'task';
  static const String veggiedayFieldName = 'veggieday';

  static DateTime nextMonday14() => DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 14)
      .next(DateTime.monday);

  static DateTime nextWednesday12() => DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 12)
      .next(DateTime.wednesday);

  static bool signupClosed() {
    Duration? untilVeggieday =
        Constants.nextMonday14().difference(DateTime.now());
    Duration? untilSignupClose =
        Constants.nextWednesday12().difference(DateTime.now());

    var secondsUntilSignupClose = untilSignupClose.inSeconds;
    var secondsUntilVeggieday = untilVeggieday.inSeconds;

    return secondsUntilVeggieday > secondsUntilSignupClose;
  }

  static bool signupOpen() {
    return !signupClosed();
  }
}
