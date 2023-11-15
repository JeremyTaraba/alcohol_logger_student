import 'package:alcohol_logger/image_preview_screen.dart';
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
      body: FutureBuilder(
        future: _task,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Container(
                  height: double.infinity,
                  child: CameraPreview(_controller),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.white.withOpacity(.4),
                      width: double.infinity,
                      child: IconButton(
                        onPressed: () async {
                          if (!_controller.value.isInitialized) {
                            return;
                          }
                          if (_controller.value.isTakingPicture) {
                            return;
                          }

                          try {
                            await _controller.setFocusMode(FocusMode.locked);

                            XFile picture = await _controller.takePicture();

                            await _controller.setFocusMode(FocusMode.locked);

                            await Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewScreen(picture: picture)));
                          } on CameraException catch (e) {
                            print(e);
                            return;
                          }
                        },
                        icon: Icon(Icons.camera),
                        iconSize: 70,
                        color: Colors.black,
                      ),
                    )),
              ],
            );
          }
          return Container();
        },
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: 3,
      ),
    );
  }

  Future<bool> cameraSetup() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);

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
