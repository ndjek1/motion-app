import 'package:flutter/material.dart';
import 'package:motion_app/models/user.dart';
import 'package:motion_app/screens/authenticate/authenticate.dart';
import 'package:motion_app/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //return either home or authenticat
    final user = Provider.of<MyUser?>(context);
    //return either home or authenticate

    if (user == null) {
      return const Authenticate();
    } else {
      return HomeScreen();
    }
  }
}
