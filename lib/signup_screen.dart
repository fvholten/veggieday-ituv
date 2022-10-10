import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:veggieday_ituv/constants.dart';
import 'package:veggieday_ituv/domain/food.dart';
import 'package:veggieday_ituv/domain/task.dart';
import 'package:veggieday_ituv/datetime-ext.dart';
import 'package:veggieday_ituv/domain/veggieday_signup.dart';

class VeggiedaySignUpForm extends StatefulWidget {
  const VeggiedaySignUpForm(
      {super.key,
      required this.signup,
      required this.foods,
      required this.tasks});

  final VeggiedaySignUp signup;
  final List<Food> foods;
  final List<Task> tasks;

  @override
  VeggiedaySignUpFormState createState() => VeggiedaySignUpFormState();
}

class VeggiedaySignUpFormState extends State<VeggiedaySignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final db = FirebaseFirestore.instance;

  TextEditingController nameEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameEditingController.text = widget.signup.name ?? '';
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor.withOpacity(.1),
        title: const Text('Anmeldung zum Veggieday'),
      ),
      body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Wrap(
                  runSpacing: 20,
                  children: [
                    // Enter your name here
                    createNameTextField(),
                    createFoodChoiceDropdown(),
                    createTaskChoiceDropdown(),
                    Builder(builder: (context) {
                      if (widget.signup.isSingedUp) {
                        return updateSignupButtons(context);
                      } else {
                        return newSignupButtons(context);
                      }
                    }),
                  ],
                ),
              ))),
    );
  }

  DropdownButtonFormField<Task> createTaskChoiceDropdown() {
    return DropdownButtonFormField(
      items: widget.tasks
          .map((item) => DropdownMenuItem<Task>(
                value: item,
                child: Text('${item.description} (${item.signupsCount})'),
              ))
          .toList(),
      decoration: const InputDecoration(
        labelText: 'Aufgabe (Anmeldungen)',
        border: OutlineInputBorder(),
      ),
      value: widget.signup.task,
      onChanged: (value) => widget.signup.task = value as Task,
    );
  }

  DropdownButtonFormField<Food> createFoodChoiceDropdown() {
    return DropdownButtonFormField(
      decoration: const InputDecoration(
        labelText: 'Essenswahl',
        border: OutlineInputBorder(),
      ),
      value: widget.signup.food,
      onChanged: (value) => widget.signup.food = value as Food,
      selectedItemBuilder: (context) {
        return widget.foods.map<Widget>((item) {
          return Container(
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(minWidth: 100),
            child: Text(item.name),
          );
        }).toList();
      },
      items: widget.foods
          .map((item) => DropdownMenuItem<Food>(
                value: item,
                child: Text(item.description),
              ))
          .toList(),
    );
  }

  Row updateSignupButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () => deleteSignup(context),
          child: const Text('Löschen'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => doSignup(context),
          child: const Text('Aktualisieren'),
        ),
      ],
    );
  }

  Row newSignupButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => doSignup(context),
          child: const Text('Anmelden!'),
        ),
      ],
    );
  }

  void doSignup(BuildContext context) {
    debugPrint(
        'NAME:${nameEditingController.text} FOOD:${widget.signup.food} TASK:${widget.signup.task}');
    if (_formKey.currentState?.validate() ?? false) {
      debugPrint('Form Valid!');
      String userEMail = FirebaseAuth.instance.currentUser!.email!;
      DateTime dateOfVeggieDay = DateTime.now().next(DateTime.wednesday);
      String veggiedayDate = DateFormat('yyyy_MM_dd').format(dateOfVeggieDay);

      DateTime plainDateOfVeggieday = DateTime(
          dateOfVeggieDay.year, dateOfVeggieDay.month, dateOfVeggieDay.day);
      debugPrint(plainDateOfVeggieday.toString());

      db
          .collection(Constants.signupCollectionName)
          .doc('$veggiedayDate-$userEMail')
          .set({
            Constants.nameFieldName: nameEditingController.text,
            'uid': FirebaseAuth.instance.currentUser?.uid,
            Constants.veggiedayFieldName: plainDateOfVeggieday,
            Constants.foodFieldName: widget.signup.food!.name,
            Constants.taskFieldName: widget.signup.task!.name
          }, SetOptions(merge: true))
          .onError((e, _) => debugPrint("Error writing document: $e"))
          .then((value) => Navigator.pop(context));
    }
  }

  void deleteSignup(BuildContext context) {
    if (widget.signup.isSingedUp) {
      String userEMail = FirebaseAuth.instance.currentUser!.email!;
      DateTime dateOfVeggieDay = DateTime.now().next(DateTime.wednesday);
      String veggiedayDate = DateFormat('yyyy_MM_dd').format(dateOfVeggieDay);

      DateTime plainDateOfVeggieday = DateTime(
          dateOfVeggieDay.year, dateOfVeggieDay.month, dateOfVeggieDay.day);
      debugPrint(plainDateOfVeggieday.toString());

      db
          .collection(Constants.signupCollectionName)
          .doc('$veggiedayDate-$userEMail')
          .delete()
          .onError((e, _) => debugPrint("Error deleting document: $e"))
          .then((value) => Navigator.pop(context));
    }
  }

  TextFormField createNameTextField() {
    return TextFormField(
      controller: nameEditingController,
      keyboardType: TextInputType.text,
      autocorrect: false,
      autofillHints: const {AutofillHints.name},
      decoration: const InputDecoration(
        labelText: 'Dein Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bitte gib einen Namen ein!';
        }
        return null;
      },
    );
  }
}
