import 'package:flutter/material.dart';
import 'package:motion_app/services/auth.dart';
import 'package:motion_app/shared/constants.dart';
import 'package:motion_app/shared/loading.dart';

class Register extends StatefulWidget {
  final Function? toggleView;
  const Register({super.key, this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String password = '';
  String email = '';
   String displayName = '';
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
              title: const Text('Sign up page'),
              actions: [
                TextButton.icon(
                  onPressed: () async {
                    widget.toggleView!();
                  },
                  icon: const Icon(Icons.person,
                      color: Colors.white), // set icon color to white
                  label: const Text(
                    'Sign in',
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
                      const Center(
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                            decoration: textInputDecoration.copyWith(
                              hintText: 'Display name',
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Enter a display name' : null,
                            onChanged: (value) => {
                              setState(() => displayName = value)
                            }),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                            decoration: textInputDecoration.copyWith(
                              hintText: 'Email',
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Enter email' : null,
                            onChanged: (value) =>
                                {setState(() => email = value)}),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
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
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600], // background
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              print('loading');
                              dynamic ressult =
                                  await _auth.registerWithEmailAndPassword(
                                      email, password,displayName);
                              if (ressult == null) {
                                setState(() {
                                  error = 'Please enter a valid email';
                                  loading = false;
                                });
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
                      )
                    ],
                  ),
                )),
          );
  }
}
