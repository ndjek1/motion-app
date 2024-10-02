import 'package:flutter/material.dart';
import 'package:motion_app/services/auth.dart';
import 'package:motion_app/shared/constants.dart';
import 'package:motion_app/shared/loading.dart';
// import 'package:lunch_crew/services/auth.dart';

class SignIn extends StatefulWidget {
  final Function? toggleView;
  const SignIn({super.key, this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

//text field state
  String password = '';
  String email = '';
  String error = '';
  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.green[100],
            appBar: AppBar(
              backgroundColor: Colors.green[400],
              elevation: 0.0,
              title: const Text('Signin in Motion'),
              actions: [
                TextButton.icon(
                  onPressed: () async {
                    widget.toggleView!();
                  },
                  icon: const Icon(Icons.person,
                      color: Colors.white), // set icon color to white
                  label: const Text(
                    'Register',
                    style: TextStyle(
                        color: Colors.white), // set text color to white
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors
                        .white, // applies to both text and icon by default
                  ),
                  iconAlignment: IconAlignment.start, // your custom alignment
                )
              ],
            ),
            body: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0),
                      TextFormField(
                          decoration: textInputDecoration.copyWith(
                            hintText: 'Email',
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter email' : null,
                          onChanged: (value) =>
                              {setState(() => email = value)}),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          hintText: 'Password',
                        ),
                        validator: (val) => val!.length < 6
                            ? 'Password must be at least 6 chars long'
                            : null,
                        obscureText: true,
                        onChanged: (value) =>
                            {setState(() => password = value)},
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600], // background
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });

                              dynamic result = await _auth
                                  .singInWithPasswordAndEmail(email, password);
                              if (result == null) {
                                setState(() {
                                  error =
                                      'Could not signin with those credentials. Please try again';
                                  loading = false;
                                });
                                print(error);
                              }
                            }
                          }),
                      const SizedBox(
                        height: 12.0,
                      ),
                      Text(
                        error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    ],
                  ),
                )),
          );
  }
}
