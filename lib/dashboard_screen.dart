import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_login/theme.dart';
import 'package:flutter_login/widgets.dart';
import 'package:veggieday_ituv/food.dart';
import 'package:veggieday_ituv/task.dart';
import 'package:veggieday_ituv/veggieday_signup.dart';
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

    DateTime dateOfVeggieDay = DateTime.now().next(DateTime.wednesday);

    return WillPopScope(
        onWillPop: () => _goToLogin(context),
        child: SafeArea(
            child: Scaffold(
          appBar: _buildAppBar(theme),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        VeggiedaySignUpForm(signup: VeggiedaySignUp())),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
          body: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection(Constants.signupCollectionName)
                  .where('veggieday', isGreaterThan: DateTime.now())
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      VeggiedaySignUp signup = VeggiedaySignUp();

                      signup.name = doc.get(Constants.nameFieldName);
                      String uid = doc.get('uid');
                      signup.task = Task.values.firstWhere(
                          (e) => e.value == doc.get(Constants.taskFieldName));
                      signup.food = Food.values.firstWhere(
                          (e) => e.value == doc.get(Constants.foodFieldName));
                      return Card(
                          child: ListTile(
                              title: Row(
                                children: [
                                  const Icon(Icons.person),
                                  Text(signup.name ?? ''),
                                ],
                              ),
                              subtitle: Text(
                                  'Aufgabe: ${signup.task!.description}, Essenswahl: ${signup.food!.description}'),
                              onTap: () {
                                if (uid == currentUser?.uid) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            VeggiedaySignUpForm(
                                              signup: signup,
                                            )),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text(
                                        'Du kannst nur deinen Eintrag verändern!'),
                                    action: SnackBarAction(
                                      label: 'Okay',
                                      onPressed: () {},
                                    ),
                                  ));
                                }
                              }));
                    }).toList(),
                  );
                }
              }),
        )));
  }
}
