import 'package:flutter/material.dart';

InputDecoration kTextFieldDecoration() {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(10),
    hintText: "Email",
    fillColor: Colors.grey[200],
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
