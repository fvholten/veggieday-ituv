import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_login/theme.dart';
import 'package:flutter_login/widgets.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:veggieday_ituv/domain/food.dart';
import 'package:veggieday_ituv/domain/task.dart';
import 'package:veggieday_ituv/domain/veggieday_signup.dart';
import 'signup_screen.dart';
import 'transition_route_observer.dart';
import 'widgets/fade_in.dart';
import 'constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veggieday_ituv/datetime-ext.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, TransitionRouteAware {
  Future<bool> _goToLogin(BuildContext context) {
    return Navigator.of(context)
        .pushReplacementNamed('/auth')
        .then((_) => FirebaseAuth.instance.currentUser != null);
  }

  final routeObserver = TransitionRouteObserver<PageRoute?>();
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  AnimationController? _loadingController;

  final currentUser = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(
        this, ModalRoute.of(context) as PageRoute<dynamic>?);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _loadingController!.dispose();
    super.dispose();
  }

  @override
  void didPushAfterTransition() => _loadingController!.forward();

  AppBar _buildAppBar(ThemeData theme) {
    final signOutBtn = IconButton(
      icon: const Icon(FontAwesomeIcons.signOutAlt),
      color: theme.colorScheme.secondary,
      onPressed: () {
        FirebaseAuth.instance.signOut().whenComplete(() => _goToLogin(context));
      },
    );
    final title = Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Hero(
            tag: Constants.logoTag,
            child: Image.asset(
              'assets/images/ecorp.png',
              height: 30,
            ),
          ),
        ),
        HeroText(
          Constants.appName,
          tag: Constants.titleTag,
          viewState: ViewState.shrunk,
          style: LoginThemeHelper.loginTextStyle,
        ),
        const SizedBox(width: 20),
      ],
    );

    return AppBar(
      actions: <Widget>[
        FadeIn(
          controller: _loadingController,
          offset: .3,
          curve: headerAniInterval,
          fadeDirection: FadeDirection.endToStart,
          child: signOutBtn,
        ),
      ],
      title: title,
      backgroundColor: theme.primaryColor.withOpacity(.1),
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
        onWillPop: () => _goToLogin(context),
        child: SafeArea(
            child: StreamBuilder3<QuerySnapshot, QuerySnapshot, QuerySnapshot>(
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
                        .map((doc) =>
                            Food(doc.get('name'), doc.get('description')))
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
                        .map((doc) => Task(
                            doc.id, doc.get('name'), taskCounts[doc.id] ?? 0))
                        .toList();
                    Map<String, Task> tasksMap = {
                      for (var element in tasks) element.name: element
                    };
                    return Scaffold(
                      appBar: _buildAppBar(theme),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          var index =
                              snapshots.snapshot3.data!.docs.indexWhere((doc) {
                            return doc.get('uid') == currentUser?.uid;
                          });

                          VeggiedaySignUp signUp;
                          if (index == -1) {
                            signUp = VeggiedaySignUp.empty();
                          } else {
                            var doc = snapshots.snapshot3.data!.docs[index];
                            signUp = VeggiedaySignUp(
                                true,
                                doc.get(Constants.nameFieldName),
                                tasksMap[doc.get(Constants.taskFieldName)],
                                foodsMap[doc.get(Constants.foodFieldName)]);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VeggiedaySignUpForm(
                                    signup: signUp,
                                    foods: foods,
                                    tasks: tasks)),
                          );
                        },
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.add),
                      ),
                      body: ListView(
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
                })));
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
    return Card(
        child: ListTile(
            leading: const Icon(Icons.person),
            iconColor: const Color.fromARGB(180, 0, 0, 0),
            textColor: const Color.fromARGB(180, 0, 0, 0),
            title: Text(
              signup.name ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: Wrap(
                direction: Axis.vertical,
                spacing: 8,
                children: [
                  Text('Aufgabe: ${signup.task!.description}'),
                  Text('Essenswahl: ${signup.food!.description}'),
                ],
              ),
            ),
            onTap: () {
              if (uid == currentUser?.uid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VeggiedaySignUpForm(
                          signup: signup, foods: foods, tasks: tasks)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      const Text('Du kannst nur deinen Eintrag verändern!'),
                  action: SnackBarAction(
                    label: 'Okay',
                    onPressed: () {},
                  ),
                ));
              }
            }));
  }
}
