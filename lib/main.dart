import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:markets_data_inserting/Themes/DarkThemeProvider.dart';
import 'package:markets_data_inserting/screens/HomeScreen.dart';
import 'package:markets_data_inserting/screens/SignInScreen.dart';
import 'package:provider/provider.dart';

import 'Themes/DarkThemePreference.dart';
import 'Themes/Styles.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      }, 
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            home: StreamBuilder<User?>(
              stream: _auth.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final user = snapshot.data;
                  if (user == null) {
                    // User is not authenticated, show the sign-in screen.
                    return SignInScreen();
                  } else {
                    // User is authenticated, show the home screen.
                    return HomeScreen();
                  }
                }
                // Show a loading indicator while waiting for the authentication state.
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            //routes: <String, WidgetBuilder>{ AGENDA: (BuildContext context) => AgendaScreen(),},
          );
        },
      ),
    );
  }
}

// return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: StreamBuilder<User?>(
//         stream: _auth.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.active) {
//             final user = snapshot.data;
//             if (user == null) {
//               // User is not authenticated, show the sign-in screen.
//               return SignInScreen();
//             } else {
//               // User is authenticated, show the home screen.
//               return HomeScreen();
//             }
//           }
//           // Show a loading indicator while waiting for the authentication state.
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         },
//       ),
//     );
