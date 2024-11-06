import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motion_app/services/auth.dart';
import 'package:motion_app/shared/constants.dart';
import 'package:motion_app/shared/loading.dart';

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
  bool isHovered = false;

  // Text field state
  String password = '';
  String email = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              backgroundColor: Colors.grey[850],
              elevation: 0.0,
              title: const Text(
                'Sign in Motion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () async {
                    widget.toggleView!();
                  },
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30.0),
                      const Hero(
                        tag: 'logo',
                        child: Icon(
                          FontAwesomeIcons.userAstronaut,
                          color: Colors.grey,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[400]!, Colors.grey[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: textInputDecoration.copyWith(
                                  hintText: 'Email',
                                  hintStyle:
                                      const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.email,
                                      color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.grey[300],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (val) =>
                                    val!.isEmpty ? 'Enter your email' : null,
                                onChanged: (value) =>
                                    setState(() => email = value),
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                decoration: textInputDecoration.copyWith(
                                  hintText: 'Password',
                                  hintStyle:
                                      const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.grey[300],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: (val) => val!.length < 6
                                    ? 'Password must be at least 6 characters long'
                                    : null,
                                onChanged: (value) =>
                                    setState(() => password = value),
                              ),
                              const SizedBox(height: 20.0),
                              ElevatedButton.icon(
                                icon: isHovered
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.white)
                                    : const Icon(Icons.arrow_forward,
                                        color: Colors.white),
                                label: const Text('Sign In',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[800],
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)),
                                ),
                                onHover: (hovering) =>
                                    setState(() => isHovered = hovering),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    dynamic result =
                                        await _auth.singInWithPasswordAndEmail(
                                            email, password);
                                    if (result == null) {
                                      setState(() {
                                        error =
                                            'Could not sign in with those credentials';
                                        loading = false;
                                      });
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                error,
                                style: const TextStyle(
                                    color: Colors.redAccent, fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
