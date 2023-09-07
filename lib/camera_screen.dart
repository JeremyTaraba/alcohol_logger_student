import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras; //all the cameras on the device
  late CameraController _controller;
  late Future<bool> _task;

  @override
  void initState() {
    _task = cameraSetup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: CameraPreview(_controller),
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: 3,
      ),
    );
  }

  Future<bool> cameraSetup() async {
    cameras = await availableCameras();
    _controller =
        CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);

    _controller.initialize().then((value) {
      if (!mounted) {
        return true;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case "CameraAccessDenied":
            print("Access to camera denied");
            break;
          default:
            print(e.description);
            break;
        }
      }
      return false;
    });

    return false;
  }
}
