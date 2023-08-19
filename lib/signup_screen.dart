import 'package:alcohol_logger/home_screen.dart';
import 'package:alcohol_logger/login_screen.dart';
import 'package:alcohol_logger/utility/buttons.dart';
import 'package:alcohol_logger/utility/text_fields.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String email = "";
  String password = "";
  String name = "";
  String confirmPassword = "";
  final formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  SnackBar snackBar(String error) {
    return SnackBar(
      content: Text(error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: const SpinKitWaveSpinner(
        color: Colors.transparent,
        trackColor: Colors.transparent,
        waveColor: Colors.lightBlueAccent,
        size: 200,
        duration: Duration(milliseconds: 1000),
        curve: Curves.linearToEaseOut,
      ),
      inAsyncCall: showSpinner,
      child: Container(
        color: Colors.white,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/drink_pour_login.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 25, left: 10, right: 10),
                      child: TextFormField(
                        onChanged: (value) {
                          name = value;
                        },
                        validator: (String? value) {
                          if (value != null && value.isNotEmpty) {
                            return null;
                          } else {
                            return "Enter your name";
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(fontSize: 22),
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        decoration:
                            kTextFieldDecoration().copyWith(hintText: "Name"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 25, left: 10, right: 10, bottom: 25),
                      child: TextFormField(
                        onChanged: (value) {
                          email = value;
                        },
                        validator: (String? value) {
                          if (value != null &&
                              value.contains('@') &&
                              value.contains('.')) {
                            return null;
                          } else {
                            return "Enter a valid email";
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(fontSize: 22),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            kTextFieldDecoration().copyWith(hintText: "Email"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 25),
                      child: TextFormField(
                        onChanged: (value) {
                          password = value;
                        },
                        validator: (String? value) {
                          if (value != null && value.length > 5) {
                            return null;
                          } else {
                            return "Must be at least 6 characters";
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(fontSize: 22),
                        autocorrect: false,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: kTextFieldDecoration()
                            .copyWith(hintText: "Password"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 25),
                      child: TextFormField(
                        onChanged: (value) {
                          confirmPassword = value;
                        },
                        validator: (String? value) {
                          if (value == password) {
                            return null;
                          } else {
                            return "Password do not match";
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(fontSize: 22),
                        autocorrect: false,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: kTextFieldDecoration()
                            .copyWith(hintText: "Confirm Password"),
                      ),
                    ),
                    Center(child: SignUpButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            showSpinner = true;
                          });
                          try {
                            final newUser =
                                await _auth.createUserWithEmailAndPassword(
                                    email: email, password: password);
                            if (newUser != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                            }
                          } catch (e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBar(
                                e.toString().split(']')[1],
                              ),
                            );
                          }
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      },
                    )),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(fontSize: 20),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()));
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
