import 'package:flutter/material.dart';
import 'package:motion_app/services/auth.dart';
import 'package:motion_app/shared/constants.dart';
import 'package:motion_app/shared/loading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Register extends StatefulWidget {
  final Function? toggleView;
  const Register({super.key, this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isHovered = false;

  // Text field state
  String password = '';
  String email = '';
  String displayName = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.grey[200],
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.grey[850],
              elevation: 0.0,
              title: const Text(
                'Create Account',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () async {
                    widget.toggleView!();
                  },
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text(
                    'Sign in',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 50.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                            colors: [
                              Colors.grey[400]!,
                              Colors.grey[600]!,
                            ],
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
                                'Let\'s Get Started!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: textInputDecoration.copyWith(
                                  hintText: 'Display Name',
                                  hintStyle:
                                      const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.person,
                                      color: Colors.white),
                                  fillColor: Colors.grey[300],
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (val) => val!.isEmpty
                                    ? 'Enter a display name'
                                    : null,
                                onChanged: (value) =>
                                    setState(() => displayName = value),
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                decoration: textInputDecoration.copyWith(
                                  hintText: 'Email',
                                  hintStyle:
                                      const TextStyle(color: Colors.white70),
                                  prefixIcon: const Icon(Icons.email,
                                      color: Colors.white),
                                  fillColor: Colors.grey[300],
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (val) =>
                                    val!.isEmpty ? 'Enter an email' : null,
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
                                  fillColor: Colors.grey[300],
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
                                label: const Text(
                                  'Register',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[800],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                                onHover: (hovering) =>
                                    setState(() => isHovered = hovering),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    dynamic result = await _auth
                                        .registerWithEmailAndPassword(
                                            email, password, displayName);
                                    if (result == null) {
                                      setState(() {
                                        error = 'Please supply a valid email';
                                        loading = false;
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
