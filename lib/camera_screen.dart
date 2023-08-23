import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      bottomNavigationBar: BottomNav(
        selectedIndex: 3,
      ),
    );
  }
}
