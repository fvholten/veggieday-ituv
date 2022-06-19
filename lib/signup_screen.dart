import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:veggieday_ituv/constants.dart';
import 'package:veggieday_ituv/food.dart';
import 'package:veggieday_ituv/task.dart';
import 'package:veggieday_ituv/datetime-ext.dart';

class VeggiedaySignUpForm extends StatefulWidget {
  @override
  _VeggiedaySignUpFormState createState() => _VeggiedaySignUpFormState();
}

class _VeggiedaySignUpFormState extends State<VeggiedaySignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final db = FirebaseFirestore.instance;

  TextEditingController nameEditingController = TextEditingController();
  Task? selectedTask;
  Food? selectedFood;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor.withOpacity(.1),
        title: const Text('Veggieday Anmeldung'),
      ),
      body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Enter your name here
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameEditingController,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        autofillHints: const {AutofillHints.name},
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Bitte deinen Namen eingeben';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField(
                        items: Food.values
                            .map((item) => DropdownMenuItem<Food>(
                                  value: item,
                                  child: Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Veggie oder Fleisch?',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedTask,
                        onChanged: (Enum? value) =>
                            selectedFood = value as Food,
                      ),
                      const SizedBox(height: 20),
                      // task
                      DropdownButtonFormField(
                        items: Task.values
                            .map((item) => DropdownMenuItem<Task>(
                                  value: item,
                                  child: Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Aufgabe',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedFood,
                        onChanged: (Enum? value) =>
                            selectedTask = value as Task,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.blue),
                            onPressed: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.blue),
                            onPressed: () {
                              debugPrint(
                                  'NAME:${nameEditingController.text} FOOD:$selectedFood TASK:$selectedTask');
                              if (_formKey.currentState?.validate() ?? false) {
                                debugPrint('Form Valid!');
                                String userEMail =
                                    FirebaseAuth.instance.currentUser!.email!;
                                DateTime dateOfVeggieDay =
                                    DateTime.now().next(DateTime.wednesday);
                                String veggiedayDate = DateFormat('yyyy_MM_dd')
                                    .format(dateOfVeggieDay);
                                debugPrint(veggiedayDate);
                                db
                                    .collection(Constants.signupCollectionName)
                                    .doc('$veggiedayDate-$userEMail')
                                    .set({
                                      Constants.nameFieldName:
                                          nameEditingController.text,
                                      'uid': FirebaseAuth
                                          .instance.currentUser?.uid,
                                      Constants.veggiedayFieldName: DateTime(
                                          dateOfVeggieDay.year,
                                          dateOfVeggieDay.month,
                                          dateOfVeggieDay.day),
                                      Constants.foodFieldName:
                                          selectedFood!.value,
                                      Constants.taskFieldName:
                                          selectedTask!.value
                                    }, SetOptions(merge: true))
                                    .onError((e, _) => debugPrint(
                                        "Error writing document: $e"))
                                    .then((value) => Navigator.pop(context));
                              }
                            },
                            child: const Text('Anmelden!'),
                          ),
                        ],
                      ),
                    ],
                  )))),
    );
  }
}
