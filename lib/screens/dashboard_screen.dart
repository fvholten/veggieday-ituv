import 'package:flutter/material.dart';
import '../widgets/veggieday_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:veggieday_ituv/domain/food.dart';
import 'package:veggieday_ituv/domain/task.dart';
import 'package:veggieday_ituv/domain/veggieday_signup.dart';
import 'veggieday_countdown_screen.dart';
import 'veggieday_signup_form.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder3<QuerySnapshot, QuerySnapshot, QuerySnapshot>(
        streams: StreamTuple3(
            db
                .collection(Constants.foodCollectionName)
                .orderBy('index')
                .snapshots(),
            db
                .collection(Constants.taskCollectionName)
                .orderBy('index')
                .snapshots(),
            db
                .collection(Constants.signupCollectionName)
                .where('veggieday', isGreaterThan: DateTime.now())
                .snapshots()),
        builder: (context, snapshots) {
          if (!snapshots.snapshot1.hasData ||
              !snapshots.snapshot2.hasData ||
              !snapshots.snapshot3.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<Food> foods = snapshots.snapshot1.data!.docs
                .map((doc) => Food(doc.get('name'), doc.get('description')))
                .toList();
            Map<String, Food> foodsMap = {
              for (var element in foods) element.name: element
            };

            var taskCounts = {};
            snapshots.snapshot3.data!.docs
                .map((doc) => doc.get(Constants.taskFieldName))
                .forEach((element) {
              if (!taskCounts.containsKey(element)) {
                taskCounts[element] = 1;
              } else {
                taskCounts[element] += 1;
              }
            });

            List<Task> tasks = snapshots.snapshot2.data!.docs
                .map((doc) =>
                    Task(doc.id, doc.get('name'), taskCounts[doc.id] ?? 0))
                .toList();
            Map<String, Task> tasksMap = {
              for (var element in tasks) element.name: element
            };

            int signupIndex = snapshots.snapshot3.data!.docs.indexWhere((doc) {
              return doc.get('uid') == currentUser.uid;
            });
            return Scaffold(
              appBar: const VeggiedayAppBar(
                title: 'Veggieday',
                key: Key('Dashboard-Appbar'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: Constants.signupOpen()
                    ? () => editOrSignUp(snapshots, tasksMap, foodsMap, context,
                        foods, tasks, signupIndex)
                    : null,
                child: Icon((signupIndex < 0) ? Icons.add : Icons.edit),
              ),
              body: snapshots.snapshot3.data!.docs.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                          Text('\\(o_o)/', style: TextStyle(fontSize: 50)),
                          SizedBox(height: 16),
                          Text('Noch leer hier! Los, melde dich schnell an!'),
                        ]))
                  : ListView(
                      children: snapshots.snapshot3.data!.docs.map((doc) {
                        String uid = doc.get('uid');
                        VeggiedaySignUp signup = VeggiedaySignUp(
                            true,
                            doc.get(Constants.nameFieldName),
                            tasksMap[doc.get(Constants.taskFieldName)],
                            foodsMap[doc.get(Constants.foodFieldName)]);

                        return VeggiedaySignupWidget(
                            signup: signup,
                            uid: uid,
                            currentUser: currentUser,
                            foods: foods,
                            tasks: tasks);
                      }).toList(),
                    ),
            );
          }
        });
  }

  void editOrSignUp(
      SnapshotTuple3<QuerySnapshot<Object?>, QuerySnapshot<Object?>,
              QuerySnapshot<Object?>>
          snapshots,
      Map<String, Task> tasksMap,
      Map<String, Food> foodsMap,
      BuildContext context,
      List<Food> foods,
      List<Task> tasks,
      int signupIndex) {
    VeggiedaySignUp signUp;
    if (signupIndex == -1) {
      signUp = VeggiedaySignUp.empty();
    } else {
      var doc = snapshots.snapshot3.data!.docs[signupIndex];
      signUp = VeggiedaySignUp(
          true,
          doc.get(Constants.nameFieldName),
          tasksMap[doc.get(Constants.taskFieldName)],
          foodsMap[doc.get(Constants.foodFieldName)]);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              VeggiedaySignUpForm(signup: signUp, foods: foods, tasks: tasks)),
    );
  }
}

class VeggiedaySignupWidget extends StatelessWidget {
  const VeggiedaySignupWidget({
    Key? key,
    required this.signup,
    required this.uid,
    required this.currentUser,
    required this.foods,
    required this.tasks,
  }) : super(key: key);

  final VeggiedaySignUp signup;
  final String uid;
  final User? currentUser;
  final List<Food> foods;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    bool thisUsersSignUp = (uid == currentUser?.uid);
    return Card(
        child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              (signup.name ?? '') +
                  (thisUsersSignUp ? ' - eigene Anmeldung' : ''),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: Wrap(
                direction: Axis.vertical,
                spacing: 8,
                children: thisUsersSignUp
                    ? [
                        subtitleRowText('Aufgabe', signup.task!.description),
                        subtitleRowText('Essenswahl', signup.food!.description),
                        const Text(
                          '-Klicken zum Bearbeiten-',
                          style: TextStyle(
                              fontWeight: FontWeight.w100, color: Colors.grey),
                        )
                      ]
                    : [
                        subtitleRowText('Aufgabe', signup.task!.description),
                        subtitleRowText('Essenswahl', signup.food!.description),
                      ],
              ),
            ),
            selected: thisUsersSignUp,
            onTap: (uid == currentUser?.uid)
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VeggiedaySignUpForm(
                              signup: signup, foods: foods, tasks: tasks)),
                    );
                  }
                : null));
  }

  Text subtitleRowText(String task, String details) {
    return Text('$task: $details');
  }
}
