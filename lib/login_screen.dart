import 'package:alcohol_logger/home_screen.dart';
import 'package:alcohol_logger/signup_screen.dart';
import 'package:alcohol_logger/utility/buttons.dart';
import 'package:alcohol_logger/utility/text_fields.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    fetchSecureStorageData();
  }

  fetchSecureStorageData() async {
    Map<String, String> loginCredentials = await _storage.readAll();
    email = loginCredentials.keys.toList().first;
    password = loginCredentials[email]!;
    print(email);
    print(password);
  }

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
              Column(
                children: [
                  SizedBox(
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 25),
                    child: TextField(
                        onChanged: (value) {
                          email = value;
                        },
                        style: TextStyle(fontSize: 22),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: kTextFieldDecoration().copyWith(hintText: "Email")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 25),
                    child: TextField(
                        onChanged: (value) {
                          password = value;
                        },
                        style: TextStyle(fontSize: 22),
                        autocorrect: false,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: kTextFieldDecoration().copyWith(hintText: "Password")),
                  ),
                  Center(
                    child: LoginButton(
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                          if (user != null) {
                            await _storage.write(key: email, value: password);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Forgot password",
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(fontSize: 20),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(color: Colors.blue, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
