import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/user.dart';
import 'package:motion_app/screens/home/invitations_list.dart';
import 'package:motion_app/screens/wrapper.dart';
import 'package:motion_app/services/auth.dart';
import 'package:motion_app/services/notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await initializeApp();

  runApp(const MyApp());
}

Future<void> initializeApp() async {
  try {
    await Firebase.initializeApp();
    await PushNotification().initNotifications();
  } catch (e) {
    print('Error during app initialization: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        routes: {
          '/invitationList': (context) => InvitationListWidget(),
        },
        home: const Wrapper(),
      ),
    );
  }
}
