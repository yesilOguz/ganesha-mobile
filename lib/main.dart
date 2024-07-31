import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ganesha/screens/admin_home_screen.dart';
import 'package:ganesha/screens/home_screen.dart';
import 'package:ganesha/screens/login_screen.dart';
import 'package:ganesha/screens/server_error_screen.dart';
import 'package:ganesha/screens/welcome_screen.dart';
import 'package:ganesha/service/background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend/Health.dart';
import 'global_variable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid || Platform.isIOS){
    await initializeService();
  }

  var screen = await selectScreen();

  runApp(MyApp(screen: screen));
}

Future<Widget> selectScreen() async {
  bool serverHealth = await Health.checkServerHealth();

  // if server down
  if (!serverHealth) {
    return const ServerErrorScreen();
  }

  final prefs = await SharedPreferences.getInstance();

  // if phone has no access key
  if (!prefs.containsKey('accessKey')) {
    return const WelcomeScreen();
  }

  bool keyHealth = await Health.checkKeyHealth();

  // if access key is not valid anymore
  if (!keyHealth) {
    bool refreshKey = await Health.refreshKey();

    // if refresh key is not work
    if (!refreshKey) {
      return const LoginScreen();
    }
  }

  // if everything is okay and user is admin
  // it can be manipulated by someone but backend is checking user so it is not a problem
  if (prefs.containsKey('isAdmin') && prefs.getBool('isAdmin')!) {
    return const AdminHomeScreen();
  }

  // if everything is okay and user is not admin
  return const HomeScreen();
}

class MyApp extends StatefulWidget {
  final Widget screen;

  const MyApp({super.key, required this.screen});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      GlobalVariable.dailyAdviceTimer!.cancel();
      GlobalVariable.dailyAdviceTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      navigatorKey: GlobalVariable.navState,
      routes: {
        '/': (context) => widget.screen,
      },
    );
  }
}
