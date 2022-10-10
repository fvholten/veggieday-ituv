import 'package:veggieday_ituv/domain/food.dart';
import 'package:veggieday_ituv/domain/task.dart';

class VeggiedaySignUp {
  bool isSingedUp = false;
  String? name;
  Task? task;
  Food? food;

  VeggiedaySignUp.empty();

  VeggiedaySignUp(this.isSingedUp, this.name, this.task, this.food);
}
