import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markets_data_inserting/screens/GoogleMapsScreen.dart';
import 'package:provider/provider.dart';

import '../Themes/DarkThemeProvider.dart';
import '../screens/SignInScreen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required FirebaseAuth auth,
  }) : _auth = auth;

  final FirebaseAuth _auth;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25),
        ),
      ),
      title: const Text("Markets"),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20.0, top: 0),
          child: CupertinoSwitch(
            activeColor: Theme.of(context).disabledColor,
            value: themeChange.darkTheme,
            onChanged: (bool? value) {
              themeChange.darkTheme = value!;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0, top: 0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GoogleMapsScreen(auth: _auth)),
              );
            },
            child: const Icon(Icons.map_outlined),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 10),
            child: GestureDetector(
              onTap: () async {
                // Perform the sign-out process
                await _auth.signOut();
                // After signing out, switch back to the SignInScreen
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
              child: const Icon(
                Icons.logout_sharp,
                size: 26.0,
              ),
            )),
      ],
    );
  }
}
