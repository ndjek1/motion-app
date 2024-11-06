import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/user.dart';
import 'package:motion_app/screens/home/invitations_list.dart';
import 'package:motion_app/screens/wrapper.dart';
import 'package:motion_app/services/auth.dart';
import 'package:motion_app/services/notifications.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotification().initNorifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
