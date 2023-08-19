import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  DefaultButton(
      {super.key,
      required this.backgroundColor,
      required this.text,
      required this.textColor,
      required this.onPressed,
      required this.width});

  Color? backgroundColor;
  String text;
  Color? textColor;
  void Function() onPressed;
  double width;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: width, vertical: 8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 32, color: textColor),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  LoginButton({super.key, required this.onPressed});
  void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      backgroundColor: Colors.indigo[800],
      text: "Login",
      textColor: Colors.white,
      onPressed: onPressed,
      width: 110,
    );
  }
}

class SignUpButton extends StatelessWidget {
  SignUpButton({super.key, required this.onPressed});
  void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      backgroundColor: Colors.white,
      text: "Sign up",
      textColor: Colors.indigo[800],
      onPressed: onPressed,
      width: 95,
    );
  }
}
