import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      bottomNavigationBar: BottomNav(
        selectedIndex: 0,
      ),
    );
  }
}
