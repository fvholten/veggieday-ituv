import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../screens/veggieday_countdown_screen.dart';

class VeggiedayAppBar extends StatefulWidget implements PreferredSizeWidget {
  const VeggiedayAppBar(
      {required super.key, required this.title, this.showLogo = true})
      : preferredSize = const Size.fromHeight(kToolbarHeight * 1.5);

  final String title;

  @override
  final Size preferredSize; // default is 56.0

  final bool showLogo;

  @override
  VeggiedayAppBarState createState() => VeggiedayAppBarState();
}

class VeggiedayAppBarState extends State<VeggiedayAppBar> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  var _isSigningOut = false;

  void _onSubmit() {
    setState(() => _isSigningOut = true);
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        color: theme.primaryColorDark,
        child: Column(
          children: [
            AppBar(
              leading: widget.showLogo
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('assets/images/ituvshort.png',
                          color: Colors.white),
                    )
                  : null,
              title: Text(widget.title),
              actions: <Widget>[
                IconButton(
                  onPressed: _isSigningOut ? null : _onSubmit,
                  icon: _isSigningOut
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.grey,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(FontAwesomeIcons.signOutAlt),
                )
              ],
            ),
            const SizedBox(height: 8),
            const VeggiedayCountDownScreen()
          ],
        ));
  }
}
