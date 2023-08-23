import 'package:alcohol_logger/camera_screen.dart';
import 'package:alcohol_logger/history_screen.dart';
import 'package:alcohol_logger/home_screen.dart';
import 'package:alcohol_logger/profile_screen.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  BottomNav({super.key, required this.selectedIndex});
  int selectedIndex;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  void bottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ProfileScreen()));
    }
    if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
    if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HistoryScreen()));
    }
    if (index == 3) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CameraScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: bottomNavTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.lightBlueAccent,
      currentIndex: widget.selectedIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          label: "Camera",
        ),
      ],
    );
  }
}
